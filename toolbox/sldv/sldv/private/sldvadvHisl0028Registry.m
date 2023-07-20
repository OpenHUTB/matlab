function rec=sldvadvHisl0028Registry()




    options.objectiveTypes='Hisl_0028';
    options.MessageCatalog='Sldv:ModelAdvisor:Hisl_0028';
    options.sldvOpts={'DetectHISMViolationsHisl_0028','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.hismviolationshisl_0028',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Hisl_0028:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Hisl_0028:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.hismviolationshisl_0028';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});
end
