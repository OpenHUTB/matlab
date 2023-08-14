function RemoveHighlighting(bdHandleOrModelName)





    mdlObj=get_param(bdHandleOrModelName,'Object');
    if isa(mdlObj,'Simulink.BlockDiagram')
        bdHandle=get_param(bdHandleOrModelName,'handle');
    else
        return
    end

    slprivate('remove_hilite',bdHandle);

    if bdIsLibrary(bdHandle)
        slprivate('hilite_option','none');
    end

    SLM3I.SLDomain.removeBdFromHighlightMode(bdHandle);

    Simulink.STOSpreadSheet.SortedOrder.NVBlockReducedDisplaySource.RemoveHighlight(bdHandle);


    Simulink.Structure.HiliteTool.AppManager.removeAdvancedHighlighting(bdHandle);

    sltrace(bdHandle,'clear');

    SLStudio.EmphasisStyleSheet.removeStyler(bdHandle);

    SLStudio.Utils.internal.runRemoveHighlightCallbacks(bdHandle);
end
