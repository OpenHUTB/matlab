function jmaab_jc_0700

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jc_0700',true,[],'None');
    rec.setLicense({styleguide_license,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

