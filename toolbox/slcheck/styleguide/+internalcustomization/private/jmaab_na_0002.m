function jmaab_na_0002





    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.na_0002_a';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.na_0002_b';

    rec=slcheck.Check('mathworks.jmaab.na_0002',...
    SubCheckCfg,...
    {sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    inputParamList=rec.setDefaultInputParams();
    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:na_0002_InputNumericBlocks');
    inputParamList{end}.Type='BlockType';
    inputParamList{end}.RowSpan=[rowSpan(1),rowSpan(1)+8];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=ModelAdvisor.Common.getNumericBlocks_na_0002_JMAAB;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:na_0002_InputLogicalBlocks');
    inputParamList{end}.Type='BlockType';
    inputParamList{end}.RowSpan=[rowSpan(1),rowSpan(1)+8];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=ModelAdvisor.Common.getLogicalBlocks_na_0002_JMAAB;

    rec.setInputParametersLayoutGrid([1,1]);
    rec.setInputParameters(inputParamList);

    rec.register();
end

function ents=getRelevantEntity(system,FollowLinks,LookUnderMasks)


    ents=get_param(find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,...
    'LookUnderMasks',LookUnderMasks,...
    'type','block'),'Handle');
end
