function status=increment(hBlk,family,name)





    model=codertarget.utils.getModelForBlock(hBlk);
    hCS=getActiveConfigSet(model);
    data=codertarget.resourcemanager.getAllResources(hCS);

    if~codertarget.resourcemanager.isregistered(hBlk,family,name)
        status=codertarget.resourcemanager.set(hBlk,family,name,1);
        return
    else
        curvalue=data.(family).(name);
        assert(~iscell(curvalue));
        data.(family).(name)=curvalue+1;
    end

    savedstate=get_param(hCS.getModel(),'Dirty');
    codertarget.resourcemanager.setAllResources(hCS,data);
    set_param(hCS.getModel(),'Dirty',savedstate);

    status=true;

end