function isEnabled=isLogDataHistoryEnabled(hSource,~)






    isEnabled=SSC.Logging.isLogNameEnabled(hSource,[])&&...
    ~strcmpi(hSource.SimscapeLogLimitData,'off');

end
