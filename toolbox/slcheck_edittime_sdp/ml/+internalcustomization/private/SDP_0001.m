function SDP_0001



    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.codegen.cgsl_0401');
    rec.Title=DAStudio.message('ModelAdvisor:sdp:cgsl_0401_title');
    rec.TitleTips=[DAStudio.message('ModelAdvisor:sdp:cgsl_0401_title'),newline,newline,DAStudio.message('ModelAdvisor:sdp:cgsl_0401_guideline')];


    rec.SupportLibrary=false;
    rec.SupportExclusion=false;
    rec.SupportHighlighting=true;
    rec.Value=false;
    rec.SupportsEditTime=true;
    rec.CallbackContext='PostCompile';
    rec.LicenseName={'RTW_Embedded_Coder'};
    rec.CSHParameters.MapKey='ma.ecoder';
    rec.CSHParameters.TopicID='cgsl_0401';







    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sdp_checks});
end
