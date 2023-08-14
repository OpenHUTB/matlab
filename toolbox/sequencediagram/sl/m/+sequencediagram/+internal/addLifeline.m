
function addLifeline(fullPath,sequencediagramName)







    try
        load_system(fullPath);
        modelName=bdroot(fullPath);
    catch ME
        ME.throwAsCaller();
    end

    sequencediagram.internal.validateSubdomain(modelName);

    name=get_param(fullPath,'Name');

    parentPath=get_param(fullPath,'Parent');
    parentType=get_param(parentPath,'Type');



    if~strcmp(parentType,'block')
        parentPath='';
    end

    builtin('_add_lifeline',sequencediagramName,name,fullPath,parentPath);
end

