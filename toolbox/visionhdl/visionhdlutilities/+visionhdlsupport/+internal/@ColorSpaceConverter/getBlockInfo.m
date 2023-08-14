function blockInfo=getBlockInfo(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        InArg1=sysObjHandle.Conversion;
        InArg2=sysObjHandle.ConversionStandard;
        InArg3=sysObjHandle.ScanningStandard;
    else
        bfp=hC.Simulinkhandle;
        InArg1=get_param(bfp,'Conversion');
        InArg2=get_param(bfp,'ConversionStandard');
        InArg3=get_param(bfp,'ScanningStandard');
    end
    S=visionhdl.ColorSpaceConverter.getWeightOffset(InArg1,InArg2,InArg3);
    blockInfo.A=S.transformA;
    blockInfo.b=S.offsetb;
    blockInfo.MinMaxLuma=S.MinMaxLuma;
    blockInfo.MinMaxChroma=S.MinMaxChroma;
    blockInfo.Conversion=InArg1;



    gainParam=this.getImplParams('ConstMultiplierOptimization');
    OptimMode=0;
    if~isempty(gainParam)
        if strcmpi(gainParam,'none')
            OptimMode=0;
        elseif strcmpi(gainParam,'csd')
            OptimMode=1;
        elseif strcmpi(gainParam,'fcsd')
            OptimMode=2;
        elseif strcmpi(gainParam,'auto')
            OptimMode=3;
        end
    end
    blockInfo.OptimM=OptimMode;


