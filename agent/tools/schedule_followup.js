// Tool 5: schedule_followup
// Generates reminder payload — Flutter fires local notification

const scheduleFollowup = (bookingPayload) => {
  console.log('\n--- Running schedule_followup ---');

  const reminder = {
    booking_id:   bookingPayload.booking_id,
    trigger_at:   bookingPayload.reminder_at,
    message:      `Reminder: ${bookingPayload.provider_name} arrives in 1 hour.`,
    status:       'reminder_scheduled',
  };

  console.log(`Reminder scheduled for: ${reminder.trigger_at}`);
  return reminder;
};

module.exports = { scheduleFollowup };
