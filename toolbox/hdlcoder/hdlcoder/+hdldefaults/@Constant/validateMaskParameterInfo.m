function msgObj=validateMaskParameterInfo(~,maskParamInfo)





    msgObj=[];


    blkDialogStr=get_param(maskParamInfo.blkHandle,'Value');

    if isempty(regexp(blkDialogStr,maskParamInfo.maskName,'once'))



        msgObj=message('hdlcoder:engine:genericconstantdialog',maskParamInfo.maskName);
        return;
    end

    if~strcmp(blkDialogStr,maskParamInfo.maskName)



        msgObj=message('hdlcoder:engine:unsupportedgenericstatement',maskParamInfo.maskName);
        return;
    end

end
