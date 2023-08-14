classdef MappingStrategy<handle






    methods(Abstract)
        createMap(obj)
    end


    methods(Hidden)

        function InputMap=mapBlock(~,mdl,portName,sigName,varargin)


            hModeledSys=get_param(mdl,'handle');

            portHandle=find_system(hModeledSys,...
            'SearchDepth',1,'Name',portName);

            BlockPath=Simulink.iospecification.InportProperty.getBlockPath(portHandle);
            Type=get_param(portHandle,'BlockType');

            SignalName=get_param(portHandle,...
            'OutputSignalNames');

            if isempty(SignalName)
                SignalName=[];
            else
                SignalName=SignalName{:};
            end


            if length(varargin)>0

                PortNum=varargin{1};

            else
                if strcmpi(Type,'Inport')
                    PortNum=str2double(get_param(...
                    portHandle,'Port'));
                else
                    PortNum=[];
                end
            end



            SSID=Simulink.ID.getSID(BlockPath);

            aDestination=Simulink.iospecification.Destination(...
            BlockPath,...
            portName,...
            SignalName,...
            PortNum,...
            SSID);

            InputMap=Simulink.iospecification.InputMap(...
            Type,...
            sigName,...
            aDestination);

        end


        function InputMap=sortMap(~,InMap)

            idx=strcmp({InMap(:).Type},'Inport');

            InputMap=InMap(idx);

            if length(InputMap)==1&&isempty(InputMap.Destination)
                return;
            end
            portNumbersByIdx=zeros(1,length(InputMap));


            for kIdx=1:length(InputMap)
                portNumbersByIdx(kIdx)=InputMap(kIdx).Destination.PortNumber;
            end

            [~,idx]=sort(portNumbersByIdx);
            InputMap=InputMap(idx);

            enableIdx=strcmp({InMap(:).Type},'EnablePort');
            if sum(enableIdx)>0
                InputMap(length(InputMap)+1)=InMap(enableIdx);
            end

            triggerIdx=strcmp({InMap(:).Type},'TriggerPort');
            if sum(triggerIdx)>0
                InputMap(length(InputMap)+1)=InMap(triggerIdx);
            end
        end


        function inportNames=getInportNames(~,mdl)


            inportNames=Simulink.iospecification.InportProperty.getInportNames(mdl,false);
        end


        function enableNames=getEnableNames(~,mdl)

            enableNames=Simulink.iospecification.InportProperty.getEnableNames(mdl);
        end


        function triggerNames=getTriggerNames(~,mdl)

            triggerNames=Simulink.iospecification.InportProperty.getTriggerNames(mdl);
        end


        function inputmap=completeMap(obj,mdl,inputmap)





            inportNames=obj.getInportNames(mdl);
            inputmap=obj.plugMapHoles(mdl,inputmap,inportNames);


            enableNames=obj.getEnableNames(mdl);
            inputmap=obj.plugMapHoles(mdl,inputmap,enableNames);


            triggerNames=obj.getTriggerNames(mdl);
            inputmap=obj.plugMapHoles(mdl,inputmap,triggerNames);

        end


        function inputmap=plugMapHoles(obj,mdl,inputmap,portNames)



            for kMap=length(inputmap):-1:1
                blocksMapped{kMap}=inputmap(kMap).Destination.BlockName;
            end

            for k=1:length(portNames)
                if~any(ismember(blocksMapped,portNames{k}))
                    inputmap(length(inputmap)+1)=...
                    obj.mapBlock(mdl,portNames{k},[]);
                end
            end
        end


        function portNumber=getPortNumber(~,modelName,portName)

            portNumber=Simulink.iospecification.InportProperty.getPortNumber(modelName,portName);
        end


        function signalName=getSignalName(~,modelName,portName)

            signalName=Simulink.iospecification.InportProperty.getSignalName(modelName,portName);
        end
    end

end
