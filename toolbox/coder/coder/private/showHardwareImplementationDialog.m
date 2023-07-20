




function showHardwareImplementationDialog(hwi,varargin)
    if coderapp.internal.globalconfig('NewConfigDialog')
        showNewDialog(hwi,varargin{:});
    else
        showJavaDialog(hwi);
    end
end


function dialog=showNewDialog(hwi,varargin)
    dialog=coderapp.internal.CoderConfigDialog.getInstance(hwi,varargin{:});
    dialog.show();
end


function showJavaDialog(hwi)
    import('com.mathworks.toolbox.coder.app.UnifiedTargetFactory');%#ok<JAPIMATHWORKS>

    config=coder.config('lib');
    config.HardwareImplementation=hwi;
    project=UnifiedTargetFactory.createTemporaryCoderProject(true);




    project.getConfiguration().setArbitraryEnumValueAllowed('param.CodeReplacementLibrary',true);

    copyConfigObjectToProject(config,project);

    configObjectDialog('showHardwareDialog',project,config);
end
