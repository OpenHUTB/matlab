function isXCP=isModelConfiguredForXCPExtMode(mdl)












    h=coder.internal.ModelCodegenMgr.getInstance(mdl);

    if~isempty(h)
        isXCP=h.MdlRefBuildArgs.IsExtModeXCP;
    else
        cs=getActiveConfigSet(mdl);
        isXCP=coder.internal.xcp.isXCPTarget(cs);
    end
end
