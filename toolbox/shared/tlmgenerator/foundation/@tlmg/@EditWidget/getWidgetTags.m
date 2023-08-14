function tags=getWidgetTags(srcObj,propName)
    tags.editW=srcObj.genTag(propName);
    tags.labelW=[tags.editW,'_label'];
end
