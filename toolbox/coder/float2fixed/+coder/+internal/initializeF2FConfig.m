function initializeF2FConfig(cfg,coderConfig)
    cfg.SupportCellArrays=logical(coder.internal.f2ffeature('SingleCCellArraySupport'));
    cfg.EmitColonWarnings=logical(coder.internal.f2ffeature('EmitColonWarnings'));
    cfg.TransformLibraryFunctions=logical(coder.internal.f2ffeature('TransformLibraryFunctions'));
    cfg.EmitC89Warnings=false;

    if~builtin('license','test','Fixed_Point_Toolbox')
        error(message('Coder:FXPCONV:DTS_RequiresFixedPointDesigner'));
    end

    try
        if isprop(coderConfig,'TargetLangStandard')
            langStd=strtrim(coderConfig.TargetLangStandard);
            if strcmp(langStd,'C89/C90 (ANSI)')
                cfg.EmitC89Warnings=true;
            end
        end
    catch
    end
end

