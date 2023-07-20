function annotation=find(annotationInfo)






















    annotation=slxmlcomp.internal.annotation.findBySID(annotationInfo);
    if~isempty(annotation)
        return
    end


    annotations=slxmlcomp.internal.annotation.findByName(annotationInfo);

    numAnnotations=numel(annotations);
    if numAnnotations==1
        annotation=annotations;
        return
    end




    if strlength(annotationInfo.Name)>0
        slxmlcomp.internal.error('reverseannotation:AnnotationNotFound');
    end
end


