function isMaster=isProcessingUnitMaster(hObj)


    if isequal(codertarget.targethardware.getProcessingUnitName(hObj),'c28xCPU1')
        isMaster=true;
    else
        isMaster=false;
    end
end

