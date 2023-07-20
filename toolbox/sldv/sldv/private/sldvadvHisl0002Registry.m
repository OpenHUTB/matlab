function rec=sldvadvHisl0002Registry()




    options.objectiveTypes='Hisl_0002';
    options.MessageCatalog='Sldv:ModelAdvisor:Hisl_0002';
    options.sldvOpts={'DetectHISMViolationsHisl_0002','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.hismviolationshisl_0002',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Hisl_0002:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Hisl_0002:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.hismviolationshisl_0002';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});
end
