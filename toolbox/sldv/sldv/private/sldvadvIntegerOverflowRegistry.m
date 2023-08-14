function rec=sldvadvIntegerOverflowRegistry()




    options.objectiveTypes='Overflow';
    options.MessageCatalog='Sldv:ModelAdvisor:Integer_Overflow';
    options.sldvOpts={'DetectIntegerOverflow','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.integeroverflow',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Integer_Overflow:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Integer_Overflow:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.integeroverflow';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end