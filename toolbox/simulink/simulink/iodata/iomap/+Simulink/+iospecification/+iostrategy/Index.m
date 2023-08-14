classdef Index<Simulink.iospecification.iostrategy.MappingStrategy














    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version


    end

    methods

        function obj=Index()


            obj.Version=1.1;
        end


        function mapping=createMap(obj,ModelName,SignalNames,~)








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


            inportNames=obj.getInportNames(ModelName);

            portNumber=zeros(1,length(inportNames));


            for kInport=1:length(inportNames)
                portNumber(kInport)=getPortNumber(obj,ModelName,inportNames{kInport});
            end

            [~,idx]=sort(portNumber);
            inportNames=inportNames(idx);
            portNumber=portNumber(idx);


            mapping=Simulink.iospecification.InputMap.empty;
            for k=1:length(inportNames)



                if k<=length(SignalNames)

                    mapping(k)=obj.mapBlock(...
                    ModelName,inportNames{k},...
                    SignalNames{k},portNumber(k));

                end

            end
            enableNames=[];
            if(length(SignalNames)>length(inportNames))
                enableNames=obj.getEnableNames(ModelName);
                if~isempty(enableNames)

                    enableCount=1;
                    for k=1:length(enableNames)

                        mapping(length(mapping)+1)=obj.mapBlock(...
                        ModelName,enableNames{enableCount},...
                        SignalNames{length(inportNames)+k});
                        enableCount=enableCount+1;
                    end
                end
            end


            if(length(SignalNames)>(length(inportNames)+length(enableNames)))

                triggerNames=obj.getTriggerNames(ModelName);

                if~isempty(triggerNames)

                    triggerCount=1;
                    for k=1:length(triggerNames)

                        mapping(length(mapping)+1)=obj.mapBlock(...
                        ModelName,triggerNames{triggerCount},...
                        SignalNames{...
                        length(inportNames)+length(enableNames)...
                        +k});
                        triggerCount=triggerCount+1;
                    end
                end
            end



            if~isempty(mapping)
                mapping=obj.completeMap(ModelName,mapping);
                mapping=obj.sortMap(mapping);
            end

        end
    end
end
