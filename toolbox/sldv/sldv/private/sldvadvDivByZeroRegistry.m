function rec=sldvadvDivByZeroRegistry()




    options.objectiveTypes='Division by zero';
    options.MessageCatalog='Sldv:ModelAdvisor:Div_By_Zero';
    options.sldvOpts={'DetectDivisionByZero','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.divbyzero',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Div_By_Zero:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Div_By_Zero:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.divbyzero';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end