var whatIf = {};

whatIf.init = function(daysInIter, remainingStoryPoints, lastIterEndDate) {

    try {
        var dateCalcText = jQuery("#what-if-date"),
            velocityText = jQuery("#what-if-velocity"),
            iterationsSpan = jQuery("#what-if-iterations"),
            secondsPerDay = 24 * 3600 * 1000;

        var dateDiffInDays = function(startDate, endDate) {
            var endTime = endDate.getTime(),
                startTime = startDate.getTime();
            macroDebug.log('date diff for: ' + startDate + '-' + endDate);
            return parseInt((endTime - startTime) / secondsPerDay, 10);
        };

        var remainingIterations = function(velocity, remaining_story_points) {
            return Math.ceil(remaining_story_points / velocity);
        };

        var expectedCompletionDateFor = function(lastIterEndDate, daysInIter, remainingIterations) {
            return new Date(lastIterEndDate.getTime() + (secondsPerDay * (daysInIter * remainingIterations)));
        };

        velocityText.blur(function() {
            var velocity = parseInt(velocityText.val(), 10),
                iterations = remainingIterations(velocity, remainingStoryPoints),
                expectedDate = expectedCompletionDateFor(lastIterEndDate, daysInIter, iterations),
                dateString = expectedDate.getFullYear() + '-' + (expectedDate.getMonth() + 1) + '-' + expectedDate.getDate();
            iterationsSpan.html(iterations);
            dateCalcText.val(dateString);
        });

        dateCalcText.blur(function() {
            var desiredEndDate = new Date(dateCalcText.val()),
                dayDiff = dateDiffInDays(lastIterEndDate, desiredEndDate),
                iterations = Math.ceil(dayDiff / daysInIter),
                requiredVelocity = remainingStoryPoints / iterations;
            iterationsSpan.html(iterations);
            velocityText.val(requiredVelocity);
        });

    } catch(err) {
        macroDebug.log(err);
    }
};
