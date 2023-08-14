function bool=getEnableSendToObserver(selection,modelName)
    import sltest.internal.menus.isBlockCompatibleForSendToObserver;
    bool=false;
    if~isscalar(selection)||~isa(selection,'Simulink.Block')||...
        (~isprop(selection,'portHandles')&&~isprop(selection,'PortHandles'))||bdIsLibrary(modelName)
        return;
    end

    bool=isBlockCompatibleForSendToObserver(selection.portHandles,selection.BlockType);
end
