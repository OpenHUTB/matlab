function rec=sldvadvCompatibilityRegistry()



    rec=ModelAdvisor.Check('mathworks.sldv.compatibility');

    rec.Title=getString(message('Sldv:ModelAdvisor:Compatibility:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Compatibility:TitleTips'));
    rec.CallbackHandle=@sldvadvCompatibilityDisplay;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleOne';
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.compatibility';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});