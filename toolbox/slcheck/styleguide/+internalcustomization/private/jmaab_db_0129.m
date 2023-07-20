function jmaab_db_0129









    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.db_0129_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.db_0129_b';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.db_0129_c';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.db_0129_d';
    SubCheckCfg(5).Type='Normal';
    SubCheckCfg(5).subcheck.ID='slcheck.jmaab.db_0129_e';

    rec=slcheck.Check('mathworks.jmaab.db_0129',SubCheckCfg,{sg_jmaab_group,sg_maab_group});
    rec.relevantEntities=@getRelevantBlocks;
    rec.LicenseString={styleguide_license,'Stateflow'};


    inputParamList=rec.setDefaultInputParams(false);
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:db_0129_d_Check_SelfTransitions');
    inputParamList{end}.Type='Bool';
    inputParamList{end}.RowSpan=[4,4];
    inputParamList{end}.ColSpan=[5,5];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Value=false;

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[6,6];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';


    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[6,6];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';


    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@inputParam_CallBack);
    rec.register();
end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)
    entities=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,...
    LookUnderMasks,{'-isa','Stateflow.Chart','-or',...
    '-isa','Stateflow.Transition','-or',...
    '-isa','Stateflow.Junction'},true);
end

function inputParam_CallBack(taskobj,tag,handle)%#ok<INUSD>
    if strcmp(tag,'InputParameters_4')
        if isa(taskobj,'ModelAdvisor.Task')
            inputParameters=taskobj.Check.InputParameters;
        elseif isa(taskobj,'ModelAdvisor.ConfigUI')
            inputParameters=taskobj.InputParameters;
        else
            return
        end

        if isequal(inputParameters{4}.Value,true)
            inputParameters{end}.Enable=true;
        else
            inputParameters{end}.Enable=false;
        end

    end
end