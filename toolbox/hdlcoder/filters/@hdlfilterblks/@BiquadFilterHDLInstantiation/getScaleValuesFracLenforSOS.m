function scalebp=getScaleValuesFracLenforSOS(this,hC,scaleValues,csize)




    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if~isSysObj
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        optimizeScalevalues=strcmpi(block.optimizeScaleValues,'on');
    else
        sysObjHandle=hC.getSysObjImpl;
        optimizeScalevalues=sysObjHandle.OptimizeUnityScaleValues;
    end

    if optimizeScalevalues
        indx_unityscales=scaleValues==1;
        if all(indx_unityscales)

            svforBPcalc=scaleValues;
        else

            svforBPcalc=scaleValues(scaleValues~=1);
        end
    end
    scalebp=getBestPrecFracLength(this,...
    svforBPcalc,csize,1);



