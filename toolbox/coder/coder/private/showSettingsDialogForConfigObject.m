




function showSettingsDialogForConfigObject(config,varargin)
    if coderapp.internal.globalconfig('NewConfigDialog')
        showNewConfigDialog(config,varargin{:});
    else
        showJavaSettingsDialog(config);
    end
end


function showNewConfigDialog(config,varargin)
    dialog=coderapp.internal.CoderConfigDialog.getInstance(config,varargin{:});
    dialog.show();
end


function showJavaSettingsDialog(config)
    import('com.mathworks.toolbox.coder.app.UnifiedTargetFactory');
    import('matlab.internal.lang.capability.Capability');

    if~Capability.isSupported(Capability.ComplexSwing)
        error(message('Coder:configSet:MODialogError'));
    end

    project=UnifiedTargetFactory.createTemporaryCoderProject(true);
    javaConfig=project.getConfiguration();

    javaConfig.setParamAsBoolean(com.mathworks.toolbox.coder.plugin.Utilities.PARAM_IS_STANDALONE_DIALOG,true);




    javaConfig.setArbitraryEnumValueAllowed('param.CodeReplacementLibrary',true);





    if isa(config,'coder.CodeConfig')
        isEcoder=isa(config,'coder.EmbeddedCodeConfig');
        javaConfig.setParamAsBoolean('param.HasECoderFeatures',isEcoder);
        javaConfig.setParamAsBoolean('param.UseECoderFeatures',isEcoder);
    end

    copyConfigObjectToProject(config,project);

    configObjectDialog('show',project,config);
end
