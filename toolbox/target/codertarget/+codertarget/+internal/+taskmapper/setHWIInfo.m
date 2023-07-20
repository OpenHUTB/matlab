function setHWIInfo(hObj,val)




    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    else

        hCS=getActiveConfigSet(hObj);
    end

    assert(hCS.isValidParam('CoderTargetData'),'No CoderTargetData');

    data=get_param(hCS,'CoderTargetData');

    data.TaskMap=val;
    set_param(hCS,'CoderTargetData',data);
end