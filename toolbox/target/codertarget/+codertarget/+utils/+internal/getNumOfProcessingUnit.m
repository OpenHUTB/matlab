function nPUs=getNumOfProcessingUnit(hObj)



    nPUs=numel(codertarget.utils.getRegisteredCPUs(hObj));
end