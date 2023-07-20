function tcAlias=isToolchainSupportedForGPU(tcStruct)





    tcAlias=[];

    if~isempty(tcStruct)&&isstruct(tcStruct)&&isfield(tcStruct,'comp')
        if isprop(tcStruct.comp,'ShortName')
            supportedTCMap=coder.gpu.getSupportedTCMap;
            shortName=tcStruct.comp.ShortName;
            if~isempty(shortName)&&isKey(supportedTCMap,shortName)
                tcAlias=supportedTCMap(shortName);
            end
        end
    end
