function inheritVATMdlAdvisorCheck




    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.simulink.InheritVATFromSlVarCtrlCheck');
    rec.Title=DAStudio.message('Simulink:VariantAdvisorChecks:MATitleIdentifyNonSVCBlksWithInherit');
    rec.TitleTips=DAStudio.message('Simulink:VariantAdvisorChecks:MATitletipIdentifyNonSVCBlksWithInherit');

    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;
    rec.CSHParameters.MapKey='ma.simulink';
    rec.CSHParameters.TopicID='MATitleIdentifyNonSVCBlksWithInherit';

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,'Simulink');
end
