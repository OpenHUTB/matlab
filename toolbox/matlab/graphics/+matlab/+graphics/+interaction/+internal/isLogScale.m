function is_log=isLogScale(hAxes)
    is_log=[strcmp(hAxes.XScale,'log');strcmp(hAxes.YScale,'log');strcmp(hAxes.ZScale,'log')];