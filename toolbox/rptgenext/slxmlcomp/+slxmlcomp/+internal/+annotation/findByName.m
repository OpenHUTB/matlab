function annotation=findByName(annotationInfo)




















    parentHandle=get_param(annotationInfo.ParentPath,'Handle');
    if numel(parentHandle)~=1||~ishandle(parentHandle)
        slxmlcomp.internal.error('reverseannotation:AnnotationNotFound');
    end


    annotation=find_system(parentHandle,...
    'FindAll','on',...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'type','Annotation',...
    'Name',annotationInfo.Name);

    if numel(annotation)<1||~ishandle(annotation(1))
        slxmlcomp.internal.error('reverseannotation:AnnotationNotFound');
    end
end

