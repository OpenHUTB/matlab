function showAnnotationsInLBRF(cbinfo,action)
    if isempty(SLStudio.Utils.getSelectedAnnotationHandles(cbinfo))
        action.enabled=false;
        action.selected=false;
    else
        isSelected=loc_ShowInLibBrowserCheck(cbinfo,'on');
        action.selected=isSelected;
    end
end

function isSelected=loc_ShowInLibBrowserCheck(cbinfo,mode)
    isSelected=false;
    attribute_count=0;
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    for i=1:length(noteHandles)
        note=noteHandles(i);
        if strcmp(get_param(note,'ShowInLibBrowser'),mode)
            attribute_count=attribute_count+1;
        else
            attribute_count=attribute_count-1;
        end
    end
    if attribute_count>0
        isSelected=true;
    end
end
