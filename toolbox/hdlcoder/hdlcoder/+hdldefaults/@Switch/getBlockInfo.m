function[compareStr,compareVal,roundMode,overflowMode]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;

    compareStr=get_param(slbh,'Criteria');
    swObj=get_param(slbh,'Object');
    swVals=swObj.getPropAllowedValues('Criteria');
    if strcmpi(swVals{3},compareStr)
        compareVal=0;
    else
        compareVal=hdlslResolve('Threshold',slbh);
    end

    roundMode=get_param(slbh,'RndMeth');
    saturateFlag=get_param(slbh,'SaturateOnIntegerOverflow');
    if strcmp(saturateFlag,'off')
        overflowMode='Wrap';
    else
        overflowMode='Saturate';
    end
end


