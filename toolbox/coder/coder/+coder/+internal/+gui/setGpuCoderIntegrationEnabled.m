

function setGpuCoderIntegrationEnabled(enabled)
    if usejava('jvm')
        com.mathworks.toolbox.coder.app.FeatureSwitches.setGpuCoderIntegrationEnabled(enabled);
    else
        error('App integration requires use of a JVM');
    end
end
