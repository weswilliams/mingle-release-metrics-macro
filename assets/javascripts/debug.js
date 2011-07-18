releaseMetrics.macroDebug = function(enabled, out) {
    var that = {};
    that.log = function(msg) {
        if (!enabled) {
            return;
        }
        out.append(new Date() + ' - ' + msg + '<br/>');
    };
    that.log('debug log starting');
    return that;
};

