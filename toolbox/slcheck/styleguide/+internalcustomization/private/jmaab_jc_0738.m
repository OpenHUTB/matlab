function jmaab_jc_0738


    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0738_a';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0738_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0738',...
    SubCheckCfg,...
    {sg_maab_group,sg_jmaab_group});

    rec.LicenseString={styleguide_license,'Stateflow'};

    rec.relevantEntities=@getSfElements;
    rec.setDefaultInputParams();
    rec.register();
end


function sfElements=getSfElements(system,FollowLinks,LookUnderMasks)
    sfElements=[];
    sfCharts=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks,LookUnderMasks,...
    {'-isa','Stateflow.Chart','-and','ActionLanguage','C'});

    if isempty(sfCharts)
        return;
    end

    sfElements=cellfun(@(x)x.find('-isa','Stateflow.State','-or',...
    '-isa','Stateflow.Transition'),sfCharts,'UniformOutput',false);

    sfElements=vertcat(sfElements{:});
    sfElements=arrayfun(@(x)x,sfElements,'UniformOutput',false);
end