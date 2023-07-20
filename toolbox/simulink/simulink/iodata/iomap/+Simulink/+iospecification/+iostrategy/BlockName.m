classdef BlockName<Simulink.iospecification.iostrategy.MappingStrategy















    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version


    end

    methods
        function obj=BlockName()


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


            uniqueSignalNames=unique(SignalNames);

            [tf,~]=ismember(uniqueSignalNames,inportNames);




            mapping=Simulink.iospecification.InputMap.empty(1,0);
            matchCount=1;
            for k=1:length(tf)
                if tf(k)

                    mapping(matchCount)=obj.mapBlock(...
                    ModelName,inportNames{strcmp(inportNames,...
                    uniqueSignalNames{k})},...
                    uniqueSignalNames{k});
                    matchCount=matchCount+1;
                end
            end

            enableNames=obj.getEnableNames(ModelName);

            if~isempty(enableNames)
                [tf,~]=ismember(uniqueSignalNames,enableNames);
                enableCount=1;
                for k=1:length(tf)
                    if tf(k)

                        mapping(length(mapping)+1)=obj.mapBlock(...
                        ModelName,enableNames{enableCount},...
                        uniqueSignalNames{k});
                        enableCount=enableCount+1;
                    end
                end
            end

            triggerNames=obj.getTriggerNames(ModelName);
            if~isempty(triggerNames)
                [tf,~]=ismember(uniqueSignalNames,triggerNames);
                triggerCount=1;
                for k=1:length(tf)
                    if tf(k)
                        mapping(length(mapping)+1)=obj.mapBlock(...
                        ModelName,triggerNames{triggerCount},...
                        uniqueSignalNames{k});
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
