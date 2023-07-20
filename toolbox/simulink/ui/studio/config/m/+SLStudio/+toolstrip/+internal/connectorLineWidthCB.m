



function connectorLineWidthCB(userdata,cbinfo)

    annotation=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidAnnotation(annotation)

        editor=cbinfo.studio.App.getActiveEditor;
        undoId='Simulink:studio:SetConnectorWidthCommand';
        editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setConnectorWidth,{annotation,userdata,editor});
    end
end

function loc_setConnectorWidth(annotation,widthStr,editor)
    width=str2double(widthStr);
    diagram=editor.getDiagram;
    model=diagram.model;
    rootDeviant=model.asDeviant(model.getRootDeviant);
    annotationRD=annotation.asDeviant(rootDeviant);

    rootDeviant.beginTransaction;


    for j=1:annotationRD.connector.size()
        connector=annotationRD.connector.at(j);
        connector.strokeWidth=width;
    end

    rootDeviant.commitTransaction;
end
