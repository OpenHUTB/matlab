function status=addunique(hCS,hBlk,family,name,value)




    if isa(hCS,'CoderTarget.SettingsController')
        hCS=hCS.getConfigSet();
    elseif ischar(hCS)
        hCS=getActiveConfigSet(hCS);
    else
        assert(isa(hCS,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

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


        arrvalue=unique(arrvalue,'stable');
        if isequal(length(arrvalue),1)
            arrvalue=arrvalue{1};
        end
        data.(family).(name)=arrvalue;
    end

    savedstate=get_param(hCS.getModel(),'Dirty');
    codertarget.resourcemanager.setAllResources(hCS,data);
    set_param(hCS.getModel(),'Dirty',savedstate);

    status=true;

end