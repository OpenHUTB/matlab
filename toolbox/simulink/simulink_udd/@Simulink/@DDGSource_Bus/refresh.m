function refresh(this,dlg,rehashCache)




    block=dlg.getDialogSource.getBlock;
    if~block.isHierarchyReadonly
        forceRefresh=rehashCache&&~block.isHierarchyReadonly;
        hierarchy=getCachedSignalHierarchy(this,block,forceRefresh);
        block.UserData.BlockHandles=getBlockHandles(this,hierarchy);
        this.refresh_hook(dlg,hierarchy,forceRefresh);
    end

end
