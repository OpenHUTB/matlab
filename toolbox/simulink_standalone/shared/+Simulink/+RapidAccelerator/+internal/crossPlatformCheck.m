function crossPlatformCheck(buildarch)
    currentarch=computer('arch');
    if(~strcmp(buildarch,currentarch))
        error(message('simulinkcompiler:runtime:SimulinkCompilerCrossPlatformUnsupported',buildarch,currentarch));
    end
end