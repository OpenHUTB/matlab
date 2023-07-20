function ret=isHeterogenousProcessorBoard(modelName)




    ret=false;
    tgtHWInfo=codertarget.targethardware.getTargetHardware(getActiveConfigSet(modelName));
    if~isempty(tgtHWInfo.ProcessingUnitInfo)

        if numel(unique({tgtHWInfo.ProcessingUnitInfo(:).ProdHWDeviceType}))>1
            ret=true;
        end
    end

end
