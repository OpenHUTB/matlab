function ret=addDefinesToBuildInfo(ModelName,Defines)





    ret=true;
    buildInfo=codertarget.interrupts.internal.getModelBuildInfo(ModelName);
    addDefines(buildInfo,Defines,'SkipForSil');
end


