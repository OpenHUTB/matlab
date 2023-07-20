




function initSFSimFolder(mdl)

    [missingFlag,mdlHdl]=isMissingSFSimArtifacts(mdl);
    if missingFlag
        assert(~isempty(mdlHdl));
        genSFSimArtifacts(mdlHdl);
    end

end




function[missingFlag,mdlHdl]=isMissingSFSimArtifacts(mdl)


    matlabBlks=getMLBlks(mdl);
    if isempty(matlabBlks)
        missingFlag=false;
        mdlHdl=[];
    else

        set_param(mdl,'SimulationCommand','update');
        [hasFlag,mdlHdl]=hasMLSimArtifacts(matlabBlks);
        missingFlag=~hasFlag;
    end

end


function matlabBlks=getMLBlks(mdl)

    matlabBlks=[];
    mdlHandle=get_param(mdl,'Handle');


    subsystems=find_system(mdlHandle,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LookUnderReadProtectedSubsystems','on',...
    'BlockType','SubSystem');
    for k=1:numel(subsystems)
        subsystem=subsystems(k);
        if slci.internal.isStateflowBasedBlock(subsystem)&&...
            sfprivate('is_eml_chart_block',subsystem)
            matlabBlks(end+1)=subsystem;%#ok
        end
    end

end


function[flag,mdlHdl]=hasMLSimArtifacts(matlabBlks)

    assert(~isempty(matlabBlks));

    mdlHdls=[];
    flag=true;
    for k=1:numel(matlabBlks)
        blkHdl=matlabBlks(k);
        chartId=sfprivate('block2chart',blkHdl);
        chartObj=idToHandle(sfroot,chartId);
        reportData=slci.mlutil.extractInferenceData(chartObj,blkHdl);
        if isempty(reportData)

            flag=false;
            machineObj=getMainMachine(chartObj,blkHdl);
            machineName=machineObj.Name;
            machineHdl=get_param(machineName,'Handle');
            mdlHdls(end+1)=machineHdl;%#ok
        end
    end

    if~isempty(mdlHdls)
        mdlHdls=unique(mdlHdls);

        assert(numel(mdlHdls)==1);
        mdlHdl=mdlHdls(1);
    else
        mdlHdl=[];
    end
end


function mainMachine=getMainMachine(chartUDDObj,hBlk)

    if chartUDDObj.Machine.isLibrary
        mdlName=get_param(bdroot(hBlk),'Name');
        mainMachine=find(sfroot,'-isa','Stateflow.Machine',...
        'Name',mdlName);%#ok<GTARG>
    else

        mainMachine=chartUDDObj.Machine;
    end

end


function genSFSimArtifacts(mdlHdl)
    mdlName=get_param(mdlHdl,'Name');
    mainMachine=find(sfroot,'-isa','Stateflow.Machine',...
    'Name',mdlName);%#ok<GTARG>
    sfprivate('autobuild_driver','rebuildall',mainMachine.Name,'sfun','no');
end
