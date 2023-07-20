function wrapBlockWithSubsytem(blockPathOrHandle)




    blockPath=Simulink.ID.getFullName(Simulink.ID.getSID(blockPathOrHandle));
    schema=FunctionApproximation.internal.approximationblock.BlockSchema();


    kSystem=new_system;
    load_system(kSystem);
    modelName=get(kSystem,'Name');
    orignalBlock=[modelName,'/',schema.SourceName];
    add_block(blockPath,orignalBlock);
    blockHandles(1)=get_param(orignalBlock,'Handle');
    blockObject=get_param(orignalBlock,'Object');
    nInputs=numel(blockObject.PortHandles.Inport);
    nOutputs=numel(blockObject.PortHandles.Outport);


    for ii=1:nInputs
        inputDTCName=schema.getInputDTCName(ii);
        dtcPath=[modelName,'/',inputDTCName];
        add_block('simulink/Signal Attributes/Data Type Conversion',dtcPath);
        add_line(modelName,[inputDTCName,'/1'],[schema.SourceName,'/',int2str(ii)]);
        blockHandles(end+1)=get_param(dtcPath,'Handle');%#ok<AGROW>
        set_param(dtcPath,'OutDataTypeStr','double');
        set_param(dtcPath,'RndMeth','Nearest');
        set_param(dtcPath,'Commented','through');
    end


    for ii=1:nOutputs
        saturateOutName=schema.getOutputSaturationName(ii);
        saturationPath=[modelName,'/',saturateOutName];
        add_block('simulink/Commonly Used Blocks/Saturation',saturationPath);
        add_line(modelName,[schema.SourceName,'/',int2str(ii)],[saturateOutName,'/1']);
        blockHandles(end+1)=get_param(saturationPath,'Handle');%#ok<AGROW>
        set_param(saturationPath,'Commented','through');

        delayName=schema.getOutputLatencyDelayName(ii);
        delayPath=[modelName,'/',delayName];
        add_block('simulink/Commonly Used Blocks/Delay',delayPath);
        add_line(modelName,[saturateOutName,'/1'],[delayName,'/1']);
        blockHandles(end+1)=get_param(delayPath,'Handle');%#ok<AGROW>
        set_param(delayPath,'Commented','through');
    end

    Simulink.BlockDiagram.arrangeSystem(modelName);
    Simulink.BlockDiagram.createSubsystem(blockHandles);
    tempSubsystemPath=[modelName,'/Subsystem'];
    FunctionApproximation.internal.Utils.replaceBlockWithBlock(blockPath,tempSubsystemPath);
    close_system(kSystem,0);
end


