function nPUs=getNumOfPUsOmitCLA(hObj)



    PUs=codertarget.utils.getRegisteredCPUs(hObj);
    PUs(contains(PUs,'CLA'))=[];
    nPUs=numel(PUs);
end