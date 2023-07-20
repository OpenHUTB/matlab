classdef BlockPath<Simulink.iospecification.iostrategy.MappingStrategy









    properties
    end


    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version


    end

    methods

        function obj=BlockPath()


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
                    if~(obj.isValidBlockPathSignal(Signals{kCell}))

                        DAStudio.error('sl_iospecification:iostrategy:invalidBlockPathSignal');
                    end
                end
            else
                DAStudio.error('sl_iospecification:iostrategy:invalidSignals');
            end




            mapping=Simulink.iospecification.InputMap.empty(1,0);



            inportNames=obj.getInportNames(ModelName);

            enableNames=obj.getEnableNames(ModelName);

            triggerNames=obj.getTriggerNames(ModelName);

            if isempty(inportNames)&&isempty(enableNames)&&...
                isempty(triggerNames)

                mapping=[];

                return;

            end



            inportBlkPathes=cell(1,length(inportNames));
            for kInportNames=1:length(inportNames)
                inportBlkPathes{kInportNames}=Simulink.iospecification.InportProperty.makeBlockPath(ModelName,inportNames{kInportNames});
            end


            enableBlkPathes=cell(1,length(enableNames));
            for kEnableNames=1:length(enableNames)
                enableBlkPathes{kEnableNames}=Simulink.iospecification.InportProperty.makeBlockPath(ModelName,enableNames{kEnableNames});
            end


            triggerBlkPathes=cell(1,length(triggerNames));
            for kTriggerNames=1:length(triggerNames)
                triggerBlkPathes{kTriggerNames}=Simulink.iospecification.InportProperty.makeBlockPath(ModelName,triggerNames{kTriggerNames});
            end

            num_ports=length(inportBlkPathes)+length(enableBlkPathes)+length(triggerBlkPathes);

            matchCount=1;


            allBlkPaths=[inportBlkPathes,enableBlkPathes,triggerBlkPathes];

            sigBlkPaths=cell(1,length(Signals));
            for kSig=1:length(Signals)


                if ischar(Signals{kSig}.BlockPath)
                    blkPath=Signals{kSig}.BlockPath;
                else

                    if Signals{kSig}.BlockPath.getLength>0
                        blkPath=Signals{kSig}.BlockPath.getBlock(1);
                    else
                        blkPath='';
                    end
                end
                sigBlkPaths{kSig}=blkPath;
            end

            [uniqueBlkPaths,idx]=unique(sigBlkPaths);
            uniqueSigs=Signals(idx);
            uniqueSigNames=SignalNames(idx);

            for k=1:length(allBlkPaths)



                compareIDX=strcmp(uniqueBlkPaths,allBlkPaths{k});

                if(any(compareIDX))


                    sigName=uniqueSigNames{compareIDX};
                    blockName=get_param(uniqueBlkPaths{compareIDX},'Name');


                    mapping(matchCount)=obj.mapBlock(...
                    ModelName,blockName,sigName);
                    matchCount=matchCount+1;
                end

            end



            if~isempty(mapping)
                mapping=obj.completeMap(ModelName,mapping);
                mapping=obj.sortMap(mapping);
            end
        end

        function bool=isValidBlockPathSignal(~,signal)

            bool=Simulink.sdi.internal.Util.isSimulationDataSet(signal)||...
            Simulink.sdi.internal.Util.isSimulinkTimeseries(signal)||...
            Simulink.sdi.internal.Util.isSimulationDataElement(signal)||...
            Simulink.sdi.internal.Util.isTSArray(signal);

        end
    end
end
