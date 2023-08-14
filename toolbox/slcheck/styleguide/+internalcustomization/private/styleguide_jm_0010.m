function styleguide_jm_0010





    rec=ModelAdvisor.Check('mathworks.maab.jm_0010');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jm0010Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jm0010Tip');
    rec.setCallbackFcn(@jm_0010_StyleOneCallback,'None','DetailStyle');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jm0010Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='all';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end


function jm_0010_StyleOneCallback(system,CheckObj)

    feature('scopedaccelenablement','off');

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);


    failedPorts=checkPortNames(mdladvObj,system);

    failedPorts=mdladvObj.filterResultWithExclusion(failedPorts);

    if isempty(failedPorts)
        mdladvObj.setCheckResultStatus(true);
        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jm0010_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jm0010_Pass'));
    else
        mdladvObj.setCheckResultStatus(false);

        ElementResults=Advisor.Utils.createResultDetailObjs(failedPorts,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jm0010_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jm0010FailMsg'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:jm0010_RecAct'));
    end
    CheckObj.setResultDetails(ElementResults);

end


function failed=checkPortNames(mdladvObj,system)
    systemHdl=get_param(system,'Handle');
    failed=[];

    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');




    allSubSystems=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',followlinkParam.Value,'LookUnderMasks',lookundermaskParam.Value,'FindAll','on','BlockType','SubSystem');
    allSubSystems(end+1)=systemHdl;

    allSubSystems=unique(allSubSystems);



    for i=1:length(allSubSystems)
        if slprivate('is_stateflow_based_block',getfullname(allSubSystems(i)))






        else
            failed=[failed,loc_checkSubSystem(mdladvObj,allSubSystems(i))];%#ok<AGROW>
        end
    end
end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

function failed=loc_checkSubSystem(mdladvObj,subsystem)
    failed=[];

    [iPort,oPort]=loc_getSubsystemPortBlocks(mdladvObj,subsystem);



    for j=1:length(iPort)
        portHandle=get_param(iPort(j),'PortHandles');
        if(portHandle.Outport~=-1)&&~(simulink.diagram.internal.isNameHiddenAutomatically(iPort(j))||strcmp(get_param(iPort(j),'showname'),'off'))

            signalName=get_param(portHandle.Outport(1),'Name');


            LH=get(portHandle.Outport(1),'Line');
            if isempty(signalName)&&(-1~=LH)&&strcmp(get(LH,'SignalPropagation'),'on')
                signalName=get_param(portHandle.Outport(1),'PropagatedSignals');
            end

            if(~isempty(signalName))

                portName=get_param(iPort(j),'Name');
                match=strcmp(portName,signalName)||strcmp(portName,[signalName,'_in']);
                if(~match)
                    failed(end+1)=iPort(j);%#ok<AGROW>
                end
            end
        end
    end


    for j=1:length(oPort)
        bObj=get_param(oPort(j),'Object');
        if(bObj.lineHandles.Inport~=-1)&&~(simulink.diagram.internal.isNameHiddenAutomatically(oPort(j))||strcmp(get_param(oPort(j),'showname'),'off'))

            signalName=get_param(bObj.lineHandles.Inport,'Name');








            propName=regexp(signalName,'^<(.*)>$','tokens','once');
            if(~isempty(propName))
                signalName=propName{1};
            end

            if(~isempty(signalName))

                portName=get_param(oPort(j),'Name');

                match=strcmp(portName,signalName)||strcmp(portName,[signalName,'_out']);
                if(~match)
                    failed(end+1)=oPort(j);%#ok<AGROW>
                end
            end
        end
    end
end

function[iPort,oPort]=loc_getSubsystemPortBlocks(mdladvObj,subsystem)
    followlinkParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(mdladvObj,'find_system.LookUnderMasks');

    iPort=find_system(subsystem,'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'FindAll','on',...
    'SearchDepth',1,...
    'BlockType','Inport');
    oPort=find_system(subsystem,'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value...
    ,'FindAll','on'...
    ,'SearchDepth',1,...
    'BlockType','Outport');
end
