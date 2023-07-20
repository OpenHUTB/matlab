function[inputmode,rndMode,satMode,dataPortOrder,portIndices,...
    dataPortForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle]=getBlockInfo(this,hC)



    if~hC.PirOutputSignals(1).Type.isArrayType&&...
        hC.PirInputSignals(2).Type.isArrayType
        inputmode=0;
    elseif~hC.PirInputSignals(1).Type.isArrayType
        inputmode=1;
    else
        inputmode=2;
    end

    slbh=hC.SimulinkHandle;
    dataPortOrder=get_param(slbh,'DataPortOrder');
    numInputs=slResolve(get_param(slbh,'Inputs'),slbh);
    obj=get_param(slbh,'Object');
    propValues=obj.getPropAllowedValues('DataPortOrder');
    if strcmp(dataPortOrder,propValues{3})
        portIndices=slResolve(obj.DataPortIndices,slbh);
    else
        portIndices=[];
    end

    dataPortForDefault=get_param(slbh,'DataPortForDefault');

    codingStyle=getImplParams(this,'CodingStyle');

    rndMode=get_param(slbh,'RndMeth');
    sat=strcmp(get_param(slbh,'SaturateOnIntegerOverflow'),'on');
    if sat==1
        satMode='Saturate';
    else
        satMode='Wrap';
    end

    nfpOptions=getNFPBlockInfo(this);


    propValues1=obj.getPropAllowedValues('DiagnosticForDefault');
    diagForDefaultErr=strcmp(get_param(slbh,'DiagnosticForDefault'),propValues1{3});
end
