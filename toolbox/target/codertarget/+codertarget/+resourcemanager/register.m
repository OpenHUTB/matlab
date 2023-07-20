function status=register(hBlk,family,name,value)





    model=codertarget.utils.getModelForBlock(hBlk);
    hCS=getActiveConfigSet(model);
    data=codertarget.resourcemanager.getAllResources(hCS);

    if isfield(data,family)
        if isfield(data.(family),name)
            status=false;
            return
        else
            data.(family).(name)=value;
        end
    else
        data.(family)=[];
        data.(family).(name)=value;
    end

    savedstate=get_param(hCS.getModel(),'Dirty');
    codertarget.resourcemanager.setAllResources(hCS,data);
    set_param(hCS.getModel(),'Dirty',savedstate);

    status=true;

end