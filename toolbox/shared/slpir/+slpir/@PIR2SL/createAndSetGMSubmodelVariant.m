function createAndSetGMSubmodelVariant(this,outModelFile,simMode)

    simModeVariant=simMode;
    simModeVariant(1)=upper(simModeVariant(1));

    hD=hdlcurrentdriver;
    gmVariant.Name=hD.gmVariantName;
    gmVariant.ModelName=outModelFile;
    gmVariant.ParameterArgumentNames='';
    gmVariant.ParameterArgumentValues='';
    gmVariant.SimulationMode=simModeVariant;
    origVariant=get_param(this.DUTMdlRefHandle,'Variants');
    genBlockPath=[get_param(origVariant.BlockName,'Parent'),'/',gmVariant.ModelName];
    add_block(origVariant.BlockName,genBlockPath);
    set_param(genBlockPath,'ModelName',gmVariant.ModelName);
    set_param(genBlockPath,'ParameterArgumentValues',gmVariant.ParameterArgumentValues);
    set_param(genBlockPath,'SimulationMode',gmVariant.SimulationMode);
    set_param(genBlockPath,'VariantControl',gmVariant.Name);

end
