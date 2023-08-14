function highlightMapping(model,studio,data)




    return;

    individualMapping=false;

    if isfield(data,'StorageClassSource')
        if strcmp(data.StorageClassSource,'Individual')
            individualMapping=true;
        end
    end

    if individualMapping
        category=data.ModelElemCategory;
        key=Simulink.ID.getHandle(data.sid);
    else
        category='Defaults';
        key=data.ModelElemCategory;
    end


    mapObj=simulinkcoder.internal.util.getMappingObject(model,category,key);


    cmp=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');


    cmp.highlight(mapObj);
