function[cval,vectorParams1D,TunableParamStr,ConstBusName,ConstBusType]...
    =getBlockInfo(this,hC)


    [cval,vectorParams1D,TunableParamStr,~,isConstBlock]=...
    this.getBlockDialogValue(hC.SImulinkHandle);
    outType=hC.PirOutputSignals(1).Type;

    if isConstBlock&&(outType.isRecordType||outType.isArrayOfRecords)
        slbh=hC.SimulinkHandle;
        ConstBusName=get_param(slbh,'Value');
        ConstBusType=get_param(slbh,'OutDataTypeStr');
    else
        ConstBusName='';
        ConstBusType='';
    end

    if outType.isArrayType&&isscalar(cval)
        cval=pirelab.getValueWithType(cval,outType);
    end
end
