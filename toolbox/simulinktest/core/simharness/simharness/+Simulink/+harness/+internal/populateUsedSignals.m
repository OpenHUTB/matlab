function usedSignals=populateUsedSignals(InputPortInfo,usedSignals)
    if isstruct(InputPortInfo)&&isfield(InputPortInfo,'Used')
        usedSignals{end+1}=InputPortInfo.Used;
    elseif iscell(InputPortInfo)
        thisUsedSignals={};
        for i=1:length(InputPortInfo)
            thisUsedSignals=Simulink.harness.internal.populateUsedSignals(InputPortInfo{i},thisUsedSignals);
        end
        usedSignals{end+1}=thisUsedSignals;
    end
end