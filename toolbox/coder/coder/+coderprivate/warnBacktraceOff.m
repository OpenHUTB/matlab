function warnBacktraceOff(msg)



    warnState=warning('backtrace','off');
    warning(msg);
    warning(warnState);
end