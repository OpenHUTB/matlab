function msgObj=validateMaskParameterInfo(~,maskParamInfo)





    msgObj=[];


    blkDialogStr=get_param(maskParamInfo.blkHandle,'const');


    if isempty(regexp(blkDialogStr,maskParamInfo.maskName,'once'))


        msgObj=message('hdlcoder:engine:genericcompareconstdialog',maskParamInfo.maskName);
        return;
    end

    if~strcmp(blkDialogStr,maskParamInfo.maskName)



        msgObj=message('hdlcoder:engine:unsupportedgenericstatement',maskParamInfo.maskName);
        return;
    end

end