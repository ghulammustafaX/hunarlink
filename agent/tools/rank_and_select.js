// Tool 3: rank_and_select
// Scores and ranks providers using weighted formula

const rankAndSelect = (providers, timePreference) => {
  console.log('\n--- Running rank_and_select ---');

  const scored = providers.map(p => {
    const proximityScore  = 0.8;  // default — real distance needs geocoding
    const ratingScore     = (p.rating || 3.0) / 5.0;
    const availabilityScore = timePreference === 'today_urgent' ? 0.5 : 1.0;

    const score = (0.40 * proximityScore) + (0.35 * ratingScore) + (0.25 * availabilityScore);
    return { ...p, score: parseFloat(score.toFixed(2)) };
  });

  scored.sort((a, b) => b.score - a.score);
  const selected = scored[0];

  console.log(`Selected: ${selected?.displayName?.text} (Score: ${selected?.score})`);
  return { ranked: scored, selected };
};

module.exports = { rankAndSelect };
