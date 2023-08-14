function[varName,rootData]=exportToDataset(this,runIDs,sigIDs,app,varName)






    assert(~isempty(varName)&&ischar(varName));


    rootData=Simulink.SimulationData.Dataset;
    rootData.Name=varName;
    runIsRoot=(length(runIDs)==1)&&(isempty(sigIDs));


    switch app
    case 'SDI'
        isActiveAppSDI=true;
    case 'Comparison'
        isActiveAppSDI=false;
    otherwise

        assert(false);
    end



    if isActiveAppSDI&&isempty(sigIDs)
        sigIDs=Simulink.sdi.internal.Util.findAllLeafSigIDsForAllTheseSignals(...
        this.sigRepository,sigIDs);
    end



    if runIsRoot
        switch app
        case 'SDI'
            if this.isValidRunID(runIDs(1))
                rootData=this.getRunData(runIDs(1));
            end
        case 'Comparison'
            assert(length(runIDs)==1);
            if this.isValidRunID(runIDs(1))
                rootData=this.getComparisonData(runIDs(1));
            end
        end
        return
    end


    for iRun=1:length(runIDs)
        if this.isValidRunID(runIDs(iRun))
            runData=this.getRunData(runIDs(iRun));
            rootData=rootData.addElement(runData,this.getRunName(runIDs(iRun)));
        end
    end






    if isempty(sigIDs)
        return
    end



    sigIDs=locGetSignalIDs(this,sigIDs);

    if length(sigIDs)==1
        if this.isValidSignalID(sigIDs(1))
            if isempty(runIDs)





                switch app
                case 'SDI'
                    runNum=this.getSignalRunID(sigIDs(1));
                    if isequal(this.sigRepository.getDatasetSignalFormat(runNum),0)
                        sig=this.getSignalObject(sigIDs(1));
                        sigTimeSeries=sig.Values;
                        if isa(sigTimeSeries,'timeseries')&&isscalar(sigTimeSeries)
                            sigTimeSeries.Name=sig.SignalLabel;
                        end
                        rootData=sigTimeSeries;
                    else
                        sigTimeTable=this.exportSignalToTimeTable(sigIDs(1));
                        rootData=sigTimeTable;
                    end
                case 'Comparison'
                    comparisonData=this.exportComparisonData(sigIDs(1));
                    rootData=comparisonData.Values;
                end
            else
                assert(isActiveAppSDI);







                signalDataset=Simulink.SimulationData.Dataset;
                [sigData,~]=this.exportSignalData(sigIDs(1));
                signalDataset=signalDataset.addElement(sigData);
                rootData=rootData.addElement(signalDataset);
            end
        end
        return
    end



    signalDataset=Simulink.SimulationData.Dataset;
    if isActiveAppSDI

        opts.sigIDs=sigIDs;


        opts.runID=0;
        exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
        signalDataset=exportRun(exporter,this.sigRepository,opts,false,false);
    else

        for iSignal=1:length(sigIDs)
            signalID=sigIDs(iSignal);
            if this.isValidSignalID(signalID)
                comparisonData=this.exportComparisonData(signalID);
                signalDataset=signalDataset.addElement(comparisonData);
            end
        end
    end
    if isempty(runIDs)





        rootData=signalDataset;
        rootData.Name=varName;
    else







        rootData=rootData.addElement(signalDataset);
    end
end


function sigIDs=locGetSignalIDs(this,sigIDs)
    for idx=1:numel(sigIDs)
        if this.isValidSignalID(sigIDs(idx))
            s=Simulink.sdi.Signal(this,sigIDs(idx));
            sigIDs(idx)=s.getIDForData();
        end
    end
end