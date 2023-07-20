function status=unregister(hBlk,family,name)





    model=codertarget.utils.getModelForBlock(hBlk);
    hCS=getActiveConfigSet(model);
    data=codertarget.resourcemanager.getAllResources(hCS);

    if isfield(data,family)
        if isfield(data.(family),name)
            info=rmfield(data.(family),name);
            data.(family)=info;
            if isempty(fields(data.(family)))
                data=rmfield(data,family);
            end
        else
            status=false;
            return
        end
    else
        status=false;
        return
    end


    savedstate=get_param(hCS.getModel(),'Dirty');
    codertarget.resourcemanager.setAllResources(hCS,data);
    set_param(hCS.getModel(),'Dirty',savedstate);

    status=true;

end