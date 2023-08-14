function styleguide_jc_0021

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.jc_0021',true,[],'None');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    rec.setLicense({styleguide_license});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,sg_maab_group);
end