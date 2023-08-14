function status=add(hBlk,family,name,value)





    model=codertarget.utils.getModelForBlock(hBlk);
    hCS=getActiveConfigSet(model);
    data=codertarget.resourcemanager.getAllResources(hCS);

    if~codertarget.resourcemanager.isregistered(hBlk,family,name)
        status=codertarget.resourcemanager.set(hBlk,family,name,value);
        return
    else
        curvalue=data.(family).(name);
        if~iscell(curvalue)
            arrvalue{1}=curvalue;
        else
            arrvalue=curvalue;
        end
        arrvalue{end+1}=value;
        data.(family).(name)=arrvalue;
    end

    savedstate=get_param(hCS.getModel(),'Dirty');
    codertarget.resourcemanager.setAllResources(hCS,data);
    set_param(hCS.getModel(),'Dirty',savedstate);

    status=true;

end