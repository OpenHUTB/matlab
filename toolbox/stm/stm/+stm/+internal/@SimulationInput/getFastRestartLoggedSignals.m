



function setDiff=getFastRestartLoggedSignals(allLoggedSignals,fastRestartLoggedSignals)
    all=convertToFormatWhichSupportsSetDiff(allLoggedSignals);
    fastRestart=convertToFormatWhichSupportsSetDiff(fastRestartLoggedSignals);
    setDiff=setdiff(all,fastRestart);
    setDiff=allLoggedSignals(ismember(all,setDiff));
end


function str=convertToFormatWhichSupportsSetDiff(signalLoggingInfo)
    bp=cellfun(@convertToCell,{signalLoggingInfo.BlockPath},'Uniform',false);
    bpStr=cellfun(@string,bp,'Uniform',false);

    joined=cellfun(@(s)s.join('|'),bpStr);

    str=joined+"|"+[signalLoggingInfo.OutputPortIndex];
end
