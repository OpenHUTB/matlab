


function Simulink_Simulation_Manager(fileName)



    multiSimMgr=MultiSim.internal.MultiSimManager.getMultiSimManager();
    viewer=multiSimMgr.getWindowForFile(fileName);
    if~isempty(viewer)
        viewer.show();
        return;
    end


    simulink.simmanager.FileReader.checkFileIsReadable(fileName);


    desc=matlabshared.mldatx.internal.getDescription(fileName);
    expectedDescription=message('multisim:FileIO:SimManagerFileDescription').getString();
    if~strcmp(desc,expectedDescription)
        error(message('multisim:FileIO:InvalidSimulationManagerFile',fileName));
    end
    jobDeserializer=MultiSim.internal.JobDeserializer();
    job=jobDeserializer.deserialize(fileName);
    viewer=MultiSim.internal.MultiSimJobViewer(job);
    viewer.setLayout(job.Layout);
    viewer.Title=message('multisim:SimulationManager:WindowTitle',fileName).getString();
    multiSimMgr.associateWindowWithFile(viewer,fileName);
    viewer.IsDirty=false;
end
