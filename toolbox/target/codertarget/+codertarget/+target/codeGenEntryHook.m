function codeGenEntryHook(h)




    hCS=getActiveConfigSet(h.ModelName);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(h.ModelName);
    xilInfo=modelCodegenMgr.MdlRefBuildArgs.XilInfo;

    hA=codertarget.attributes.getTargetHardwareAttributes(hCS);
    if~isempty(get(hA,'Profiler'))&&~xilInfo.IsPil
        set_param(h.ModelName,'ExecTimeCallbackPrm',@codertarget.profile.codeGenHook);
    end

    codeGenEntryHook=get(hA,'OnCodeGenEntryHook');
    if~isempty(codeGenEntryHook)
        feval(codeGenEntryHook,hCS);
    end
end
