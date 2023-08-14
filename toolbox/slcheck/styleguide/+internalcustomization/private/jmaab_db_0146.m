function jmaab_db_0146






    SubChecksCfg(1).Type='Normal';
    SubChecksCfg(1).subcheck.ID='slcheck.jmaab.db_0146_a';

    SubChecksCfg(2).Type='Normal';
    SubChecksCfg(2).subcheck.ID='slcheck.jmaab.db_0146_b';


    rec=slcheck.Check('mathworks.jmaab.db_0146',SubChecksCfg,{sg_jmaab_group,sg_maab_group});



    inputParamList=rec.setDefaultInputParams(false);

    rec.relevantEntities=@getRelevantEntities;


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');


    entries={DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Top'),...
    DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Left'),...
    DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Right'),...
    DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Bottom')};

    paramBlockPosition=Advisor.Utils.getInputParam_Enum('ModelAdvisor:jmaab:db_0146_BlockPosition',[4,4],[1,2],entries);

    paramFollowLinks.RowSpan=[3,3];
    paramFollowLinks.ColSpan=[1,2];
    paramLookUnderMasks.RowSpan=[3,3];
    paramLookUnderMasks.ColSpan=[3,4];
    rec.setInputParametersLayoutGrid([4,4]);

    rec.setInputParameters([inputParamList,{paramFollowLinks,paramLookUnderMasks,paramBlockPosition}]);

    rec.LicenseString=styleguide_license;

    rec.register();

end

function entities=getRelevantEntities(system,FollowLinks,LookUnderMasks)


    entities=find_system(...
    system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,...
    'LookUnderMasks',LookUnderMasks,...
    'regexp','on',...
    'BlockType','TriggerPort|EnablePort|ActionPort|ForIterator|WhileIterator|ForEach'...
    );
    entities=Advisor.Utils.Naming.filterUsersInShippingLibraries(entities);

    serviceOptions.FollowLinks=FollowLinks;
    serviceOptions.LookUnderMasks=LookUnderMasks;
    serviceOptions.BlocksOnly=false;

    slcheck.services.PositionalMapService.instance.init(system,serviceOptions);
end
