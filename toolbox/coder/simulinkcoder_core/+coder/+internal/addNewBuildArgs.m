function addNewBuildArgs(lBuildInfo,lRTWBuildArgs_before,lRTWBuildArgs_after)





    groupBuildArg='BUILD_ARG';

    argsAsCellArrayAfter=...
    rtwprivate('getRTWBuildArgTokens',lRTWBuildArgs_after);
    argsAsCellArrayBefore=...
    rtwprivate('getRTWBuildArgTokens',lRTWBuildArgs_before);
    argsAsCellArrayDiff=...
    setdiff(argsAsCellArrayAfter,argsAsCellArrayBefore,'stable');
    bArgsBefore=regexprep(argsAsCellArrayBefore,'^([^=]+)=.*','$1');
    bArgsDiff=regexprep(argsAsCellArrayDiff,'^([^=]+)=.*','$1');
    bArgValsDiff=regexprep(argsAsCellArrayDiff,'^[^=]+=?(.*)$','$1');
    bArgGroupsDiff(1:length(bArgsDiff))={groupBuildArg};


    [~,bArgsChangedIdx]=intersect(bArgsBefore,bArgsDiff);
    [~,bArgsRemovedIdx]=setdiff(argsAsCellArrayBefore,argsAsCellArrayAfter);
    if~isempty(bArgsChangedIdx)||~isempty(bArgsRemovedIdx)
        DAStudio.error('RTW:buildProcess:InvalidRTWBuildArgsUpdate',...
        lRTWBuildArgs_before,lRTWBuildArgs_after);
    end

    lBuildInfo.addBuildArgs(bArgsDiff,bArgValsDiff,bArgGroupsDiff);
