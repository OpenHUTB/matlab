function rec=sldvadvDSMAccessViolationsRegistry()




    options.objectiveTypes={'Read-before-write','Write-after-read','Write-after-write'};
    options.MessageCatalog='Sldv:ModelAdvisor:DSMAccessViolations';
    options.sldvOpts={'DetectDSMAccessViolations','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.dsmaccessviolations',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:DSMAccessViolations:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:DSMAccessViolations:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.dsmaccessviolations';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});

end