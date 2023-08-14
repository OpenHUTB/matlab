function rec=sldvadvHisl0004Registry()




    options.objectiveTypes='Hisl_0004';
    options.MessageCatalog='Sldv:ModelAdvisor:Hisl_0004';
    options.sldvOpts={'DetectHISMViolationsHisl_0004','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.hismviolationshisl_0004',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Hisl_0004:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Hisl_0004:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.hismviolationshisl_0004';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});
end
