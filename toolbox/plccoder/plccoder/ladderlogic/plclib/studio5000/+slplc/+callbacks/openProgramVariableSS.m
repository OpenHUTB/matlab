function openProgramVariableSS(block)



    pouType=slplc.utils.getParam(block,'PLCPOUType');
    if strcmpi(pouType,'Program')
        varSSBlockPath=slplc.utils.getInternalBlockPath(block,'VariableSS');
        open_system(varSSBlockPath);
        close_system(block);
    else

        updateVarSS(block)
    end
end

function updateVarSS(varSSBlock)

    if bdIsLibrary(bdroot(varSSBlock))
        open_system(varSSBlock,'mask');
        return
    end
    pouBlock=slplc.utils.getParentPOU(varSSBlock);
    if~isempty(pouBlock)&&...
        strcmpi(get_param(bdroot(pouBlock),'SimulationStatus'),'stopped')
        slplc.utils.updateVariableList(pouBlock);
        slplc.utils.updateDataBlocks(pouBlock);
        slplc.utils.refreshPOUVarSS(pouBlock);
    end
    open_system(varSSBlock,'mask');
end
