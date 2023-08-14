function[altMegaFunctionName,extraDir,status]=getRelopMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo,relopType)










    if(nargin<7)
        relopType='==';
    end

    baseType=inType.getTargetCompDataTypeStr(inType,true);

    convertType='';
    switch(relopType)
    case '==',
        convertType='EQ';
    case '~=',
        convertType='NEQ';
    case '<',
        convertType='LT';
    case '<=',
        convertType='LE';
    case '>',
        convertType='GT';
    case '>=',
        convertType='GE';
    case{'isInf','isFinite','isNaN'},
        error(message('hdlcommon:targetcodegen:AlteraMegaWizardUnsupportedMode',relopType));
    end
    specificArgs=sprintf('--component-param=compare_type=%s',convertType);
    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithTwoInputsFPF(targetCompInventory,baseType,className,convertType,latencyFreq,isFreqDriven,alteratarget.Relop,dryRun,deviceInfo,specificArgs,convertType);


