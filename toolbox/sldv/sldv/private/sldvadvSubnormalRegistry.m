function rec=sldvadvSubnormalRegistry()




    options.objectiveTypes='Subnormal value';
    options.MessageCatalog='Sldv:ModelAdvisor:Subnormal';
    options.sldvOpts={'DetectSubnormal','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.subnormal',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Subnormal:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Subnormal:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.subnormal';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end