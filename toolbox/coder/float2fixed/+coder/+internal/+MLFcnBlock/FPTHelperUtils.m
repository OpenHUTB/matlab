classdef FPTHelperUtils
    properties(Constant)
        FPT_ALERT_LVL_RED='red';
        FPT_ALERT_LVL_YELLOW='yellow';
    end
    methods(Static)
        function SetResultAlertLevel(results,alertLevel)
            for ii=1:length(results)
                result=results(ii);
                result.setAlert(alertLevel);
            end
        end
    end
end