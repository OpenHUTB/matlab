function rec=sldvadvArrayBoundsRegistry()




    options.objectiveTypes='Array bounds';
    options.MessageCatalog='Sldv:ModelAdvisor:Array_Bounds';
    options.sldvOpts={'DetectOutOfBounds','on';
    'UseGUI',true};

    rec=ModelAdvisor.SLDVCheck('mathworks.sldv.arraybounds',options);

    rec.Title=getString(message('Sldv:ModelAdvisor:Array_Bounds:Title'));
    rec.TitleTips=getString(message('Sldv:ModelAdvisor:Array_Bounds:TitleTips'));
    rec.CSHParameters.MapKey='ma.sldv';
    rec.CSHParameters.TopicID='mathworks.sldv.arraybounds';
    rec.Value=false;
    rec.setLicense({'Simulink_Design_Verifier'});
end