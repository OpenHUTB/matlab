function setTestComponentSimulationMode(obj)




    obj.mIsXIL=false;


    if~sldv.code.internal.isXilFeatureEnabled()||obj.mTestComp.activeSettings.Mode~="TestGeneration"
        obj.mTestComp.simMode="DV_SIMMODE_NORMAL";
        return;
    end

    if Sldv.utils.Options.isTestgenTargetForModel(obj.mTestComp.activeSettings)
        obj.mTestComp.simMode="DV_SIMMODE_NORMAL";
    else
        if Sldv.utils.Options.isTestgenTargetForCode(obj.mTestComp.activeSettings)
            obj.mTestComp.simMode="DV_SIMMODE_SIL";
        else
            obj.mTestComp.simMode="DV_SIMMODE_REFSIL";
        end
        obj.mIsXIL=true;
    end
end
