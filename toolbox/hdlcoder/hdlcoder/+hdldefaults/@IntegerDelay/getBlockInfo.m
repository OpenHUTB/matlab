function[initVal,numDelays,hasExtEnable,resetnone,rtype,extrtype,rambased,isVarDelay,delayLimit]=getBlockInfo(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        initVal=sysObjHandle.InitialConditions;
        numDelays=sysObjHandle.Length;
        hasExtEnable=false;
        resetnone=false;
        rtype='default';
        extrtype='None';
        rambased='off';
        isVarDelay=false;
        delayLimit=-1;


    else

        slbh=hC.SimulinkHandle;
        initVal=this.getInitialValue(hC,slbh);

        try
            hasExtEnable=strcmpi(get_param(slbh,'ShowEnablePort'),'on');
        catch
            hasExtEnable=false;
        end

        resetnone=false;
        rtype=this.getImplParams('ResetType');
        extrtype=get_param(slbh,'ExternalReset');
        rambased=this.getImplParams('UseRAM');

        isVarDelay=strcmpi(get_param(slbh,'DelayLengthSource'),'Input port');
        delayLimit=double(hdlslResolve('DelayLengthUpperLimit',slbh));
        if(isVarDelay)
            numDelays=delayLimit;
        else
            numDelays=getDelayLength(slbh);
        end

    end

end

function numdelays=getDelayLength(slbh)
    numdelays=hdlslResolve('NumDelays',slbh);
end
