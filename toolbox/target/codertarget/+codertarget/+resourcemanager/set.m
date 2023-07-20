function status=set(hBlk,family,name,value)





    model=codertarget.utils.getModelForBlock(hBlk);
    hCS=getActiveConfigSet(model);
    data=codertarget.resourcemanager.getAllResources(hCS);

    if~codertarget.resourcemanager.isregistered(hBlk,family,name)
        status=codertarget.resourcemanager.register(hBlk,family,name,value);
        return
    else
        data.(family).(name)=value;
    end

    savedstate=get_param(hCS.getModel(),'Dirty');
    codertarget.resourcemanager.setAllResources(hCS,data);
    set_param(hCS.getModel(),'Dirty',savedstate);

    status=true;

end