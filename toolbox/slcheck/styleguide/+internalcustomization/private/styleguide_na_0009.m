function styleguide_na_0009

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.na_0009',false,@(system)ModelAdvisor.internal.checkSignalPropagation(system,false),'None');
    rec.SupportLibrary=false;

    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.maab.na_0009';

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='graphical';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    rec.setLicense({styleguide_license});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,sg_maab_group);
end

