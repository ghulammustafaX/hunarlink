const rankAndSelect = (providers, timePreference) => {
  console.log('\n--- Running rank_and_select ---');

  const scored = providers.map(p => {
    // Real proximity score based on distance
    const km = p.estimatedDistanceKm || 3.0;
    const proximityScore =
      km <= 2 ? 1.0 :
      km <= 4 ? 0.8 :
      km <= 6 ? 0.6 : 0.4;

    const ratingScore       = (p.rating || 3.0) / 5.0;
    const availabilityScore = timePreference === 'today_urgent' ? 0.0 : timePreference === 'flexible' ? 0.5 : 1.0;

    const score = (0.40 * proximityScore) + (0.35 * ratingScore) + (0.25 * availabilityScore);

    const name = p?.displayName?.text || 'Provider';
    return {
      ...p,
      displayName: { text: name.length > 40 ? name.substring(0, 40) + '...' : name },
      distanceLabel: `${km} km`,
      score: parseFloat(score.toFixed(2)),
    };
  });

  scored.sort((a, b) => b.score - a.score);
  const top3     = scored.slice(0, 3);
  const selected = top3[0];

  console.log('\n     Rankings:');
  top3.forEach((p, i) => {
    console.log(`     ${i + 1}. ${p.displayName.text} — Score: ${p.score} | ${p.distanceLabel} | ⭐ ${p.rating || 'N/A'}`);
  });
  console.log(`\n     Selected: ${selected?.displayName?.text}`);

  const reasoning = `Selected ${selected?.displayName?.text} as the best match. ` +
    `Closest available at ${selected?.distanceLabel} with a ${selected?.rating || 'N/A'} rating ` +
    `and a weighted score of ${selected?.score} (proximity 40%, rating 35%, availability 25%).`;

  return { ranked: top3, selected, reasoning };
};

module.exports = { rankAndSelect };