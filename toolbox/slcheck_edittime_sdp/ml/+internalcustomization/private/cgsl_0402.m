function cgsl_0402



    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.codegen.cgsl_0402');
    rec.Title=DAStudio.message('ModelAdvisor:sdp:cgsl_0402_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:sdp:cgsl_0402_title'),newline,newline,DAStudio.message('ModelAdvisor:sdp:cgsl_0402_guideline')];


    rec.SupportLibrary=false;
    rec.SupportExclusion=false;
    rec.SupportHighlighting=true;
    rec.Value=false;
    rec.SupportsEditTime=true;
    rec.CallbackContext='None';
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='cgsl_0402';







    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sdp_checks});
end
