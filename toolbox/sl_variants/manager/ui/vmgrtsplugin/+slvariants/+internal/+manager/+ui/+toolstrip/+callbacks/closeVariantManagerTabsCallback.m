function closeVariantManagerTabsCallback(userdata,cbinfo)







    modelHandle=cbinfo.Context.Object.App.ModelHandle;
    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);

    cbinfo.Context.Object.TypeChain={userdata};
    toolStrip=vmStudioHandle.getToolStrip;

    slvariants.internal.manager.ui.utils.toolstripTabChangeCB(toolStrip.ActiveTab,modelHandle);
end


