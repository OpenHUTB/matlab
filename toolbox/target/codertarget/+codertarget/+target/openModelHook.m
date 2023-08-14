function outHardwareBoard=openModelHook(aHardwareBoard)
    allHWNames=codertarget.targethardware.getRegisteredTargetHardwareNames('ert');
    if ismember(aHardwareBoard,allHWNames)
        outHardwareBoard=aHardwareBoard;
    else
        allHWWithAliases=codertarget.targethardware.getRegisteredTargetHardware;
        if isempty(allHWWithAliases)
            outHardwareBoard=aHardwareBoard;
        else
            idx=cellfun(@(x)~isempty(x),{allHWWithAliases.Aliases});
            allHWWithAliases=allHWWithAliases(idx);
            if ismember(aHardwareBoard,[allHWWithAliases.Aliases])
                idx=find(cellfun(@(x)~isempty(find(ismember(x,aHardwareBoard),1)),{allHWWithAliases.Aliases}));
                if isempty(idx)
                    outHardwareBoard=aHardwareBoard;
                else
                    outHardwareBoard=allHWWithAliases(idx(1)).Name;
                end
            else
                outHardwareBoard=aHardwareBoard;
            end
        end
    end
end