function handleEditorChanged(obj,cbinfo)


    if~isvalid(obj)
        return;
    end

    mdl=obj.model;
    bdh=get_param(mdl,'handle');
    if obj.preModel~=bdh
        obj.preModel=bdh;
        obj.switchModel(bdh);
    end