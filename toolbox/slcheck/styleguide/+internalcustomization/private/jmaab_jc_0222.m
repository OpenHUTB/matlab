function jmaab_jc_0222






    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(1).subcheck.InitParams.CheckName='jc_0222_a';
    SubCheckCfg(1).subcheck.InitParams.RegValue='[^a-z_A-Z_0-9]';
    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(2).subcheck.InitParams.CheckName='jc_0222_b';
    SubCheckCfg(2).subcheck.InitParams.RegValue='^[0-9]';
    SubCheckCfg(3).Type='Normal';
    SubCheckCfg(3).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(3).subcheck.InitParams.CheckName='jc_0222_c';
    SubCheckCfg(3).subcheck.InitParams.RegValue='^_';
    SubCheckCfg(4).Type='Normal';
    SubCheckCfg(4).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(4).subcheck.InitParams.CheckName='jc_0222_d';
    SubCheckCfg(4).subcheck.InitParams.RegValue='_$';
    SubCheckCfg(5).Type='Normal';
    SubCheckCfg(5).subcheck.ID='slcheck.jmaab.NamingFormat';
    SubCheckCfg(5).subcheck.InitParams.CheckName='jc_0222_e';
    SubCheckCfg(5).subcheck.InitParams.RegValue='[_][_]';
    SubCheckCfg(6).Type='Normal';
    SubCheckCfg(6).subcheck.ID='slcheck.jmaab.IsAKeyWord';
    SubCheckCfg(6).subcheck.InitParams.CheckName='jc_0222_f';


    rec=slcheck.Check('mathworks.jmaab.jc_0222',...
    SubCheckCfg,...
    {sg_jmaab_group,sg_maab_group});

    rec.LicenseString=styleguide_license;

    rec.relevantEntities=@getRelevantEntity;

    rec.setDefaultInputParams();
    rec.register();

end

function entities=getRelevantEntity(system,FollowLinks,LookUnderMasks)



    signals=find_system(system,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,...
    'Type','line');
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    signals=mdladvObj.filterResultWithExclusion(signals);

    slObjs=get_param(signals,'Object');

    if~iscell(slObjs)
        slObjs=num2cell(slObjs);
    end

    [~,indices]=unique(cell2mat(cellfun(@(x)x.SrcBlockHandle,slObjs,'UniformOutput',false)));
    slObjs=slObjs(indices);

    slObjs=slObjs(cellfun(@(x)Advisor.Utils.Naming.verifySignal(x.Handle),slObjs));

    entities=cellfun(@(x)x.Handle,slObjs,'UniformOutput',false);

end
