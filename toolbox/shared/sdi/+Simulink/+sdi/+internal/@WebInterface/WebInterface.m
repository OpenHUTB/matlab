


classdef WebInterface


    methods(Static)


        function out=setGetResetEngine(action)
            out=[];
            persistent sdiEngine;
            if strcmpi(action,'set')&&isempty(sdiEngine)
                sdiEngine=Simulink.sdi.Instance.engine;
            elseif strcmpi(action,'get')&&isempty(sdiEngine)
                sdiEngine=Simulink.sdi.Instance.engine;
                out=sdiEngine;
            elseif strcmpi(action,'get')
                out=sdiEngine;
            elseif strcmpi(action,'reset')
                clear sdiEngine;
                sdiEngine=[];
            end
        end


        function startStreaming(startTime,stopTime,clients,clientId,varargin)


            validateattributes(startTime,{'numeric'},{'scalar','finite'});
            validateattributes(stopTime,{'numeric'},{'scalar'});
            validateattributes(clients,{'cell'},{});
            validateattributes(clientId,{'char'},{});


            if isempty(varargin)
                apps={};
            else
                validateattributes(varargin{1},{'cell'},{});
                apps=varargin{1};
            end


            Simulink.sdi.internal.WebInterface.startStreamingSpecificClients(...
            startTime,stopTime,clients,clientId,apps);


            runID=uint64(0);
            if~isempty(clients)
                import Simulink.sdi.WebClient;
                import Simulink.HMI.AsyncQueueObserverAPI;
                sigID=WebClient.getSignalIDforObserver(...
                AsyncQueueObserverAPI.getUUIdFromString(clients{1}.UUID));
                runID=WebClient.getRunIDforSignal(sigID);
            end


            asyncQueueAPI=Simulink.HMI.AsyncQueueObserverAPI;
            asyncQueueAPI.launchAsyncThreads;
        end

    end


    methods(Static,Access=private)


        function startStreamingSpecificClients(startTime,stopTime,clients,clientId,apps)


            eng=Simulink.sdi.Instance.engine;


            modelInfo.Apps=apps;
            modelInfo.ClientID=clientId;


            modelInfo.StartTime=startTime;
            if isfinite(stopTime)
                modelInfo.StopTime=stopTime;
            else
                modelInfo.StopTime='InfiniteSimTime';
            end


            modelInfo.RunID=uint64(0);
            modelInfo.fixedSignalID='';
            modelInfo.model='';
            idxToRemove=[];
            modelInfo.ObsSigIDs=cell(1,length(clients));
            modelInfo.ObsUUIDs=cell(1,length(clients));
            modelInfo.ObsLabels=cell(1,length(clients));
            modelInfo.ObsEnumDefs=cell(1,length(clients));
            modelInfo.ObsLineStyles=cell(1,length(clients));
            modelInfo.ObsLineWidths=cell(1,length(clients));
            modelInfo.ObsLineColors=cell(1,length(clients));
            modelInfo.ObsAxes=cell(1,length(clients));
            import Simulink.sdi.WebClient;
            import Simulink.sdi.internal.LineSettings;
            for idx=1:length(clients)
                validateattributes(clients{idx},...
                {'Simulink.AsyncQueue.SignalClient'},{'scalar'});


                modelInfo.ObsLabels{idx}=getLabel(clients{idx});



                import Simulink.HMI.AsyncQueueObserverAPI;
                obsUUID=AsyncQueueObserverAPI.getUUIdFromString(clients{idx}.UUID);
                modelInfo.ObsUUIDs{idx}=num2str(obsUUID);
                modelInfo.ObsSigIDs{idx}=...
                WebClient.getSignalIDforObserver(obsUUID);
                if~modelInfo.ObsSigIDs{idx}
                    idxToRemove(end+1)=idx;%#ok<AGROW>
                    continue;
                end
                if~modelInfo.RunID
                    modelInfo.RunID=WebClient.getRunIDforSignal(...
                    modelInfo.ObsSigIDs{idx});
                end


                enumDefn=Simulink.sdi.SignalClient.getEnumDefinition(...
                modelInfo.ObsSigIDs{idx});
                if~isempty(enumDefn)
                    modelInfo.ObsEnumDefs(idx)=...
                    {struct('EnumValue',{enumDefn.EnumValue},...
                    'EnumLabel',{enumDefn.EnumLabel})};
                else
                    modelInfo.ObsEnumDefs(idx)=...
                    {struct('EnumValue',{int32([])},'EnumLabel',{[]})};
                end


                colorVal=eng.getSignalLineColor(modelInfo.ObsSigIDs{idx});
                modelInfo.ObsLineColors{idx}=...
                LineSettings.colorToHexString(colorVal);
                modelInfo.ObsLineStyles{idx}=...
                eng.getSignalLineDashed(modelInfo.ObsSigIDs{idx});
                modelInfo.ObsLineWidths{idx}=...
                eng.getSignalLineWidth(modelInfo.ObsSigIDs{idx});
                if isfield(clients{idx}.ObserverParams,'LineSettings')
                    numPlots=length(...
                    clients{idx}.ObserverParams.LineSettings.Axes);
                    modelInfo.ObsAxes{idx}=cell(1,numPlots);
                    for idx2=1:numPlots
                        modelInfo.ObsAxes{idx}{idx2}=...
                        clients{idx}.ObserverParams.LineSettings.Axes(idx2);
                    end
                else
                    if eng.getSignalChecked(modelInfo.ObsSigIDs{idx})
                        modelInfo.ObsAxes{idx}={1};
                    else
                        modelInfo.ObsAxes{idx}={};
                    end
                end
            end


            if~isempty(idxToRemove)
                modelInfo.ObsSigIDs(idxToRemove)=[];
                modelInfo.ObsUUIDs(idxToRemove)=[];
                modelInfo.ObsLabels(idxToRemove)=[];
                modelInfo.ObsEnumDefs(idxToRemove)=[];
                modelInfo.ObsLineStyles(idxToRemove)=[];
                modelInfo.ObsLineWidths(idxToRemove)=[];
                modelInfo.ObsLineColors(idxToRemove)=[];
                modelInfo.ObsAxes(idxToRemove)=[];
            end


            message.publish('/sdi2/onModelStart',modelInfo);
        end
    end

end


