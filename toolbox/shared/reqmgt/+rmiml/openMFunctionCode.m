function sid=openMFunctionCode(sid)


    if rmisl.isHarnessIdString(sid)

        sid=rmisl.harnessIdToEditorName(sid);
    end

    obj=Simulink.ID.getHandle(sid);
    if isa(obj,'double')
        eval(rmi.objinfo(obj));
        sfId=sf('Private','block2chart',obj);
        sf('Open',sfId);
    else
        sf('Open',obj.Id)
    end
end
