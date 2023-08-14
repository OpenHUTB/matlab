


function jmaab_jc_0281

    SubCheckCfg(1).Type='Group';
    SubCheckCfg(1).GroupName='jc_0281_a';
    SubCheckCfg(1).subcheck(1).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(1).subcheck(1).InitParams.Name='jc_0281_a1';
    SubCheckCfg(1).subcheck(1).InitParams.Mode=1;
    SubCheckCfg(1).subcheck(1).InitParams.Stateflow=false;
    SubCheckCfg(1).subcheck(2).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(1).subcheck(2).InitParams.Name='jc_0281_a2';
    SubCheckCfg(1).subcheck(2).InitParams.Mode=2;
    SubCheckCfg(1).subcheck(2).InitParams.Stateflow=false;
    SubCheckCfg(1).subcheck(3).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(1).subcheck(3).InitParams.Name='jc_0281_a3';
    SubCheckCfg(1).subcheck(3).InitParams.Mode=3;
    SubCheckCfg(1).subcheck(3).InitParams.Stateflow=false;
    SubCheckCfg(1).subcheck(4).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(1).subcheck(4).InitParams.Name='jc_0281_a4';
    SubCheckCfg(1).subcheck(4).InitParams.Mode=4;
    SubCheckCfg(1).subcheck(4).InitParams.Stateflow=false;

    SubCheckCfg(2).Type='Group';
    SubCheckCfg(2).GroupName='jc_0281_b';
    SubCheckCfg(2).subcheck(1).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(2).subcheck(1).InitParams.Name='jc_0281_b1';
    SubCheckCfg(2).subcheck(1).InitParams.Mode=1;
    SubCheckCfg(2).subcheck(1).InitParams.Stateflow=true;
    SubCheckCfg(2).subcheck(2).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(2).subcheck(2).InitParams.Name='jc_0281_b2';
    SubCheckCfg(2).subcheck(2).InitParams.Mode=2;
    SubCheckCfg(2).subcheck(2).InitParams.Stateflow=true;
    SubCheckCfg(2).subcheck(3).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(2).subcheck(3).InitParams.Name='jc_0281_b3';
    SubCheckCfg(2).subcheck(3).InitParams.Mode=3;
    SubCheckCfg(2).subcheck(3).InitParams.Stateflow=true;
    SubCheckCfg(2).subcheck(4).ID='slcheck.jmaab.subcheck_jc_0281';
    SubCheckCfg(2).subcheck(4).InitParams.Name='jc_0281_b4';
    SubCheckCfg(2).subcheck(4).InitParams.Mode=4;
    SubCheckCfg(2).subcheck(4).InitParams.Stateflow=true;

    rec=slcheck.Check('mathworks.jmaab.jc_0281',SubCheckCfg,{sg_jmaab_group,sg_maab_group});

    rec.relevantEntities=@getTriggerBlocks;

    rec.setDefaultInputParams();

    rec.LicenseString={styleguide_license,'Stateflow'};
    rec.register();
end

function triggerBlocks=getTriggerBlocks(system,FollowLinks,LookUnderMasks)

    triggerBlocks=[];



    blocksSL=find_system(get_param(system,'handle'),...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,...
    'LookUnderMasks',LookUnderMasks,...
    'BlockType','TriggerPort',...
    'IsSimulinkFunction','off');

    charts=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Chart'});

    blocksSF=[];
    if~isempty(charts)
        trigPorts=cellfun(@(x)Stateflow.SLUtils.findSystem(...
        sfprivate('chart2block',x.Id),'BlockType','TriggerPort'),...
        charts,'UniformOutput',false);

        trigPorts=trigPorts(~cellfun('isempty',trigPorts));

        blocksSF=zeros(length(trigPorts),1);
        for idx=1:numel(trigPorts)
            if~isempty(trigPorts{idx})
                blocksSF(idx)=trigPorts{idx};
            end
        end
    end

    if iscell(blocksSF)
        blocksSF=blocksSF{:};
    end

    blks=[blocksSL;blocksSF];

    if~isempty(blks)




        sysObj=get_param(system,'Object');
        sfSLFuncs=sysObj.find('-isa','Stateflow.SLFunction');


        sfSLFuncNames=...
        arrayfun(@(x)[x.Path,'.',x.Name],sfSLFuncs,'UniformOutput',false);



        sfSLFuncNames1=...
        arrayfun(@(x)[x.Path,'/',x.Name],sfSLFuncs,'UniformOutput',false);
        blkObj=get_param(blks,'object');
        if~iscell(blkObj)
            blkObj={blkObj};
        end
        blks=blks(cellfun(@(x)(~ismember(x.Parent,sfSLFuncNames)&&~ismember(x.Parent,sfSLFuncNames1)),blkObj));
        triggerBlocks=num2cell(blks);
    end
end


