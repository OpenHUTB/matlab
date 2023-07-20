function jmaab_jc_0792

    SubCheckCfg(1).Type='Normal';
    SubCheckCfg(1).subcheck.ID='slcheck.jmaab.jc_0792_a';

    SubCheckCfg(2).Type='Normal';
    SubCheckCfg(2).subcheck.ID='slcheck.jmaab.jc_0792_b';

    rec=slcheck.Check('mathworks.jmaab.jc_0792',SubCheckCfg,{sg_maab_group,sg_jmaab_group});


    rec.relevantEntities=@getRelevantBlocks;

    rec.setDefaultInputParams(false);

    rec.LicenseString=styleguide_license;
    rec.register();

end

function entities=getRelevantBlocks(system,~,~)
    entities=num2cell(Simulink.findVars(bdroot(system),'SearchMethod','cached','FindUsedVars',false,'IncludeEnumTypes','on'));
end