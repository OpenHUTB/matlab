



function annotationMarkupRF(userdata,cbinfo,action)
    clickedAnnotation=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~SLStudio.Utils.objectIsValidAnnotation(clickedAnnotation)
        action.enabled=false;
    else
        action.enabled=true;
        action.selected=strcmp(clickedAnnotation.category,userdata);


        if strcmp(userdata,'markup')&&~SLStudio.MarkupStyleSheet.isMarkupVisible(cbinfo.model.handle)
            action.description='simulink_ui:studio:resources:ObjectTypeHiddenMarkupActionDescription';
        end
    end
end
