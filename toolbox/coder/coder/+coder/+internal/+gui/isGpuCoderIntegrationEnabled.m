

function enabled=isGpuCoderIntegrationEnabled()
    enabled=usejava('jvm')&&com.mathworks.toolbox.coder.app.FeatureSwitches.isGpuCoderIntegrationEnabled();
end
