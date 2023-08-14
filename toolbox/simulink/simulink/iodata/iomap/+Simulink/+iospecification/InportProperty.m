classdef InportProperty









    properties
    end


    methods(Static)


        function inportNames=getInportNames(mdl,varargin)









            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);

            includeAllBusElementPorts=true;

            if~isempty(varargin)
                includeAllBusElementPorts=varargin{1};
            end

            inportNames={};

            MODEL_IS_GOOD=Simulink.iospecification.InportProperty.checkModelName(mdl);


            if MODEL_IS_GOOD

                hModeledSys=get_param(mdl,'handle');

                tempInportNames=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','Inport'),'Name');



                if ischar(tempInportNames)

                    inportNames{1}=tempInportNames;
                else
                    inportNames=tempInportNames;
                end


                if includeAllBusElementPorts
                    return;
                end


                portNums=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','Inport'),'Port');

                if~iscell(portNums)

                    portH=get_param(find_system(hModeledSys,...
                    'SearchDepth',1,'BlockType','Inport'),'Handle');
                    return;
                end

                [~,ia,~]=unique(portNums);


                if length(ia)==length(portNums)
                    return;
                end


                portH=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','Inport'),'Handle');


                inportNames=inportNames(ia);
                portH=portH(ia);

            end

        end


        function HAS_BUS_EL_AT_ROOT=hasBusElementPortsAtRoot(mdl)
            HAS_BUS_EL_AT_ROOT=false;
            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);



            if Simulink.iospecification.InportProperty.checkModelName(mdl)

                hModeledSys=get_param(mdl,'handle');

                tempInportNames=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','Inport','IsBusElementPort','on'),'Name');

                if~isempty(tempInportNames)
                    HAS_BUS_EL_AT_ROOT=true;
                end
            end
        end


        function enableNames=getEnableNames(mdl)

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);

            enableNames={};


            if Simulink.iospecification.InportProperty.checkModelName(mdl)

                hModeledSys=get_param(mdl,'handle');

                tempEnableNames=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','EnablePort'),'Name');

                if~isempty(tempEnableNames)

                    enableNames{1}=tempEnableNames;

                end
            end
        end


        function triggerNames=getTriggerNames(mdl)
            triggerNames={};

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);


            if Simulink.iospecification.InportProperty.checkModelName(mdl)

                hModeledSys=get_param(mdl,'handle');

                tempTriggerNames=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','TriggerPort'),'Name');


                if~isempty(tempTriggerNames)&&...
                    ~strcmpi(get_param([mdl,'/',tempTriggerNames],'TriggerType'),'function-call')

                    triggerNames{1}=tempTriggerNames;

                end
            end
        end


        function bool=checkModelName(mdl)

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);

            bool=true;

            if~ischar(mdl)||isempty(mdl)||~isvarname(mdl)||~bdIsLoaded(mdl)
                bool=false;
            end
        end


        function portNumber=getPortNumber(modelName,portName)
            portNumber=[];

            modelName=Simulink.iospecification.InportProperty.charModelName(modelName);


            if Simulink.iospecification.InportProperty.checkModelName(modelName)

                try
                    blkPath=Simulink.iospecification.InportProperty.makeBlockPath(modelName,portName);
                    if any(strcmpi({'Inport','InportShadow'},get_param(...
                        blkPath,'BlockType')))

                        portNumber=str2double(get_param(...
                        blkPath,'Port'));
                    end
                catch


                end

            end
        end


        function signalName=getSignalName(modelName,portName)
            signalName={};

            modelName=Simulink.iospecification.InportProperty.charModelName(modelName);


            if Simulink.iospecification.InportProperty.checkModelName(modelName)
                try
                    signalName=get_param(get_param(...
                    Simulink.iospecification.InportProperty.makeBlockPath(modelName,portName),'Handle'),...
                    'OutputSignalNames');
                catch

                end

            end
        end


        function blkPath=makeBlockPath(modelName,portName)
            blkPath=[];

            modelName=Simulink.iospecification.InportProperty.charModelName(modelName);

            if isStringScalar(portName)
                portName=convertStringsToChars(portName);
            end


            if Simulink.iospecification.InportProperty.checkModelName(modelName)
                try
                    hModeledSys=get_param(modelName,'handle');

                    portHandle=find_system(hModeledSys,...
                    'SearchDepth',1,'Name',portName);

                    blkPath=getfullname(portHandle);




                catch

                end
            end
        end


        function blkPath=getBlockPath(portHandle)
            blkPath=getfullname(portHandle);

            blkPathTmp=Simulink.SimulationData.BlockPath(blkPath);
            blkPath=blkPathTmp.getBlock(1);
        end


        function[portH,portBlkPath,portName,portSigName,portNum]=...
            getInportProperties(mdl,varargin)







            portH={};
            portBlkPath={};
            portName={};
            portSigName={};
            portNum={};

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);
            MODEL_IS_GOOD=Simulink.iospecification.InportProperty.checkModelName(mdl);

            includeAllBusElementPorts=true;

            if~isempty(varargin)
                includeAllBusElementPorts=varargin{1};
            end


            if MODEL_IS_GOOD


                hModeledSys=get_param(mdl,'handle');


                tempInportHandles=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','Inport'),'Handle');


                if~iscell(tempInportHandles)
                    numH=length(tempInportHandles);
                    portH=cell(numH,1);

                    for k=1:numH
                        portH{k}=tempInportHandles;
                    end
                else
                    portH=tempInportHandles;
                end

                numH=length(portH);


                portBlkPath=cell(numH,1);
                portName=cell(numH,1);
                portSigName=cell(numH,1);
                portNumStr=cell(numH,1);
                portNum=cell(numH,1);


                for k=1:length(portH)
                    portBlkPath{k}=Simulink.iospecification.InportProperty.getBlockPath(portH{k});
                    portName{k}=get_param(portH{k},'Name');
                    portSigName{k}=Simulink.iospecification.InportProperty.getOutputSignalName(portH{k});
                    portNumStr{k}=get_param(portH{k},'Port');
                    portNum{k}=str2double(portNumStr{k});
                end



                if includeAllBusElementPorts


                    return;

                end


                [~,ia,~]=unique(portNumStr);


                if length(ia)==length(portNumStr)
                    return;
                end


                portBlkPath=portBlkPath(ia);
                portName=portName(ia);
                portSigName=portSigName(ia);
                portNum=portNum(ia);
                portH=portH(ia);
            end

        end


        function[portH,portBlkPath,portName,portSigName]=...
            getEnableProperties(mdl)



            portH={};
            portBlkPath={};
            portName={};
            portSigName={};

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);


            if Simulink.iospecification.InportProperty.checkModelName(mdl)


                hModeledSys=get_param(mdl,'handle');


                tempEnableHandles=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','EnablePort'),'Handle');


                if~iscell(tempEnableHandles)
                    numH=length(tempEnableHandles);
                    portH=cell(numH,1);

                    for k=1:numH
                        portH{k}=tempEnableHandles;
                    end
                else
                    portH=tempEnableHandles;
                end

                numH=length(portH);


                portBlkPath=cell(numH,1);
                portName=cell(numH,1);
                portSigName=cell(numH,1);


                for k=1:length(portH)
                    portBlkPath{k}=Simulink.iospecification.InportProperty.getBlockPath(portH{k});
                    portName{k}=get_param(portH{k},'Name');
                    portSigName{k}=Simulink.iospecification.InportProperty.getOutputSignalName(portH{k});
                end
            end

        end


        function[portH,portBlkPath,portName,portSigName]=...
            getTriggerProperties(mdl)



            portH={};
            portBlkPath={};
            portName={};
            portSigName={};

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);


            if Simulink.iospecification.InportProperty.checkModelName(mdl)


                hModeledSys=get_param(mdl,'handle');


                tempTriggerHandles=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','TriggerPort'),'Handle');


                if~iscell(tempTriggerHandles)
                    numH=length(tempTriggerHandles);
                    portH=cell(numH,1);

                    for k=1:numH
                        portH{k}=tempTriggerHandles;
                    end
                else
                    portH=tempTriggerHandles;
                end

                idxToScrub=[];
                for kPort=1:length(portH)
                    if strcmpi(get(portH{kPort},'TriggerType'),'function-call')
                        idxToScrub=kPort;
                    end
                end
                portH(idxToScrub)=[];


                numH=length(portH);


                portBlkPath=cell(numH,1);
                portName=cell(numH,1);
                portSigName=cell(numH,1);

                if isempty(portH)
                    return;
                end


                for k=1:length(portH)
                    portBlkPath{k}=Simulink.iospecification.InportProperty.getBlockPath(portH{k});
                    portName{k}=get_param(portH{k},'Name');
                    portSigName{k}=Simulink.iospecification.InportProperty.getOutputSignalName(portH{k});
                end
            end

        end


        function signalName=getOutputSignalName(portH)


            tmpSignalName=get_param(portH,'OutputSignalNames');

            if isempty(tmpSignalName)
                signalName='';
            else
                signalName=tmpSignalName{:};
            end

        end


        function[portH,portBlkPath,portName,portSigName,portNum]=...
            getInportShadowProperties(mdl)




            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);

            portH={};
            portBlkPath={};
            portName={};
            portSigName={};
            portNum={};


            if Simulink.iospecification.InportProperty.checkModelName(mdl)


                hModeledSys=get_param(mdl,'handle');


                tempInportHandles=get_param(find_system(hModeledSys,...
                'SearchDepth',1,'BlockType','InportShadow'),'Handle');


                if~iscell(tempInportHandles)
                    numH=length(tempInportHandles);
                    portH=cell(numH,1);

                    for k=1:numH
                        portH{k}=tempInportHandles;
                    end
                else
                    portH=tempInportHandles;
                end

                numH=length(portH);


                portBlkPath=cell(numH,1);
                portName=cell(numH,1);
                portSigName=cell(numH,1);
                portNum=cell(numH,1);


                for k=1:length(portH)
                    portBlkPath{k}=Simulink.iospecification.InportProperty.getBlockPath(portH{k});
                    portName{k}=get_param(portH{k},'Name');
                    portSigName{k}=Simulink.iospecification.InportProperty.getOutputSignalName(portH{k});
                    portNum{k}=str2double(get_param(portH{k},'Port'));
                end

            end

        end


        function bool=isPortInModel(mdl,portName)

            mdl=Simulink.iospecification.InportProperty.charModelName(mdl);

            if isStringScalar(portName)
                portName=convertStringsToChars(portName);
            end

            bool=false;


            [~,~,inportName,~,~]=...
            Simulink.iospecification.InportProperty.getInportProperties(mdl);


            if~isempty(inportName)&&any(strcmp(inportName,portName))
                bool=true;
                return;
            end



            [~,~,enablePortName,~]=...
            Simulink.iospecification.InportProperty.getEnableProperties(mdl);


            if~isempty(enablePortName)&&any(strcmp(enablePortName,portName))
                bool=true;
                return;
            end



            [~,~,triggerPortName,~]=...
            Simulink.iospecification.InportProperty.getTriggerProperties(mdl);


            if~isempty(triggerPortName)&&any(strcmp(triggerPortName,portName))
                bool=true;
                return;
            end



            [~,~,shadowPortName,~,~]=...
            Simulink.iospecification.InportProperty.getInportShadowProperties(mdl);


            if~isempty(shadowPortName)&&any(strcmp(shadowPortName,portName))
                bool=true;
                return;
            end

        end


        function mdlOut=charModelName(mdl)

            if isStringScalar(mdl)
                mdl=convertStringsToChars(mdl);
            end

            mdlOut=mdl;

        end

    end
end
