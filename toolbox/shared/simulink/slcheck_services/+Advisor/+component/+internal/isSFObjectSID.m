function[status,libBDName]=isSFObjectSID(sid)



    objIn=Simulink.ID.getHandle(sid);
    if isa(objIn,'double')
        objIn=get_param(objIn,'Object');
    end
    libBDName='';

    if isa(objIn,'Stateflow.Object')
        status=true;
    elseif slprivate('is_stateflow_based_block',objIn.Handle)
        status=true;
    else
        status=false;
    end

    if status
        bdName=Simulink.ID.getModel(sid);

        if bdIsLibrary(bdName)
            libBDName=bdName;
        end
    end
end

