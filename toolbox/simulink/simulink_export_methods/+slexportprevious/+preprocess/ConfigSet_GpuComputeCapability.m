function ConfigSet_GpuComputeCapability(obj)





    if isReleaseOrEarlier(obj.ver,'R2021b')&&~isR2020aOrEarlier(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CSorCSR=getConfigSet(obj.modelName,sets{i});
            if isa(CSorCSR,'Simulink.ConfigSetRef')
                return;
            else
                locSetGpuComputeCapability(CSorCSR,obj);
            end
        end
    end






    function locSetGpuComputeCapability(configSet,saveAsVersionObj)
        if isRelease(saveAsVersionObj.ver,'R2020b')
            locSetCCAndReportWarningIfCCUnsupported({'8.0','8.6'},configSet,saveAsVersionObj);
        elseif isRelease(saveAsVersionObj.ver,'R2021a')||isRelease(saveAsVersionObj.ver,'R2021b')
            locSetCCAndReportWarningIfCCUnsupported({'8.6'},configSet,saveAsVersionObj);
        end
    end

end

function locSetCCAndReportWarningIfCCUnsupported(unsupportedCCs,configSet,saveAsVersionObj)
    gpu_compute_capability=get_param(configSet,'GPUComputeCapability');
    if any(strcmp(gpu_compute_capability,unsupportedCCs))
        set_param(configSet,'GPUComputeCapability','3.5');
        saveAsVersionObj.reportWarning('Simulink:ExportPrevious:GPUComputeCapabilityNotSupported',gpu_compute_capability,'3.5');
    end

end
