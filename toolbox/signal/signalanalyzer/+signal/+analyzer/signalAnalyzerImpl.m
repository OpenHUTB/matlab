function signalAnalyzerImpl(Fs,Ts,St,Tv,mode,sigNames,sigVals)



    if signal.analyzer.WebGUI.debugMode()
        appname='sa-debug';
    else
        appname='sa';
    end

    engine=Simulink.sdi.Instance.engine;

    appStateCtrl=signal.analyzer.controllers.AppState.getController();

    if~isempty(sigNames)&&appStateCtrl.isPreprocessingModeSA()


        error(message('SDI:sigAnalyzer:ImportErrorWhenPreprocessingModeActive'));
    end



    while~signal.analyzer.Instance.isSDIRunning()&&...
        ~isempty(Simulink.sdi.WebClient.getAllClients(appname))
        Simulink.sdi.WebClient.disconnectAllClients;
    end


    if~signal.analyzer.Instance.isSDIRunning()
        if signal.analyzer.controllers.Scalogram.haveWaveletToolBox()
            signal.analyzer.WebGUI.haveWaveletToolbox(true);
        end
        signal.analyzer.Instance.open();
    end

    clients=[];
    signalAnalyzerClient=[];
    status=[];


    while isempty(clients)||~all(strcmp(status,'connected'))||...
        ~Simulink.sdi.WebClient.appIsConnected(appname)||...
        isempty(appStateCtrl.getSignalAnalyzerClientID())

        clients=Simulink.sdi.WebClient.getAllClients(appname);
        [status{1:size(clients,2)}]=clients.Status;
        if~isempty(clients)
            if isempty(appStateCtrl.getSignalAnalyzerClientID())



                appStateCtrl.setSignalAnalyzerClientID(clients(end).ClientID);
                appStateCtrl.setSignalAnalyzerActiveAppFlag(true);


                signal.analyzer.Instance.createLabelRepository();
            end

            signalAnalyzerClient=getSignalAnalyzerClient(clients,appStateCtrl);
        end
    end

    if isempty(sigNames)&&isempty(sigVals)
        return;
    end


    hApp=signal.analyzer.Instance.getMainGUI;


    metaStruct=getMetaStruct(signalAnalyzerClient.ClientID,mode,Fs,Ts,St,Tv);


    clients=Simulink.sdi.WebClient.getAllClients(appname);
    signalAnalyzerClient=getSignalAnalyzerClient(clients,appStateCtrl);

    selectedDisplay=Simulink.sdi.getSelectedPlot(engine.sigRepository);
    contFlag=true;
    count=0;
    while contFlag
        if~isempty(clients)&&~isempty(signalAnalyzerClient)&&~isempty(signalAnalyzerClient.Axes)
            selectedAxes=signalAnalyzerClient.Axes([signalAnalyzerClient.Axes.AxisID]==selectedDisplay);
            if~isempty(selectedAxes)
                contFlag=false;
                if count>0



                    pause(1);
                end
            end
        else
            pause(1);
        end

        count=count+1;
        if(count>60)
            contFlag=false;
        end
        drawnow;
    end





    hImport=signal.analyzer.controllers.ImportFromDrop.getController();
    updateRepository(hImport,sigNames,true,...
    str2double(signalAnalyzerClient.ClientID),true,...
    'MetaStructure',metaStruct,'SigVals',sigVals);






    clients=Simulink.sdi.WebClient.getAllClients(appname);
    selectedDisplay=Simulink.sdi.getSelectedPlot(engine.sigRepository);
    contFlag=true;
    count=0;

    while contFlag
        if~isempty(clients)&&~isempty(signalAnalyzerClient)&&~isempty(signalAnalyzerClient.Axes)
            selectedAxes=signalAnalyzerClient.Axes([signalAnalyzerClient.Axes.AxisID]==selectedDisplay);
            if~isempty(selectedAxes)&&~isempty(selectedAxes.DatabaseIDs)
                contFlag=false;
                if count>0



                    pause(1);
                end
            end
        end

        count=count+1;
        if(count>1000)
            contFlag=false;
        end
        drawnow;
    end


    hApp.bringToFront;

end


function signalAnalyzerClient=getSignalAnalyzerClient(clients,appStateCtrl)
    signalAnalyzerClient=[];
    if~isempty(clients)

        for idx=1:length(clients)
            if clients(idx).ClientID==appStateCtrl.getSignalAnalyzerClientID()
                signalAnalyzerClient=clients(idx);
            end
        end
    end
end


function args=getMetaStruct(clientID,mode,Fs,Ts,St,Tv)



    switch mode
    case 'fs'
        startTime=St;
        sampleTimeOrRate=Fs;
        timeVector='';
    case 'ts'
        startTime=St;
        sampleTimeOrRate=Ts;
        timeVector='';
    case 'samples'
        startTime='';
        sampleTimeOrRate='';
        timeVector='';
    case 'tv'
        startTime='';
        sampleTimeOrRate='';
        timeVector=Tv;
    case 'inherent'
        startTime='';
        sampleTimeOrRate='';
        timeVector='';
    end

    data.startTime=startTime;
    data.signalIDs=[];
    data.tmMode=mode;
    data.runIDs=[];
    data.clientID=str2double(clientID);
    data.sampleTimeOrRate=sampleTimeOrRate;
    data.timeVector=timeVector;

    opts.appName="SignalAnalyzer";
    opts.reImportExistingVarNames=true;
    opts.warnIfExceedsMaxNumColumns=true;

    args.clientID=clientID;
    args.data=data;
    args.opts=opts;
end