function resetInstructionSetExtensionsIfNecessary(cs,paramName)








    if isa(cs,'Simulink.HardwareCC')
        config=cs.getConfigSet();
    else
        config=cs;
    end

    prodEqTarget=strcmpi(cs.getProp('ProdEqTarget'),'on');
    needSwitching=(strcmpi(paramName,'ProdHWDeviceType')&&prodEqTarget)||...
    (strcmpi(paramName,'TargetHWDeviceType')&&~prodEqTarget);

    if~isempty(config)&&needSwitching
        defaultISE=configset.internal.util.getDefaultInstructionSetExtensions(config);
        config.set_param('InstructionSetExtensions',defaultISE);
    end
end