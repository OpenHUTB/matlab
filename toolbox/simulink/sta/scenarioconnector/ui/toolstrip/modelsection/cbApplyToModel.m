function[DID_APPLY,errMsg]=cbApplyToModel(inputSpecID,signalID,modelToApplyTo)




    DID_APPLY=false;
    errMsg='';



    cs=getActiveConfigSet(modelToApplyTo);

    if isa(cs,'Simulink.ConfigSetRef')
        errMsg=DAStudio.message('sl_sta:mapping:configsetrefNoMark',modelToApplyTo);
        return;
    end


    inputSpec=sta.InputSpecification(inputSpecID);

    aFactory=starepository.repositorysignal.Factory;


    concreteExtractor=aFactory.getSupportedExtractor(signalID);
    [Signals.Data{1},Signals.Names{1}]=concreteExtractor.extractValue(signalID);

    assignVarToWorkspace(Signals,Signals.Names);


    setExternalInput(modelToApplyTo,inputSpec.InputString);
    DID_APPLY=true;