function[rec]=styleguide_jc_0111









    rec=ModelAdvisor.Check('mathworks.maab.jc_0111');
    rec.Title=DAStudio.message(['ModelAdvisor:styleguide:'...
    ,'jc0111Title']);
    rec.TitleTips=DAStudio.message(['ModelAdvisor:styleguide:'...
    ,'jc0111Tip']);
    rec.CallbackHandle=@jc_0111_Callback;
    rec.CallbackContext='None';
    rec.CallbackStyle='DetailStyle';
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0111Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.SupportsEditTime=true;
    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.register(rec);
end




function jc_0111_Callback(system,CheckObj)

    feature('scopedaccelenablement','off');
    ResultDescription={};


    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);
    followlinkParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.LookUnderMasks');

    deviantSystems={};

    if(sLSGIsModelReference(system)==true)




    else



        blksSubsystem=find_system(system,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followlinkParam.Value,...
        'LookUnderMasks',lookundermaskParam.Value,...
        'BlockType','SubSystem');

        orient=get_param(blksSubsystem,'Orientation');
        rightOrient=strcmp(orient,'right');
        deviantSystems=blksSubsystem(find(~rightOrient));%#ok<FNDSB>
    end

    model=getfullname(bdroot(system));
    filteredDeviantSystems={};
    for i=1:length(deviantSystems)
        isSF=0;
        if~strcmp(model,get_param(deviantSystems{i},'Parent'))
            if slprivate('is_stateflow_based_block',get_param(deviantSystems{i},'Parent'))
                isSF=1;
            end
        end
        if~isSF
            filteredDeviantSystems=[filteredDeviantSystems,deviantSystems(i)];%#ok<AGROW>
        end
    end
    deviantSystems=filteredDeviantSystems;

    deviantSystems=modelAdvisorObject.filterResultWithExclusion(deviantSystems);

    if~isempty(deviantSystems)

        modelAdvisorObject.setCheckResultStatus(false);
        ElementResults=Advisor.Utils.createResultDetailObjs(deviantSystems,...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jc0111_Info'),...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0111SubSystemError'),...
        'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc0111_RecAct'));

    else


        ElementResults=Advisor.Utils.createResultDetailObjs('',...
        'Description',DAStudio.message('ModelAdvisor:styleguide:jc0111_Info'),...
        'IsViolation',false,...
        'Status',DAStudio.message('ModelAdvisor:styleguide:jc0111SubSystemPass'));
        modelAdvisorObject.setCheckResultStatus(true);
    end
    ResultDescription=[ResultDescription,ElementResults];

    CheckObj.setResultDetails(ResultDescription);
end


