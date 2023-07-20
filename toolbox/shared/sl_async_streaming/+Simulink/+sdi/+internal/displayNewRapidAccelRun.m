function displayNewRapidAccelRun(mdl,runID)



    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    isMenuSim=false;
    fw.onRapidAccelRunImport(runID,mdl,isMenuSim);
end