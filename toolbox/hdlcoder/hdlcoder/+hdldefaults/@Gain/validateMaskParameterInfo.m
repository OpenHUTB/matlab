function msgObj=validateMaskParameterInfo(this,maskParamInfo)





    msgObj=[];


    blkDialogStr=get_param(maskParamInfo.blkHandle,'Gain');

    if isempty(regexp(blkDialogStr,maskParamInfo.maskName,'once'))



        msgObj=message('hdlcoder:engine:genericgaindialog',maskParamInfo.maskName);
        return;
    end

    if~strcmp(blkDialogStr,maskParamInfo.maskName)



        msgObj=message('hdlcoder:engine:unsupportedgenericstatement',maskParamInfo.maskName);
        return;
    end


    constMultiplierOptimParam=this.getImplParams('ConstMultiplierOptimization');
    if~isempty(constMultiplierOptimParam)&&...
        ~strcmpi(constMultiplierOptimParam,'none')
        msgObj=message('hdlcoder:engine:genericgaincsd',maskParamInfo.maskName);
        return;
    end

end
