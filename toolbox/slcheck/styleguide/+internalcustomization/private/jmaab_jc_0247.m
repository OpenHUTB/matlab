function jmaab_jc_0247






    checkID='jc_0247';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.jmaab.jc_0247');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.Value=true;
    rec.SupportsEditTime=true;
    rec.setLicense({styleguide_license});

    [inputParamList,gridLayout]=Advisor.Utils.Naming.getLengthRestrictionInputParams('JMAAB');
    rec.setInputParametersLayoutGrid(gridLayout);
    rec.setInputParameters(inputParamList);
    rec.setInputParametersCallbackFcn(@Advisor.Utils.Naming.inputParam_NameLength);


    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end

