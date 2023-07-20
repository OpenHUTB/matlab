function rec=sldvadvInfNaNRegistry()




    options.objectiveTypes={'Inf value','NaN value'};
    options.MessageCatalog='Sldv:ModelAdvisor:InfNaN';
    options.sldvOpts={'DetectInfNaN','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.infnan',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:InfNaN:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:InfNaN:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.infnan';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end