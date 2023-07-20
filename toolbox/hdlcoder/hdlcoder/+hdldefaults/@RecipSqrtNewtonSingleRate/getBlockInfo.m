function newtonInfo=getBlockInfo(this,slbh)

















    newtonInfo.networkName=get_param(slbh,'Name');


    newtonInfo.rndMode=get_param(slbh,'RndMeth');
    newtonInfo.satMode=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');


    newtonInfo.iterNum=hdlslResolve('Iterations',slbh);


    newtonInfo.internalRule='';
    intermStr=get_param(slbh,'IntermediateResultsDataTypeStr');
    if strcmpi(intermStr,'Inherit: Inherit from input')
        newtonInfo.intermDT='Input';
    elseif strcmpi(intermStr,'Inherit: Inherit from output')
        newtonInfo.intermDT='Output';
    elseif strcmpi(intermStr,'Inherit: Inherit via internal rule')
        newtonInfo.intermDT='InternalRule';
        newtonInfo.internalRule=get_param(slbh,'IntermediateResultsDataTypeName');
    else
        error(message('hdlcoder:validate:IncorrectIntermDTSR',intermStr,newtonInfo.networkName));
    end





