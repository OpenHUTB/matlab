classdef LazyLoadDataHandlerActionBase<handle




    methods

        function info=addDataToDBSignal(this,hImportToJetStream,dataInfo,currentMemberID,clientID)


            info=this.createNewSignalForData(hImportToJetStream,dataInfo,clientID);
        end
    end



    methods(Access=protected)

        function info=createNewSignalForData(this,hImportToJetStream,dataInfo,clientID)
            metaStruct=this.getMetaStruct(dataInfo.mode,dataInfo.Fs,dataInfo.Ts,dataInfo.St,dataInfo.Tv,clientID);
            info=updateRepository(hImportToJetStream,...
            dataInfo.varsToImport,false,clientID,'MetaStructure',metaStruct,'SigVals',dataInfo.dataToImport);
        end

        function info=updateDataInParentSignal(this,hImportToJetStream,parentSignalID,dataInfo)

            info.success=false;
            parentSignalID=int32(parentSignalID);
            jetStreamEngine=getJetStreamEngine(this,hImportToJetStream);
            sigData=createSigDataFromDataInfo(this,dataInfo);
            parentSigObj=jetStreamEngine.getSignalObject(parentSignalID);
            parentSigObj.Values=sigData;
            avgSampleRate=getAvgSampleRate(this,sigData.Time);
            jetStreamEngine.setSignalTmAvgSampleRate(parentSignalID,avgSampleRate,false);
            jetStreamEngine.setSignalTmNumPoints(parentSignalID,length(sigData.Time));
            jetStreamEngine.setSignalTmTimeRange(parentSignalID,[sigData.Time(1),sigData.Time(end)]);
            info.success=true;
        end

        function y=createSigDataFromDataInfo(~,dataInfo)



            y=struct('Data',[],'Time',[]);
        end

        function y=getAvgSampleRate(~,timeVector)
            y=signal.internal.utilities.getEffectiveFs(sort(timeVector),false);
        end

        function y=getJetStreamEngine(~,hImportToJetStream)
            y=hImportToJetStream.engine;
        end

        function y=getJetStreamSigRepository(~,hImportToJetStream)
            y=hImportToJetStream.engine.sigRepository;
        end

        function y=getMetaStruct(~,mode,Fs,Ts,St,Tv,clientID)
            y=signal.sigappsshared.Utilities.getMetaStruct(mode,Fs,Ts,St,Tv,clientID);
        end
    end
end
