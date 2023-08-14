function validateExternalInput(simIn)










    buildDir=fullfile('slprj','raccel',simIn.ModelName);
    buildDataFile=fullfile(buildDir,'rs_raccel.mat');

    if~isdeployed&&~isfile(buildDataFile)
        Simulink.BlockDiagram.buildRapidAcceleratorTarget(simIn.ModelName);
    end

    buildData=load(buildDataFile);
    buildData.mdl=simIn.ModelName;
    buildData.opts.verbose=0;
    buildData.extInputs=simIn.ExternalInput;
    buildData.buildDir=char(buildDir);
    buildData.tmpVarPrefix={'1'};

    rapid_accel_target_utils('setup_ext_inputs',buildData);
end