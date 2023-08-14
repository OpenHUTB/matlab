function generateSLBlock(this,hC,targetBlkPath)














    originalBlkPath=getfullname(hC.SimulinkHandle);

    outputPipelineDelay=getImplParams(this,'OutputPipeline');
    inputPipelineDelay=getImplParams(this,'InputPipeline');

    outDelay=hC.getOptimizationLatency;
    if outDelay>0


        generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,outDelay);
    else

        addBlockAndHilite(this,hC,originalBlkPath,targetBlkPath,...
        inputPipelineDelay,outputPipelineDelay);
    end

    rt=sfroot;
    src_machine=rt.find('-isa','Stateflow.Machine','Name',bdroot(originalBlkPath));
    src_target=src_machine.find('-isa','Stateflow.Target','Name','sfun');

    gm_machine=rt.find('-isa','Stateflow.Machine','Name',bdroot(targetBlkPath));
    gm_target=gm_machine.find('-isa','Stateflow.Target','Name','sfun');


    gm_machine.Debug.RunTimeCheck.StateInconsistencies=src_machine.Debug.RunTimeCheck.StateInconsistencies;
    gm_machine.Debug.RunTimeCheck.DataRangeChecks=src_machine.Debug.RunTimeCheck.DataRangeChecks;
    gm_machine.Debug.RunTimeCheck.CycleDetection=src_machine.Debug.RunTimeCheck.CycleDetection;
    gm_machine.Debug.DisableAllBreakpoints=src_machine.Debug.DisableAllBreakpoints;
    gm_machine.Debug.BreakOn.StateEntry=src_machine.Debug.BreakOn.StateEntry;
    gm_machine.Debug.BreakOn.EventBroadcast=src_machine.Debug.BreakOn.EventBroadcast;
    gm_machine.Debug.BreakOn.ChartEntry=src_machine.Debug.BreakOn.ChartEntry;
    gm_machine.Debug.Animation.Delay=src_machine.Debug.Animation.Delay;
    gm_machine.Debug.Animation.Enabled=src_machine.Debug.Animation.Enabled;


    gm_target.ApplyToAllLibs=src_target.ApplyToAllLibs;
    gm_target.ApplyToAllLibs=src_target.ApplyToAllLibs;
    gm_target.CustomCode=src_target.CustomCode;
    gm_target.CustomInitializer=src_target.CustomInitializer;
    gm_target.CustomTerminator=src_target.CustomTerminator;
    gm_target.UserIncludeDirs=src_target.UserIncludeDirs;
    gm_target.UserLibraries=src_target.UserLibraries;
    gm_target.UserSources=src_target.UserSources;
    gm_target.setCodeFlag('debug',src_target.getCodeFlag('debug'));
    gm_target.setCodeFlag('overflow',src_target.getCodeFlag('overflow'));
end


function addBlockAndHilite(this,hC,originalBlkPath,targetBlkPath,...
    inputPipelineDelay,outputPipelineDelay)

    uniqueName=targetBlkPath;
    try
        find_system(uniqueName,'SearchDepth',1);
        blockExists=1;
    catch
        blockExists=0;
    end
    if blockExists
        suffix='_chart';
        uniqueName=[uniqueName,suffix];
        hC.Name=[hC.Name,suffix];
    end
    newBlockHandle=add_block(originalBlkPath,uniqueName);
    targetParentPath=get_param(uniqueName,'Parent');

    hdlbuiltinimpl.EmlImplBase.addTunablePortsFromParams(newBlockHandle);


    [turnhilitingon,color]=this.getHiliteInfo(hC);
    if((~isempty(inputPipelineDelay)&&inputPipelineDelay>0)...
        ||(~isempty(outputPipelineDelay)&&outputPipelineDelay>0))...
        &&turnhilitingon
        set_param(targetParentPath,'BackgroundColor',color);
    end
end
