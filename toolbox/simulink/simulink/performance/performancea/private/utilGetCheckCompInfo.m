function CompInfo=utilGetCheckCompInfo(checkObj)




    if isfield(checkObj.ResultData,'compInfo')
        CompInfo=checkObj.ResultData.compInfo;
    else
        CompInfo.value={};
        CompInfo.valid=false;
    end