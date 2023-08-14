classdef SignalName<Simulink.iospecification.iostrategy.MappingStrategy















    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version


    end

    methods

        function obj=SignalName()


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




            mapping=Simulink.iospecification.InputMap.empty;

            if~ischar(ModelName)||isempty(ModelName)
                DAStudio.error('sl_iospecification:iostrategy:invalidModel');
            end

            if~iscellstr(SignalNames)||isempty(SignalNames)
                DAStudio.error('sl_iospecification:iostrategy:invalidSignalNames');
            end


            inportNames=obj.getInportNames(ModelName);


            uniqueSignalNames=unique(SignalNames);

            if~isempty(inportNames)
                outSignalNames{length(inportNames)}=[];

                for kInport=1:length(inportNames)
                    tempOutSignalNames=getSignalName(obj,ModelName,inportNames{kInport});
                    outSignalNames{kInport}=tempOutSignalNames{:};
                end

                [tf,~]=ismember(outSignalNames,uniqueSignalNames);
                matchCount=1;
                for k=1:length(tf)
                    if tf(k)

                        mapping(matchCount)=obj.mapBlock(...
                        ModelName,inportNames{k},outSignalNames{k});
                        matchCount=matchCount+1;

                    end
                end
            end


            enableNames=obj.getEnableNames(ModelName);
            if~isempty(enableNames)
                for kEnable=1:length(enableNames)

                    enableSignal=getSignalName(obj,ModelName,enableNames{kEnable});
                    if~isempty(enableSignal)
                        [tf,~]=ismember(uniqueSignalNames,enableSignal);

                        for k=1:length(tf)
                            if tf(k)

                                mapping(length(mapping)+1)=obj.mapBlock(...
                                ModelName,enableNames{kEnable},uniqueSignalNames{k});

                            end
                        end


                    elseif any(strcmp(uniqueSignalNames,'Enable'))||any(strcmp(uniqueSignalNames,'enable'))
                        mapping(length(mapping)+1)=obj.mapBlock(...
                        ModelName,enableNames{kEnable},uniqueSignalNames{...
                        (strcmp(uniqueSignalNames,'Enable'))|(strcmp(uniqueSignalNames,'enable'))});
                    end
                end
            end


            triggerNames=obj.getTriggerNames(ModelName);
            if~isempty(triggerNames)

                for kTrigger=1:length(triggerNames)

                    triggerSignal=getSignalName(obj,ModelName,triggerNames{kTrigger});
                    if~isempty(triggerSignal)

                        [tf,~]=ismember(uniqueSignalNames,triggerSignal);
                        triggerCount=1;
                        for k=1:length(tf)
                            if tf(k)

                                mapping(length(mapping)+1)=obj.mapBlock(...
                                ModelName,triggerNames{triggerCount},uniqueSignalNames{k});
                                triggerCount=triggerCount+1;
                            end
                        end

                    elseif any(strcmp(uniqueSignalNames,'Trigger'))||any(strcmp(uniqueSignalNames,'trigger'))
                        mapping(length(mapping)+1)=obj.mapBlock(...
                        ModelName,triggerNames{kTrigger},uniqueSignalNames{...
                        (strcmp(uniqueSignalNames,'Trigger'))|(strcmp(uniqueSignalNames,'trigger'))});

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
