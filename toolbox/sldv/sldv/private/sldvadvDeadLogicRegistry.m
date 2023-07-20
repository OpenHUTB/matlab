function rec=sldvadvDeadLogicRegistry()




    options.objectiveTypes='Any';
    options.objectiveStatus='Dead Logic';
    options.MessageCatalog='Sldv:ModelAdvisor:Dead_Logic';
    options.sldvOpts={'DetectDeadLogic','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.deadlogic',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Dead_Logic:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Dead_Logic:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.deadlogic';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end