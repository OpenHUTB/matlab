function FuzzyLogicControllerBlock(obj)
    flcBlocks=obj.findLibraryLinksTo(sprintf('fuzblock/Fuzzy Logic \nController'));

    if isR2017aOrEarlier(obj.ver)
        params={...
        {'OutputSampleNumber',101,errorID('flcMaskWarn_IncompatibleSampleNumber')},...
        {'DataType','double',errorID('flcMaskWarn_IncompatibleDataType')},...
        {'FuzzifiedInputs','off',errorID('flcMaskWarn_IncompatibleOutportFI')},...
        {'RuleFiringStrengths','off',errorID('flcMaskWarn_IncompatibleOutportRFS')},...
        {'RuleOutputs','off',errorID('flcMaskWarn_IncompatibleOutportFSO')},...
        {'AggregatedOutputs','off',errorID('flcMaskWarn_IncompatibleOutportAO')}...
        };

        for i=1:numel(flcBlocks)
            blk=flcBlocks{i};
            cellfun(@(x)throwWarning(blk,x{1},x{2},x{3}),params);
        end
    end

end

function errID=errorID(key)
    errID=['fuzzy:dialogs:',key];
end

function throwWarning(blk,param,refValue,errorID)
    paramValue=get_param(blk,param);
    try
        resolvedValue=slResolve(paramValue,blk);
    catch me %#ok<NASGU>
        resolvedValue=paramValue;
    end

    if~isequal(resolvedValue,refValue)
        MSLDiagnostic(errorID).reportAsWarning;
    end
end
