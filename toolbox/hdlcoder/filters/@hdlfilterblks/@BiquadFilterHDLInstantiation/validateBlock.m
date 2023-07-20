function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        sysObjHandle=hC.getSysObjImpl;
        optimizeScaleValues=sysObjHandle.OptimizeUnityScaleValues;
        filterSourceDialog=strcmpi(sysObjHandle.SOSMatrixSource,'Property');
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        optimizeScaleValues=strcmp(block.optimizeScaleValues,'on');
        filterSourceDialog=strcmp(block.FilterSource,'Dialog parameters');








    end


    ip=hC.PirInputPorts(1).Signal;
    op=hC.PirOutputPorts(1).Signal;






    if~optimizeScaleValues&&filterSourceDialog
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:biquad:validate:optimizeSVunchecked'));
    end

    if~isSysObj&&strcmpi(block.FilterSource,'Filter object')
        Hd=this.hdlslResolve('dfiltObjectName',bfp);

        if isa(block.UserData.filter,'dsp.BiquadFilter')
            OptimizeScaleValues=Hd.OptimizeUnityScaleValues;
        else
            OptimizeScaleValues=Hd.OptimizeScaleValues;
        end

        if~OptimizeScaleValues
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:biquad:validate:optimizeSVuncheckedDfilt'));
        end
    end


    if any([v.Status])
        return;
    end


    v=[v,validateInitialCondition(this,hC)];






    v=[v,validateFilterImplParams(this,hC)];


