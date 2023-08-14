function v=validateBlock(this,hC)


    v=hdlvalidatestruct;

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        resetPort=sysObjHandle.ResetInputPort;

        if resetPort
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:DSPDelay:validateSysObj:controlportunsupported'));
        end








    else
        bfp=hC.SimulinkHandle;
        frameDelay=strcmp(get_param(bfp,'dly_unit'),'Frames');
        resetPort=~strcmp(get_param(bfp,'reset_popup'),'None');

        if frameDelay
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:DSPDelay:validateBlock:framedelayunsupported'));
        end
        if resetPort
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:DSPDelay:validateBlock:controlportunsupported'));
        end

        blockInfo=getBlockInfo(this,hC);

        if blockInfo.rambased&&~all(blockInfo.initVal==0)
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:DSPDelay:validateBlock:RAMRequiresZeroIC'));
        end

    end

end
