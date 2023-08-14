function v=validatePortDatatypes(this,hC)


















    v=hdlvalidatestruct;






    if isa(hC,'hdlcoder.sysobj_comp')
        slbh=-1;
    else
        slbh=hC.SimulinkHandle;
    end


    numIn=hC.NumberOfPirInputPorts;










    try
        hasEnablePort=strcmpi(get_param(slbh,'ShowEnablePort'),'on');
    catch
        hasEnablePort=false;
    end

    if hasEnablePort
        enDataType=hdlsignalsltype(hC.PirInputPorts(numIn).Signal);
        if~strcmpi(enDataType,'boolean')&&~strcmpi(enDataType,'ufix1')
            v=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:enablePortType'));
        end
    end

    try
        hasResetPort=~strcmpi(get_param(slbh,'ExternalReset'),'None');
    catch
        hasResetPort=false;
    end


    if hasResetPort
        rstDataType=hdlsignalsltype(hC.PirInputPorts(numIn).Signal);
        if~strcmpi(rstDataType,'boolean')&&~strcmpi(rstDataType,'ufix1')
            v=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:resetPortType'));
        end
    end









