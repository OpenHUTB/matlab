function slCoderCorePreSaveWarningCallback(bdname)
    % verifies that a model doesn't have a coder
    % dictionary before saving it as an MDL file
    if (bdIsLoaded(bdname))
        mdlW = coder.internal.CoderDataStaticAPI.mdlWarner(get_param(bdname, 'Handle'));
        warnIfMdl(mdlW);
    end
end
