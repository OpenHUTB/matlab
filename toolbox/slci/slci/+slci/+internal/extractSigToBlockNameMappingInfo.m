

























function blkName=extractSigToBlockNameMappingInfo(config,sigName)

    blkName='';

    if~config.hasModelMapping()
        return;
    end


    modelMapping=config.getModelMappingTable();

    blkName=extractSigToBlockNameMapping(modelMapping,sigName);

end

function blk_name=extractSigToBlockNameMapping(aModelMapping,aSigName)
    blk_name='';
    if aModelMapping.hasSignal(aSigName)
        blk_name=aModelMapping.getBlockNameInfo(aSigName);
    end
end