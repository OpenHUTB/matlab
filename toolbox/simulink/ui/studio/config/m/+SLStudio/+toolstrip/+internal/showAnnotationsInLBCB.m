function showAnnotationsInLBCB(cbinfo)
    value=cbinfo.EventData;
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    SLStudio.Utils.SetAnnotationParam(noteHandles,'ShowInLibBrowser',double(value));



    if strcmpi(value,'on')
        h=cbinfo.studio.App.blockDiagramHandle;
        if strcmpi(get_param(h,'BlockDiagramType'),'Library')
            set_param(h,'EnableLBRepository','on');
        end
    end
end