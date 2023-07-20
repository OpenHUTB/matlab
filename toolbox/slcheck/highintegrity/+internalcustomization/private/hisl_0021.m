function hisl_0021




    rec=getNewCheckObject('mathworks.hism.hisl_0021',false,@hCheckAlgo,'None');

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_title');
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice1'),...
    DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice2'),...
    DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice3')};
    inputParamList{end}.Value=DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice1');
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[2,2];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';


    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end


function violations=hCheckAlgo(system)

    violations=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    check_setting=inputParams{1}.Value;






    allBlocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',inputParams{2}.Value,...
    'LookUnderMasks',inputParams{3}.Value,...
    'RegExp','on',...
    'BlockType','\<MultiPortSwitch\>|\<Assignment\>|\<Selector\>|\<ForIterator\>');
    allBlocks=mdladvObj.filterResultWithExclusion(allBlocks);

    flags=zeros(1,length(allBlocks));
    for i=1:length(allBlocks)
        if strcmp(get_param(allBlocks{i},'BlockType'),'MultiPortSwitch')
            param='DataPortOrder';
        else
            param='IndexMode';
        end

        if strncmpi(get_param(allBlocks{i},param),'Zero-based',10)
            flags(i)=1;
        elseif strncmpi(get_param(allBlocks{i},param),'One-based',9)
            flags(i)=2;
        else
            flags(i)=0;
        end

    end

    ZeroBasedBlocks=allBlocks(flags==1);
    OneBasedBlocks=allBlocks(flags==2);






    commonArgs={'FollowLinks',inputParams{2}.Value,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',inputParams{3}.Value};
    OneBasedBlocks=[OneBasedBlocks;...
    find_system(system,commonArgs{:},'BlockType','Fcn');...
    find_system(system,commonArgs{:},'SFBlockType','MATLAB Function');...
    find_system(system,commonArgs{:},'BlockType','MATLABSystem');...
    find_system(system,commonArgs{:},'SFBlockType','Truth Table');...
    find_system(system,commonArgs{:},'SFBlockType','Test Sequence')];


    if(Advisor.Utils.license('test','stateflow'))
        OneBasedBlocks=[OneBasedBlocks;...
        Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.Chart','-and','ActionLanguage','MATLAB'},true);...
        Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.StateTransitionTableChart','-and','ActionLanguage','MATLAB'},true);...
        Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.TruthTable','-and','Language','MATLAB'},true)];
    end
    OneBasedBlocks=mdladvObj.filterResultWithExclusion(OneBasedBlocks);


    if(Advisor.Utils.license('test','stateflow'))


        ZeroBasedBlocks=[ZeroBasedBlocks;...
        Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.Chart','-and','ActionLanguage','C'},true);...
        Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.StateTransitionTableChart','-and','ActionLanguage','C'},true);...
        Advisor.Utils.Stateflow.sfFindSys(system,inputParams{2}.Value,inputParams{3}.Value,{'-isa','Stateflow.TruthTable','-and','Language','C'},true)];
    end

    ZeroBasedBlocks=mdladvObj.filterResultWithExclusion(ZeroBasedBlocks);

    switch check_setting
    case DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice1')

        if~isempty(ZeroBasedBlocks)&&~isempty(OneBasedBlocks)

            violations=[Advisor.Utils.createResultDetailObjs(ZeroBasedBlocks,'Status',DAStudio.message('ModelAdvisor:hism:hisl_0021_warn1'),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0021_rec_action1')),...
            Advisor.Utils.createResultDetailObjs(OneBasedBlocks,'Status',DAStudio.message('ModelAdvisor:hism:hisl_0021_warn2'),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0021_rec_action1'))];
        end

    case DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice2')

        violations=Advisor.Utils.createResultDetailObjs(OneBasedBlocks,'Status',DAStudio.message('ModelAdvisor:hism:hisl_0021_warn2'),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0021_rec_action2'));

    case DAStudio.message('ModelAdvisor:hism:hisl_0021_input_param_choice3')

        violations=Advisor.Utils.createResultDetailObjs(ZeroBasedBlocks,'Status',DAStudio.message('ModelAdvisor:hism:hisl_0021_warn1'),'RecAction',DAStudio.message('ModelAdvisor:hism:hisl_0021_rec_action3'));

    end


end
