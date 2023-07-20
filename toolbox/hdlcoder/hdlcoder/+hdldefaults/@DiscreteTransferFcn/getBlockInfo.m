function[tfInfo,nfpOptions]=getBlockInfo(this,hC)






























    slbh=hC.SimulinkHandle;
    hInSignals=hC.PirInputSignals;
    hFirstIn=hInSignals(1);
    hInType=hFirstIn.Type.getLeafType;

    tfInfo.blockname=get_param(slbh,'Name');
    tfInfo.blockpath=get_param(slbh,'Parent');

    tfInfo.Numerator=hdlslResolve('Numerator',slbh);
    tfInfo.Denominator=hdlslResolve('Denominator',slbh);

    tfInfo.InputProcessing=get_param(slbh,'InputProcessing');
    tfInfo.InitialStates=hdlslResolve('InitialStates',slbh);
    tfInfo.SampleTime=get_param(slbh,'SampleTime');
    tfInfo.a0EqualsOne=get_param(slbh,'a0EqualsOne');
    tfInfo.NumCoefMin=slResolve(get_param(slbh,'NumCoefMin'),slbh,'expression');
    tfInfo.NumCoefMax=slResolve(get_param(slbh,'NumCoefMax'),slbh,'expression');
    tfInfo.DenCoefMin=slResolve(get_param(slbh,'DenCoefMin'),slbh,'expression');
    tfInfo.DenCoefMax=slResolve(get_param(slbh,'DenCoefMax'),slbh,'expression');
    tfInfo.OutMin=slResolve(get_param(slbh,'OutMin'),slbh,'expression');
    tfInfo.OutMax=slResolve(get_param(slbh,'OutMax'),slbh,'expression');

    if hInType.isFloatType()

        if strncmp(get_param(slbh,'StateDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'NumCoefDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'DenCoefDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'NumProductDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'NumCoefDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'DenProductDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'NumAccumDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'DenAccumDataTypeStr'),'Inherit',7)&&...
            strncmp(get_param(slbh,'OutDataTypeStr'),'Inherit',7)

            if hInType.isSingleType
                floatTypeStr='single';
            else
                floatTypeStr='double';
            end
            tfInfo.StateDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.NumCoefDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.DenCoefDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.NumProductDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.DenProductDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.NumAccumDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.DenAccumDataType=pirelab.convertSLType2PirType(floatTypeStr);
            tfInfo.OutDataType=pirelab.convertSLType2PirType(floatTypeStr);
        else


            error(message('hdlcoder:validate:InconsistentDTF'));
        end
    else
        tfInfo.StateDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'StateDataTypeStr'),slbh);
        tfInfo.NumCoefDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'NumCoefDataTypeStr'),slbh);
        tfInfo.DenCoefDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'DenCoefDataTypeStr'),slbh);
        tfInfo.NumProductDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'NumProductDataTypeStr'),slbh);
        tfInfo.DenProductDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'DenProductDataTypeStr'),slbh);
        tfInfo.NumAccumDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'NumAccumDataTypeStr'),slbh);
        tfInfo.DenAccumDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'DenAccumDataTypeStr'),slbh);
        tfInfo.OutDataType=pirelab.convertSLUserType2PirType...
        (get_param(slbh,'OutDataTypeStr'),slbh);

        tfInfo.StateDataType=safe_dt_assign1(tfInfo.StateDataType,hInType);
        tfInfo.NumCoefDataType=safe_dt_assign0(tfInfo.NumCoefDataType);
        tfInfo.DenCoefDataType=safe_dt_assign0(tfInfo.DenCoefDataType);
        tfInfo.NumProductDataType=safe_dt_assign1(tfInfo.NumProductDataType,hInType);
        tfInfo.DenProductDataType=safe_dt_assign1(tfInfo.DenProductDataType,hInType);
        tfInfo.NumAccumDataType=safe_dt_assign2(tfInfo.NumAccumDataType,...
        hInType,tfInfo.NumProductDataType);
        tfInfo.DenAccumDataType=safe_dt_assign2(tfInfo.DenAccumDataType,...
        hInType,tfInfo.DenProductDataType);
        tfInfo.OutDataType=safe_dt_assign1(tfInfo.OutDataType,hInType);
    end


    tfInfo.rndMode=get_param(slbh,'RndMeth');
    tfInfo.SaturateOnIntegerOverflow=...
    get_param(slbh,'SaturateOnIntegerOverflow');
    if strcmp(tfInfo.SaturateOnIntegerOverflow,'on')
        tfInfo.satMode='Saturate';
    else
        tfInfo.satMode='Wrap';
    end
    tfInfo.convMode='RWV';
    tfInfo.gainMode=1;
    tfInfo.resetnone=false;

    constMultiplierOptimParam=this.getImplParams('ConstMultiplierOptimization');
    tfInfo.constMultiplierOptimMode=0;
    if~isempty(constMultiplierOptimParam)
        if strcmpi(constMultiplierOptimParam,'none')
            tfInfo.constMultiplierOptimMode=0;
        elseif strcmpi(constMultiplierOptimParam,'csd')
            tfInfo.constMultiplierOptimMode=1;
        elseif strcmpi(constMultiplierOptimParam,'fcsd')
            tfInfo.constMultiplierOptimMode=2;
        elseif strcmpi(constMultiplierOptimParam,'auto')
            tfInfo.constMultiplierOptimMode=3;
        end
    end


    tfInfo.constrainedOutputPipeline=...
    this.getImplParams('ConstrainedOutputPipeline');

    nfpOptions=getNFPBlockInfo(this);
end



function y=safe_dt_assign0(infoDT)
    if~isempty(infoDT.pirtype)
        y=infoDT.pirtype;
    else
        error(message('hdlcoder:validate:unsupporteddatatype'));
    end
end

function y=safe_dt_assign1(infoDT,hInType)
    if~isempty(infoDT.pirtype)
        y=infoDT.pirtype;
    else
        if strcmp(infoDT.inheritance,'input')
            y=hInType;
        else
            error(message('hdlcoder:validate:UnsupportedInheritance',...
            'internal'));
        end
    end
end

function y=safe_dt_assign2(infoDT,hInType,productType)
    if~isempty(infoDT.pirtype)
        y=infoDT.pirtype;
    else
        if strcmp(infoDT.inheritance,'input')
            y=hInType;
        elseif strcmp(infoDT.inheritance,'Inherit: Same as product output')
            y=productType;
        else
            error(message('hdlcoder:validate:UnsupportedInheritance',...
            'internal'));
        end
    end
end


