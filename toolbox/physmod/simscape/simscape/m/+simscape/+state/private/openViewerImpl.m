function openViewerImpl(model,isUIMode,simulateModel)










    if isUIMode
        stageName=DAStudio.message('Simulink:SLMsgViewer:Simulation_Stage_Name');
        stage=Simulink.output.Stage(stageName,'ModelName',model,...
        'UIMode',true);%#ok<NASGU>
    end

    w=warning('query','backtrace');
    warning('off','backtrace');
    c=onCleanup(@()(warning(w)));

    try
        lImpl(model,simulateModel,isUIMode);
    catch e
        if isUIMode
            Simulink.output.error(e,'Component','Simscape');
        else
            rethrow(e);
        end
    end

end

function lImpl(model,simulateModel,uiMode)


    simscape_request_state_viewer(model,true);


    c=onCleanup(@()(simscape_request_state_viewer(model,false)));


    if~bdIsLoaded(model)
        open_system(model);
    end







    if~lModelContainsPmBlocks(model)&&~simscape.state.internal.disablePmBlocksCheck

        prefix='physmod:simscape:simscape:state:viewer';
        messageId=[prefix,':NoSimscapeBlocks'];
        dialogMessage=message(messageId,getfullname(model));
        error(dialogMessage);
    else


        validateModel(model);

        if simulateModel

            simscape.internal.sim0(model,uiMode);
        else


            simscape_open_state_viewer(model,true);


            c=onCleanup(@()(simscape_open_state_viewer(model,false)));
        end


        simscape.state.internal.addRenameCallback(model);


        simscape.state.internal.addClearCallback(model);

    end
end


function hasPmBlocks=lModelContainsPmBlocks(model)





    blockTypesRegex=char(join(string(pmsl_getblocktypes()),"|"));




    pmBlocks=find_system(model,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'regexp','on','Type','Block','BlockType',blockTypesRegex);



    if isempty(pmBlocks)


        neDomainBlocks=find_system(model,'FollowLinks','on','LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','SubSystem','PhysicalDomain','network_engine_domain');
        hasPmBlocks=~isempty(neDomainBlocks);
    else
        hasPmBlocks=true;
    end

end

function validateModel(model)



    simMode=get_param(model,'SimulationMode');
    supportedModes={'normal','accelerator'};
    unsupportedSimMode=~any(strcmpi(simMode,supportedModes));
    if unsupportedSimMode
        str=sprintf('''%s''',supportedModes{1});
        for idx=2:numel(supportedModes)
            str=sprintf('%s\n''%s''',str,supportedModes{idx});
        end
        pm_error('physmod:simscape:simscape:state:viewer:UnsupportedSimulationMode',...
        simMode,str);
    end


    mdlRefTarget=get_param(model,'ModelReferenceTargetType');
    switch upper(mdlRefTarget)
    case 'NONE'
        unsupportedModelRefMode=false;
    otherwise
        unsupportedModelRefMode=true;
    end
    if unsupportedModelRefMode
        pm_error('physmod:simscape:simscape:state:viewer:ModelRefNotSupported',...
        get_param(model,'Name'));
    end

end
