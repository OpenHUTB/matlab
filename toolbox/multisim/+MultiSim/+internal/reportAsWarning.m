






function reportAsWarning(modelName,ME)

    warnState=warning('query','backtrace');
    oc=onCleanup(@()warning(warnState));
    warning off backtrace;
    msld=MSLDiagnostic(ME);
    msld.reportAsWarning(modelName,false);
end