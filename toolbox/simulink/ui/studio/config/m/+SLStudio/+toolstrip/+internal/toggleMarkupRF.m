



function toggleMarkupRF(cbinfo,action)
    blockDiagram=cbinfo.model.handle;

    visible=SLStudio.MarkupStyleSheet.isMarkupVisible(blockDiagram);

    action.selected=visible;
end
