



function annotationMarkupCB(userdata,cbinfo)

    if cbinfo.EventData

        annotation=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidAnnotation(annotation)

            if~strcmp(annotation.category,userdata)

                editor=cbinfo.studio.App.getActiveEditor;
                undoId='Simulink:studio:SLChangeMarkupCategory';
                editor.createMCommand(undoId,DAStudio.message(undoId),@loc_changeAnnotationCategory,{annotation,editor});
            end
        end
    end
end

function loc_changeAnnotationCategory(annotation,editor)
    diagram=editor.getDiagram;
    model=diagram.model;
    rootDeviant=model.asDeviant(model.getRootDeviant);
    annotationRD=annotation.asDeviant(rootDeviant);







    rootDeviant.beginTransaction;


    if strcmp(annotationRD.category,'markup')
        annotationRD.category='model';


        for j=1:annotationRD.connector.size()
            connector=annotationRD.connector.at(j);
            otherEnd=connector.srcElement;
            if connector.srcElement==annotationRD
                otherEnd=connector.dstElement;
            end
            if strcmp(class(otherEnd),'SLM3I.Annotation')
                if strcmp(otherEnd.category,'model')

                    connector.category='model';
                end
            else

                connector.category='model';
            end
        end


    else
        annotationRD.category='markup';


        for j=1:annotationRD.connector.size()
            connector=annotationRD.connector.at(j);
            connector.category='markup';
        end
    end

    rootDeviant.commitTransaction;
end
