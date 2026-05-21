// ─── fetch_maps_data.js ──────────────────────────────────────────────────────
// Tool 2: Fetch nearby service providers via Google Maps Places API
// Tool 2b: Calculate real GPS distances via Google Distance Matrix API
//
// Flow:
//   1. Search providers via Places API (textQuery)
//   2. Extract lat/lng for each result
//   3. Batch call Distance Matrix API → get real driving distances in km
//   4. Fall back to index-estimate if Distance Matrix unavailable

const fetchMapsData = async (serviceCategory, location) => {
  console.log('\n--- Running fetch_google_maps_data ---');
  console.log(`Querying: "${serviceCategory}" near "${location}"`);

  // ─── MOCK MODE ─────────────────────────────────────────────────────────────
  if (process.env.MOCK_MODE === 'true') {
    const locLower = (location || '').toLowerCase();
    
    // DHA check or non-standard check to trigger empty -> radius expansion simulation
    const isStandardSector = ['g-13', 'g13', 'f-11', 'f11', 'g-14', 'g14', 'i-10', 'i10', 'f-8', 'f8', 'i-8', 'i8'].some(s => locLower.includes(s));
    let radiusExpanded = false;
    
    if (!isStandardSector || locLower.includes('dha') || locLower.includes('bahria')) {
      console.log('No providers found — expanding radius to 10km');
      radiusExpanded = true;
    }

    console.log('     [MOCK MODE] Returning mock provider dataset with GPS distances');
    const mockProviders = [
      { displayName: { text: 'Abbasi Electric & AC Repair' }, formattedAddress: '124, G-13/4, Islamabad', rating: 4.9, userRatingCount: 132, location: { latitude: 33.6938, longitude: 73.0156 } },
      { displayName: { text: 'Raja AC Services Islamabad' },  formattedAddress: 'G-14 Markaz, Islamabad',  rating: 4.7, userRatingCount: 84,  location: { latitude: 33.7001, longitude: 73.0089 } },
      { displayName: { text: 'Khan Brothers Technicians' },   formattedAddress: 'F-11/2, Islamabad',        rating: 4.6, userRatingCount: 61,  location: { latitude: 33.7073, longitude: 72.9987 } },
      { displayName: { text: 'Al-Madina Home Services' },     formattedAddress: 'G-13/3, Islamabad',        rating: 4.4, userRatingCount: 47,  location: { latitude: 33.6921, longitude: 73.0201 } },
      { displayName: { text: 'Islamabad Quick Fix' },         formattedAddress: 'I-10, Islamabad',          rating: 4.2, userRatingCount: 29,  location: { latitude: 33.6637, longitude: 73.0479 } },
    ];
    // In mock mode, use real GPS distances via Distance Matrix if key available
    const withDistance = await attachDistances(mockProviders, location);
    if (radiusExpanded) {
      withDistance.forEach(p => p.radiusExpanded = true);
    }
    console.log(`Found ${withDistance.length} mock providers`);
    return withDistance;
  }

  // ─── LIVE MODE: Google Maps Places API ─────────────────────────────────────
  const placesKey = process.env.GOOGLE_PLACES_API_KEY;
  if (!placesKey) {
    console.error('GOOGLE_PLACES_API_KEY not found in .env');
    return null;
  }

  const url = 'https://places.googleapis.com/v1/places:searchText';
  const makeSearch = async (queryText) => {
    return await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': placesKey,
        'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.location',
      },
      body: JSON.stringify({
        textQuery: queryText,
        maxResultCount: 10,
      }),
    });
  };

  let response = await makeSearch(`${serviceCategory} near ${location}`);
  let data = await response.json();
  let places = data.places || [];
  let radiusExpanded = false;

  if (places.length === 0) {
    console.log('No providers found — expanding radius to 10km');
    radiusExpanded = true;
    response = await makeSearch(`${serviceCategory} near Islamabad`);
    data = await response.json();
    places = data.places || [];
  }

  if (places.length === 0) {
    console.warn('⚠️  No providers found from Places API');
    return [];
  }

  // ─── Attach real GPS distances via Distance Matrix API ──────────────────────
  const withDistance = await attachDistances(places, location);
  if (radiusExpanded) {
    withDistance.forEach(p => p.radiusExpanded = true);
  }
  console.log(`Found ${withDistance.length} providers with real GPS distances`);
  return withDistance;
};

// ─── Distance Matrix Helper ───────────────────────────────────────────────────
// Geocodes the user location string → calls Distance Matrix API with all
// provider lat/lng coordinates in one batch call → attaches real km distances.
const attachDistances = async (places, originLocation) => {
  const dmKey = process.env.GOOGLE_DISTANCE_MATRIX_API_KEY;

  // Build destination coordinates from places that have location data
  const destinations = places
    .map(p => p.location)
    .filter(loc => loc && (loc.latitude || loc.lat));

  if (!dmKey || destinations.length === 0) {
    // Graceful fallback — use index-based estimate
    console.log('     [Distance] Falling back to index-based estimates');
    return places.map((p, i) => ({
      ...p,
      estimatedDistanceKm: parseFloat((1.0 + i * 0.4).toFixed(1)),
      distanceSource: 'estimated',
    }));
  }

  try {
    // Build pipe-separated destination string: lat,lng|lat,lng|...
    const destStr = destinations
      .map(loc => `${loc.latitude ?? loc.lat},${loc.longitude ?? loc.lng}`)
      .join('|');

    const dmUrl = `https://maps.googleapis.com/maps/api/distancematrix/json` +
      `?origins=${encodeURIComponent(originLocation)}` +
      `&destinations=${encodeURIComponent(destStr)}` +
      `&units=metric` +
      `&mode=driving` +
      `&key=${dmKey}`;

    console.log(`     [Distance Matrix] Calculating real GPS distances for ${destinations.length} providers...`);

    const dmResponse = await fetch(dmUrl);
    const dmData = await dmResponse.json();

    if (dmData.status !== 'OK') {
      throw new Error(`Distance Matrix API error: ${dmData.status} — ${dmData.error_message || ''}`);
    }

    const elements = dmData.rows?.[0]?.elements || [];
    let dmIndex = 0;

    const withDistance = places.map((p, i) => {
      const hasLocation = p.location && (p.location.latitude || p.location.lat);
      if (!hasLocation) {
        // No coordinates — fall back to estimate
        return {
          ...p,
          estimatedDistanceKm: parseFloat((1.0 + i * 0.4).toFixed(1)),
          distanceSource: 'estimated',
        };
      }

      const element = elements[dmIndex++];
      if (element?.status === 'OK' && element.distance?.value != null) {
        const realKm = parseFloat((element.distance.value / 1000).toFixed(1));
        const durationText = element.duration?.text || '';
        console.log(`     ✅ ${p.displayName?.text}: ${realKm} km (${durationText} drive)`);
        return {
          ...p,
          estimatedDistanceKm: realKm,
          distanceSource: 'gps',
          drivingDuration: durationText,
        };
      }

      // Element not OK — fall back to estimate
      return {
        ...p,
        estimatedDistanceKm: parseFloat((1.0 + i * 0.4).toFixed(1)),
        distanceSource: 'estimated',
      };
    });

    return withDistance;

  } catch (err) {
    console.warn(`     ⚠️  Distance Matrix failed: ${err.message}`);
    console.log('     [Distance] Falling back to index-based estimates');
    // Graceful fallback
    return places.map((p, i) => ({
      ...p,
      estimatedDistanceKm: parseFloat((1.0 + i * 0.4).toFixed(1)),
      distanceSource: 'estimated',
    }));
  }
};

module.exports = { fetchMapsData };