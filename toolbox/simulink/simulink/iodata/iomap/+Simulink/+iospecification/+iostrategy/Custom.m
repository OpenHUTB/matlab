classdef Custom<Simulink.iospecification.iostrategy.MappingStrategy














    properties
CustomFHandle
    end


    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version


    end

    methods
        function obj=Custom(CustomFHandle)
            obj.CustomFHandle=CustomFHandle;



            obj.Version=1.1;

        end

        function mapping=createMap(obj,ModelName,SignalNames,Signals)









            narginchk(3,4);

            if isStringScalar(ModelName)
                ModelName=convertStringsToChars(ModelName);
            end

            if isstring(SignalNames)&&~isscalar(SignalNames)
                SignalNames=cellstr(SignalNames);
            end


            if~ischar(ModelName)||isempty(ModelName)

                DAStudio.error('sl_iospecification:iostrategy:invalidModel');

            end


            if~iscellstr(SignalNames)||isempty(SignalNames)

                DAStudio.error('sl_iospecification:iostrategy:invalidSignalNames');

            end


            if iscell(Signals)
                for kCell=1:length(Signals)
                    if~isSimulinkSignalFormat(Signals{kCell})

                        DAStudio.error('sl_iospecification:iostrategy:invalidSignals');
                    end
                end
            else
                DAStudio.error('sl_iospecification:iostrategy:invalidSignals');
            end

            if isempty(obj.CustomFHandle)

                DAStudio.error('sl_iospecification:iostrategy:inValidCustomFile');

            end

            if exist(obj.CustomFHandle,'file')==0

                DAStudio.error('sl_iospecification:iostrategy:customFileNotOnPath');

            end

            try
                mapping=Simulink.iospecification.InputMap.empty;%#ok<NASGU>
                mapping=feval(obj.CustomFHandle,ModelName,SignalNames,Signals);
            catch ME


                DAStudio.error('sl_iospecification:iostrategy:customFileError',...
                obj.CustomFHandle,obj.CustomFHandle,ME.message);
            end


            if~isempty(mapping)
                obj.validateMappingReturn(mapping,ModelName,SignalNames);
                mapping=obj.completeMap(ModelName,mapping);
                mapping=obj.sortMap(mapping);
            end
        end

    end

    methods(Access=private)

        function validateMappingReturn(obj,mapping,ModelName,SignalNames)

            if~isa(mapping,'Simulink.iospecification.InputMap')
                DAStudio.error('sl_iospecification:iostrategy:errorCustomBadType');
            end



            inportNames=obj.getInportNames(ModelName);

            enableNames=obj.getEnableNames(ModelName);

            triggerNames=obj.getTriggerNames(ModelName);

            nSize=length(mapping);

            isValidPort=zeros(1,nSize);


            for kIn=length(mapping):-1:1
                returnNames{kIn}=mapping(kIn).Destination.BlockName;
            end

            for kMap=1:nSize

                if~isempty(inportNames)
                    if any(strcmp(inportNames,returnNames{kMap}))&&...
                        strcmp(mapping(kMap).Type,'Inport')

                        isValidPort(kMap)=1;
                    end
                end

                if~isempty(enableNames)
                    if any(strcmp(enableNames,returnNames{kMap}))&&...
                        strcmp(mapping(kMap).Type,'EnablePort')
                        isValidPort(kMap)=1;
                    end
                end

                if~isempty(triggerNames)
                    if any(strcmp(triggerNames,returnNames{kMap}))&&...
                        strcmp(mapping(kMap).Type,'TriggerPort')
                        isValidPort(kMap)=1;
                    end
                end
            end

            if sum(isValidPort)~=nSize
                DAStudio.error('sl_iospecification:iostrategy:customFileBadBlockName',obj.CustomFHandle,obj.CustomFHandle);
            end


            for kMap=1:length(mapping)


                if~any(strcmp(mapping(kMap).DataSourceName,SignalNames))

                    DAStudio.error('sl_iospecification:iostrategy:customFileBadSignalName',obj.CustomFHandle,obj.CustomFHandle);
                end
            end
        end

    end
end
