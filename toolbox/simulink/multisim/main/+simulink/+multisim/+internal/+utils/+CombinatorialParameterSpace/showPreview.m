function showPreview(~,parameterSpace,modelHandle)




    combinatorialSampler=simulink.multisim.internal.sampler.CombinatorialParameterSpace(parameterSpace);
    designPoints=combinatorialSampler.createDesignPoints;

    if~isempty(designPoints)
        simulink.multisim.internal.utils.Preview.previewApp(designPoints);
    else
        reportEmptyDesignPointsWarning(modelHandle);
    end
end

function reportEmptyDesignPointsWarning(modelHandle)
    currentModelName=get_param(modelHandle,"Name");
    dvStageName=message("multisim:SetupGUI:DVMultiSimStageName").getString();
    dvStage=sldiagviewer.createStage(dvStageName,'ModelName',currentModelName);
    dvStageCleanup=onCleanup(@()delete(dvStage));

    ME=MException(message("multisim:SetupGUI:EmptyPreview"));
    sldiagviewer.reportWarning(ME);
end