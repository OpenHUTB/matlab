classdef ObserverInterface






    methods(Static)

        function clientMap=createClientMap(clients)
            clientMap=Simulink.sdi.Map('char','int32 vector');
            if~isempty(clients)
                for idx=1:clients.Count
                    client=get(clients,idx);
                    sigInfo=client.SignalInfo;
                    if~isempty(sigInfo)
                        hash=sigInfo.getHash();
                        idxArray=idx;

                        if clientMap.isKey(hash)
                            idxArray=[idxArray,clientMap.getDataByKey(hash)];%#ok<AGROW>
                        end
                        clientMap.insert(hash,idxArray);
                    end
                end
            end
        end

        function sigMap=createSignalMap(instSigs)
            sigMap=Simulink.sdi.Map('char','int32');
            if~isempty(instSigs)
                for i=1:instSigs.Count
                    sigInfo=get(instSigs,i);
                    hash=sigInfo.getHash();
                    sigMap.insert(hash,i);
                end
            end
        end

        function addObservers(mdl,signals)
            clients=get_param(mdl,'StreamingClients');
            if isempty(clients)
                clients=Simulink.HMI.StreamingClients(mdl);
            end
            instSigs=get_param(mdl,'InstrumentedSignals');
            if isempty(instSigs)
                instSigs=Simulink.HMI.InstrumentedSignals(mdl);
            end
            clientsMap=Simulink.sdi.internal.ObserverInterface.createClientMap(clients);
            sigMap=Simulink.sdi.internal.ObserverInterface.createSignalMap(instSigs);
            sigs=Simulink.HMI.SignalSpecification.empty();
            tempClients=Simulink.HMI.SignalClient.empty();
            for i=1:length(signals)
                signal=signals(i);
                hash=signal.getHash();
                if~clientsMap.isKey(hash)
                    if~sigMap.isKey(hash)

                        signal.MaxPoints_=1024;
                        sigs(end+1)=signal;%#ok<AGROW>
                    end
                end
            end
            if~isempty(sigs)
                for i=1:length(sigs)
                    add(instSigs,sigs(i));
                end

                try
                    bpath=sigs(end).BlockPath.getBlock(1);
                    lastSubSys=get_param(bpath,'Parent');
                catch me %#ok<NASGU>
                    lastSubSys='';
                end

                Simulink.sdi.internal.setInstrumentedSignalsWithUndo(mdl,instSigs,lastSubSys);
            end
            if~isempty(tempClients)
                for i=1:length(tempClients)
                    add(clients,tempClients(i));
                end
                set_param(mdl,'StreamingClients',clients);
            end
        end


        function deleteObservers(mdl,signals)
            clients=get_param(mdl,'StreamingClients');
            instSigs=get_param(mdl,'InstrumentedSignals');
            clientsMap=Simulink.sdi.internal.ObserverInterface.createClientMap(clients);
            sigMap=Simulink.sdi.internal.ObserverInterface.createSignalMap(instSigs);
            clientIdxs=[];
            sigIdxs=[];
            portHandles=zeros(1,length(signals));
            lastSubSys='';
            for i=1:length(signals)
                signal=signals(i);
                portHandles(i)=signal.PortHandle;
                if isa(signal,'Simulink.HMI.SignalSpecification')
                    hash=signal.getHash();
                else
                    hash=[num2str(signal.BlockHandle,64),'$$',int2str(signal.PortIndex)];
                end
                if clientsMap.isKey(hash)
                    clientIdxs=[clientIdxs,clientsMap.getDataByKey(hash)];%#ok<AGROW>
                end
                if sigMap.isKey(hash)
                    sigIdxs=[sigIdxs,sigMap.getDataByKey(hash)];%#ok<AGROW>
                end

                try
                    lastSubSys=get_param(signal.BlockHandle,'Parent');
                catch me %#ok<NASGU>
                    lastSubSys='';
                end
            end
            clientIdxs=sort(clientIdxs,2,'descend');
            for idx=1:length(clientIdxs)
                clientIdx=clientIdxs(idx);
                remove(clients,clientIdx);
                if~clients.Count
                    clients=[];
                    break;
                end
            end
            sigIdxs=sort(sigIdxs,2,'descend');
            for idx=1:length(sigIdxs)
                sigIdx=sigIdxs(idx);
                remove(instSigs,sigIdx);
                if~instSigs.Count
                    instSigs=[];
                    break;
                end
            end
            set_param(mdl,'StreamingClients',clients);
            Simulink.sdi.internal.setInstrumentedSignalsWithUndo(mdl,instSigs,lastSubSys);
            locRemovePortLoggingFlag(portHandles);
        end


        function addObserver(mdl,sigInfo,addToAxes)


            if nargin<3
                addToAxes=[];
            end
            addToAxes=uint32(addToAxes);
            import Simulink.sdi.internal.ObserverInterface;
            [idxs,~]=ObserverInterface.getClientIndex(mdl,sigInfo);
            if isempty(idxs)
                sig=ObserverInterface.instrumentModel(sigInfo);
                mdlPath=ObserverInterface.getModelBlockPath(sigInfo.BlockPath);
                client=ObserverInterface.createClient(mdl,sig,mdlPath,addToAxes);
                clients=get_param(mdl,'StreamingClients');
                if isempty(clients)
                    clients=Simulink.HMI.StreamingClients(mdl);
                end
                for i=1:length(client)
                    add(clients,client(i));
                end
                set_param(mdl,'StreamingClients',clients);
            end
        end


        function deleteObserver(mdl,sigObs,supportUndo)
            if nargin<3
                supportUndo=true;
            end


            import Simulink.sdi.internal.ObserverInterface;
            [idxs,~]=ObserverInterface.getClientIndex(mdl,sigObs);


            idxs=flipud(idxs(:));


            clients=get_param(mdl,'StreamingClients');
            for obsIdx=1:length(idxs)
                idx=idxs{obsIdx};
                remove(clients,idx);
                if~clients.Count
                    clients=[];
                end
            end
            set_param(mdl,'StreamingClients',clients);


            sigs=get_param(mdl,'InstrumentedSignals');
            if(~isempty(sigs))
                idx=ObserverInterface.getInstrumentedSignalIdx(sigObs,sigs);
                if(idx~=0)
                    remove(sigs,idx);
                    if~sigs.Count
                        sigs=[];
                    end
                    if supportUndo
                        Simulink.sdi.internal.setInstrumentedSignalsWithUndo(mdl,sigs);
                    else
                        set_param(mdl,'InstrumentedSignals',sigs);
                    end
                end
            end
        end


        function[foundIndices,sigId]=getClientIndex(mdl,sigInfo,observerType)


            import Simulink.sdi.internal.ObserverInterface;

            obsTypes={ObserverInterface.ObserverType,'database_observer',...
            'adapted_database_observer'};

            if nargin>2&&~isequal(observerType,ObserverInterface.ObserverType)
                obsTypes=observerType;
            end

            foundIndices={};
            sigIds={};
            sigId='';
            clients=get_param(mdl,'StreamingClients');
            if~isempty(clients)
                len=clients.Count;
                for idx=1:len
                    client=get(clients,idx);
                    if ismember(client.ObserverType,obsTypes)
                        sig=client.SignalInfo;
                        if~isempty(sig)&&...
                            sig.OutputPortIndex==sigInfo.OutputPortIndex&&...
                            isequal(getFullSignalPath(client),sigInfo.BlockPath)
                            foundIndices{end+1}=idx;%#ok<AGROW>
                            sigIds{end+1}=client.SignalUUID_;%#ok<AGROW>
                        end
                    end
                end
            end

            if~isempty(sigIds)
                uniqueSigIds=unique(sigIds);



                sigId=uniqueSigIds{1};
            end
        end

    end

    methods(Static,Hidden)


        function sig=instrumentModel(sigInfo,supportUndo,refreshPorts)





            if nargin<2
                supportUndo=true;
            end

            if nargin<3
                refreshPorts=true;
            end

            import Simulink.SimulationData.BlockPath;
            len=getLength(sigInfo.BlockPath);
            sigBlk=getBlock(sigInfo.BlockPath,len);
            bpath=Simulink.BlockPath(sigInfo.BlockPath,sigInfo.BlockPath.SubPath);
            mdl=BlockPath.getModelNameForPath(sigBlk);
            maxPts=1024;


            sigs=get_param(mdl,'InstrumentedSignals');
            if isempty(sigs)
                sigs=Simulink.HMI.InstrumentedSignals(mdl);
            end


            import Simulink.sdi.internal.ObserverInterface;
            idx=ObserverInterface.getInstrumentedSignalIdx(sigInfo,sigs);
            if(idx~=0)
                sig=get(sigs,idx);
                return;
            end


            try
                subSys=get_param(sigBlk,'Parent');
            catch me %#ok<NASGU>
                subSys='';
            end


            sig=Simulink.HMI.SignalSpecification;
            sig.BlockPath=bpath;
            sig.OutputPortIndex=sigInfo.OutputPortIndex;
            if sig.BlockPath.getLength()>0
                try
                    blkH=get_param(sig.BlockPath.getBlock(1),'handle');
                    sig.CachedBlockHandle_=blkH;
                    sig.CachedPortIdx_=double(sigInfo.OutputPortIndex);
                catch
                end
            end
            sig.MaxPoints_=maxPts;
            add(sigs,sig);
            if~supportUndo&&~refreshPorts
                set_param(mdl,'InstrumentedSignalsNoRefresh',sigs);
            elseif supportUndo
                Simulink.sdi.internal.setInstrumentedSignalsWithUndo(mdl,sigs,subSys);
            elseif~refreshPorts
                Simulink.sdi.internal.setInstrumentedSignalsWithUndo(mdl,sigs,subSys,false);
            else
                set_param(mdl,'InstrumentedSignals',sigs);
            end
        end


        function mdlBlk=getModelBlockPath(bpath)


            len=getLength(bpath);
            if len<2
                mdlBlk=Simulink.BlockPath({});
            else
                import Simulink.HMI.BlockPathUtils;
                [mdlPath,mdlSID]=...
                BlockPathUtils.getPathMetaData(bpath);
                mdlPath=mdlPath(1:end-1);
                mdlSID=mdlSID(1:end-1);
                mdlBlk=BlockPathUtils.createPathFromMetaData(...
                mdlPath,mdlSID,'');
            end
        end


        function client=createClient(mdl,sig,mdlPath,addToAxes)



            client=[];

            if isempty(addToAxes)
                return
            end

            client=Simulink.HMI.SignalClient;
            client.SignalInfo=sig;
            client.ReferenceModel=mdlPath;
            client.ObserverType_=Simulink.sdi.internal.ObserverInterface.ObserverType;
            client.UpdateRate_=1;


            client.ObserverParams=...
            Simulink.HMI.AsyncQueueObserverAPI.getDefaultObserverParams(...
            client(end).ObserverType);
            client.ObserverParams.LineSettings.Axes=addToAxes;
        end


        function idx=getInstrumentedSignalIdx(sigInfo,sigs)
            idx=0;
            bpath=Simulink.BlockPath(sigInfo.BlockPath,sigInfo.BlockPath.SubPath);
            try
                sid=sigInfo.SID_;
            catch me %#ok<NASGU>
                sid='';
            end
            len=sigs.Count;
            for i=1:len
                sig=get(sigs,i);
                if isempty(sid)
                    if sig.OutputPortIndex==sigInfo.OutputPortIndex&&...
                        isequal(sig.BlockPath,bpath)
                        idx=i;
                        return;
                    end
                else
                    if sig.OutputPortIndex==sigInfo.OutputPortIndex&&...
                        (isequal(sig.BlockPath,bpath)||...
                        isequal(sig.SID_,sid))
                        idx=i;
                        return;
                    end
                end

            end
        end
    end


    properties(Constant)
        ObserverType='webclient_observer';
    end

end


function locRemovePortLoggingFlag(ports)
    set(ports,'DataLogging','off');
end


