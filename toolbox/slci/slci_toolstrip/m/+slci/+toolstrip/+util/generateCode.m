



function generateCode(cbinfo,useDefaultGenCodeOnlyOption,generateCodeOnly)

    modelH=cbinfo.model.Handle;

    if~bdIsLibrary(modelH)
        cs=getActiveConfigSet(modelH);
        if~isa(cs,'Simulink.ConfigSetRef')&&~useDefaultGenCodeOnlyOption
            set_param(modelH,'GenCodeOnly',generateCodeOnly);
        end

        ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
        ctx.setSingleFolderCodePlacement(false);

        configObj=slci.Configuration(get_param(modelH,'Name'));
        configObj.setViaGUI(true);
        configObj.setGenerateCode(true);
        configObj.setTopModel(ctx.getTopModel());

        try
            configObj.GenerateTheCode();
        catch

        end
        configObj.setGenerateCode(false);

    end
end