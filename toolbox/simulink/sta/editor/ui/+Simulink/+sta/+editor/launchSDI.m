function LAUNCH_SDI=launchSDI(dbId)



    LAUNCH_SDI=true;

    aFactory=starepository.repositorysignal.Factory;


    concreteExtractor=aFactory.getSupportedExtractor(dbId);
    [ds,dsLabel]=concreteExtractor.extractValue(dbId);


    Simulink.sdi.createRun(dsLabel,'vars',ds);
    Simulink.sdi.view;

end
