function jmaab_db_0112




    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='db_0112_a';

    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.CheckIndexingMode';
    SubCheckCfg(1).subcheck(1).InitParams.Name='db_0112_a1';
    SubCheckCfg(1).subcheck(1).InitParams.IndexMode=1;

    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.CheckIndexingMode';
    SubCheckCfg(1).subcheck(2).InitParams.Name='db_0112_a2';
    SubCheckCfg(1).subcheck(2).InitParams.IndexMode=0;

    rec=slcheck.Check('mathworks.jmaab.db_0112',SubCheckCfg,{sg_jmaab_group,sg_maab_group});

    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,FollowLinks,LookUnderMasks)





    indexBlks=find_system(system,'FollowLinks',FollowLinks,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks',LookUnderMasks,...
    'regexp','on','BlockType',...
    '^(Assignment|ForIterator|Find|MultiPortSwitch|Selector)$');
    indexBlks=indexBlks';

    defaultIndexBlkList={...
    'SFBlockType','MATLAB Function';...
    'BlockType','Fcn';...
    'BlockType','MATLABSystem';...
    'SFBlockType','Truth Table';...
    'SFBlockType','State Transition Table';...
    'SFBlockType','Test Sequence'};


    defIndexBlks=cellfun(@(type,block)find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,...
    'LookUnderMasks',LookUnderMasks,...
    type,block),{defaultIndexBlkList{:,1}},{defaultIndexBlkList{:,2}},...
    'UniformOutput',false);

    defIndexBlks=defIndexBlks(~isempty(defIndexBlks));
    defIndexBlks=[defIndexBlks{:}]';


    slIndexBlks=[indexBlks,defIndexBlks];

    slIndexBlks=get_param(slIndexBlks(cellfun(@(x)~Advisor.Utils.Simulink.isBlockCommented(x),slIndexBlks)),'Object');


    sfIndexBlks=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,{'-isa','Stateflow.Chart','-or',...
    '-isa','Stateflow.EMFunction','-or','-isa','Stateflow.TruthTable'},true);


    entities=[slIndexBlks;sfIndexBlks];

end