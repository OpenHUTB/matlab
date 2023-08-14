function newtonInfo=getBlockInfo(this,slbh)

















    newtonInfo.networkName=get_param(slbh,'Name');


    newtonInfo.rndMode=get_param(slbh,'RndMeth');
    newtonInfo.satMode=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');


    newtonInfo.iterNum=this.getChoice;


    newtonInfo.intermDT='Output';
    newtonInfo.internalRule='';


    newtonInfo.isMultirate=true;
    newtonInfo.upFactor=3;


    newtonInfo.isRsqrtBased=true;



