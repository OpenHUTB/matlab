function rec=sldvadvBlockInputRangeViolationsRegistry()




    options.objectiveTypes='Block input range violation';
    options.MessageCatalog='Sldv:ModelAdvisor:BlockInputRangeViolations';
    options.sldvOpts={'DetectBlockInputRangeViolations','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.blockinputrangeviolations',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:BlockInputRangeViolations:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:BlockInputRangeViolations:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.blockinputrangeviolations';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end