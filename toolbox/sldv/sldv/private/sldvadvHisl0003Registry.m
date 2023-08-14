function rec=sldvadvHisl0003Registry()




    options.objectiveTypes='Hisl_0003';
    options.MessageCatalog='Sldv:ModelAdvisor:Hisl_0003';
    options.sldvOpts={'DetectHISMViolationsHisl_0003','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.hismviolationshisl_0003',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Hisl_0003:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Hisl_0003:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.hismviolationshisl_0003';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});
end
