function out=guidlookup(modelH,guidStr)

    guidtable=get_param(modelH,'GUIDTable');
    if isempty(guidtable)
        isLocked=strcmp(get_param(modelH,'Lock'),'on');
        if isLocked
            hasActiveHarness=Simulink.harness.internal.hasActiveHarness(modelH);
            if hasActiveHarness
                Simulink.harness.internal.setBDLock(modelH,false);
            else
                set_param(modelH,'Lock','off');
            end
        end
        guidtable=reqmgt('guidBuild',modelH);
        if isLocked
            if hasActiveHarness
                Simulink.harness.internal.setBDLock(modelH,true);
            else
                set_param(modelH,'Lock','on');
            end
        end
    end

    if isempty(guidtable)||~isfield(guidtable,guidStr)
        out=[];
    else
        out=guidtable.(guidStr);
    end
end


