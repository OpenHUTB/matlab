function restoreToGpuCoderFactorySettings(cfg)





    setIfExists('DynamicMemoryAllocation','Threshold');
    setIfExists('DynamicMemoryAllocationThreshold',1073741824);
    setIfExists('InlineBetweenUserFunctions','Always');
    setIfExists('InlineBetweenMathWorksFunctions','Always');
    setIfExists('InlineBetweenUserAndMathWorksFunctions','Always');
    setIfExists('CppPreserveClasses',false);
    setIfExists('DynamicMemoryAllocationInterface','C');

    emlcprivate('forceGpuCoderSettings',cfg);

    function setIfExists(propName,propValue)
        if isprop(cfg,propName)
            cfg.(propName)=propValue;
        end
    end

end
