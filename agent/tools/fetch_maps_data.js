// Tool 2: fetch_google_maps_data
// Calls Google Maps Places API (New) to find real nearby providers

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
      'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.rating,places.userRatingCount',
    },
    body: JSON.stringify({
      textQuery: `${serviceCategory} near ${location}`,
    }),
  });

  const data = await response.json();
  console.log(`Found ${data.places?.length || 0} providers`);
  return data.places || [];
};

module.exports = { fetchMapsData };
