



function connectorLineWidthRF(cbinfo,action)
    action.enabled=false;
    clickedAnnotation=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidAnnotation(clickedAnnotation)&&~SLStudio.toolstrip.internal.objIsImage(clickedAnnotation)
        if clickedAnnotation.edge.begin~=clickedAnnotation.edge.end
            action.enabled=true;
        end
    end
end
