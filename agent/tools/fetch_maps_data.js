const fetchMapsData = async (serviceCategory, location) => {
  console.log('\n--- Running fetch_google_maps_data ---');
  console.log(`Querying: "${serviceCategory}" near "${location}"`);

  const apiKey = process.env.GOOGLE_PLACES_API_KEY;
  if (!apiKey) {
    console.error('GOOGLE_PLACES_API_KEY not found in .env');
    return null;
  }

  const url = 'https://places.googleapis.com/v1/places:searchText';
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.location',
    },
    body: JSON.stringify({
      textQuery: `${serviceCategory} near ${location}`,
      maxResultCount: 10,
    }),
  });

  const data = await response.json();
  const places = data.places || [];

  // Attach a mock distance based on result order
  // (real geocoding would need a second API call)
  const withDistance = places.map((p, i) => ({
    ...p,
    estimatedDistanceKm: parseFloat((1.0 + i * 0.4).toFixed(1)),
  }));

  console.log(`Found ${withDistance.length} providers`);
  return withDistance;
};

module.exports = { fetchMapsData };