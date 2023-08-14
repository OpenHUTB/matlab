function rec=sldvadvMinMaxRegistry()




    options.objectiveTypes='Design Range';
    options.MessageCatalog='Sldv:ModelAdvisor:Min_Max';
    options.sldvOpts={'DesignMinMaxCheck','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.minmax',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Min_Max:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Min_Max:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.minmax';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end