function browseOutputFolderForReduction(cbinfo)




    ctxApp=cbinfo.Context.Object.App;
    modelHandle=ctxApp.ModelHandle;



    fileName=get_param(modelHandle,'FileName');
    [dir,~,~]=fileparts(fileName);


    slvariants.internal.manager.core.disableUI(modelHandle);
    cleanupObj=onCleanup(@()uiCleanUpFcn(modelHandle));


    titlePrefix=[get_param(modelHandle,'Name'),': '];
    title=[titlePrefix,DAStudio.message('Simulink:VariantManagerUI:VariantReducerFilechooserDialog')];

    chosenDirectory=uigetdir(dir,title);

    if~chosenDirectory

        chosenDirectory=ctxApp.ReductionOptions.OutputFolder;
    end

    ctxApp.ReductionOptions.OutputFolder=chosenDirectory;

    function uiCleanUpFcn(modelHandle)
        if slvariants.internal.manager.core.hasOpenVM(modelHandle)
            slvariants.internal.manager.core.enableUI(modelHandle);
            slvariants.internal.manager.ui.utils.disableModelHierSSVM(modelHandle);
        end
    end
end


