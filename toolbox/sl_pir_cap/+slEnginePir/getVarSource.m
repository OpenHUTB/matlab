

function srcString=getVarSource(aTrgHandle,aVarName)
    srcString=[''];
    varUsage=Simulink.findVars(getfullname(aTrgHandle),'SearchMethod','cached','Name',aVarName);
    if~isempty(varUsage)
        srcString=['[',varUsage.SourceType,']',varUsage.Source];
    end
end