classdef StimulationControl<handle










    methods(Access={?slrealtime.Target})
        function this=StimulationControl(tg)
            this.Target=tg;
        end
    end
    methods(Access=private)
        function delete(~)
        end
    end



    properties(Access=private)
Target
    end



    methods(Access=public)

        function start(this,arg)






















            this.validateTargetConnectAndLoad('start');


            objStruct=this.getRootInportConfiguration(this.Target.ModelStatus.ModelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'));
            end


            if isequal(arg,'all')
                arg=cell(1,length(objStruct.metadata));
                for i=1:length(objStruct.metadata)
                    arg{i}=objStruct.metadata(i).FullBlockPath;
                end
            end


            this.getStatus(arg);


            if this.checkStatus({slrealtime.internal.StimulationState.ERROR})
                error(message('slrealtime:rootinport:StimFailed'));
            end
            if this.checkStatus({slrealtime.internal.StimulationState.RUNNING,...
                slrealtime.internal.StimulationState.STARTING})&&this.Target.isRunning
                error(message('slrealtime:rootinport:StimAlreadyStarted'));
            end


            blockPaths=this.validateArg(arg,objStruct.metadata);
            blockPaths=cellfun(@(x)(strrep(x,'\n',' ')),blockPaths,'UniformOutput',false);
            tc=this.Target.get('tc');

            try
                tc.stimulationCommand('start',blockPaths);
                maxWait=2.0;
                start=tic;
                while true
                    if this.checkStatus({slrealtime.internal.StimulationState.STARTING,...
                        slrealtime.internal.StimulationState.RUNNING})||toc(start)>maxWait
                        break;
                    end
                    pause(0.01);
                end
            catch ME
                throwAsCaller(ME);
            end
        end

        function pause(this,arg)
















            this.validateTargetConnectAndLoad('pause');


            objStruct=this.getRootInportConfiguration(this.Target.ModelStatus.ModelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'));
            end


            if isequal(arg,'all')
                arg=cell(1,length(objStruct.metadata));
                for i=1:length(objStruct.metadata)
                    arg{i}=objStruct.metadata(i).FullBlockPath;
                end
            end


            this.getStatus(arg);


            if~this.checkStatus({slrealtime.internal.StimulationState.RUNNING})
                error(message('slrealtime:rootinport:StimNotStarted'));
            end


            blockPaths=this.validateArg(arg,objStruct.metadata);
            blockPaths=cellfun(@(x)(strrep(x,'\n',' ')),blockPaths,'UniformOutput',false);
            tc=this.Target.get('tc');

            try
                tc.stimulationCommand('pause',blockPaths);
                maxWait=1.0;
                start=tic;
                while true
                    if this.checkStatus({slrealtime.internal.StimulationState.PAUSED})||toc(start)>maxWait
                        break;
                    end
                    pause(0.01);
                end
            catch ME
                throwAsCaller(ME);
            end
        end

        function stop(this,arg)


















            this.validateTargetConnectAndLoad('stop');


            objStruct=this.getRootInportConfiguration(this.Target.ModelStatus.ModelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'));
            end


            if isequal(arg,'all')
                arg=cell(1,length(objStruct.metadata));
                for i=1:length(objStruct.metadata)
                    arg{i}=objStruct.metadata(i).FullBlockPath;
                end
            end


            this.getStatus(arg);


            if this.checkStatus({slrealtime.internal.StimulationState.ERROR})
                error(message('slrealtime:rootinport:StimFailed'));
            end


            blockPaths=this.validateArg(arg,objStruct.metadata);
            blockPaths=cellfun(@(x)(strrep(x,'\n',' ')),blockPaths,'UniformOutput',false);
            tc=this.Target.get('tc');

            try
                tc.stimulationCommand('stop',blockPaths);
                maxWait=2.0;
                start=tic;
                while true
                    if this.checkStatus({slrealtime.internal.StimulationState.STOPPED})||toc(start)>maxWait
                        break;
                    end
                    pause(0.01);
                end
            catch ME
                throwAsCaller(ME);
            end
        end

        function status=getStatus(this,arg)


















            this.validateTargetConnectAndLoad('getStatus');


            objStruct=this.getRootInportConfiguration(this.Target.ModelStatus.ModelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'));
            end


            if isequal(arg,'all')
                arg=cell(1,length(objStruct.metadata));
                for i=1:length(objStruct.metadata)
                    arg{i}=objStruct.metadata(i).FullBlockPath;
                end
            end


            blockPaths=this.validateArg(arg,objStruct.metadata);
            blockPaths=cellfun(@(x)(strrep(x,'\n',' ')),blockPaths,'UniformOutput',false);

            ports=cell(1,length(blockPaths));
            for i=1:length(blockPaths)
                str=split(blockPaths(i),'/');
                ports{i}=strrep(str{end},' ','');
            end
            tc=this.Target.get('tc');
            tc.StimulationState={};
            tc.StimulationIsFinished={};
            prevState=tc.StimulationState;
            status=struct();

            try
                tc.stimulationCommand('status',blockPaths);
                maxWait=1.0;
                start=tic;
                while true
                    if~isequal(prevState,tc.StimulationState)||toc(start)>maxWait
                        states=tc.StimulationState;
                        isFinished=tc.StimulationIsFinished;
                        break;
                    end
                    pause(0.01);
                end
            catch ME
                throwAsCaller(ME);
            end
            for i=1:length(ports)
                ports{i}=strrep(ports{i},'\n','');
                if~isempty(states)
                    status.(ports{i}).state=states{i};
                else
                    status.(ports{i}).state=slrealtime.internal.StimulationState.ERROR;
                end

                if~isempty(isFinished)
                    status.(ports{i}).isFinished=isFinished{i};
                else
                    status.(ports{i}).isFinished='';
                end
            end
        end

        function reloadData(this,varargin)
























            if nargin<2||~rem(nargin,2)
                error(message('slrealtime:rootinport:NoInputArgs'));
            end

            this.validateTargetConnectAndLoad('reload');


            objStruct=this.getRootInportConfiguration(this.Target.ModelStatus.ModelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'))
            end

            arg=varargin(1:2:nargin-1);
            if isnumeric(varargin{1})
                arg=cell2mat(arg);
            end


            this.getStatus(arg);


            if~this.checkStatus({slrealtime.internal.StimulationState.STOPPED})
                error(message('slrealtime:rootinport:StimNotStopped'));
            end


            ts=varargin(2:2:nargin-1);


            blockPaths=this.validateArg(arg,objStruct.metadata);
            portIndices=zeros(1,length(blockPaths));
            data={};
            Index=0;

            for i=1:length(blockPaths)
                for j=1:length(objStruct.metadata)
                    if isequal(blockPaths{i},objStruct.metadata(j).FullBlockPath)


                        if objStruct.metadata(j).isInport
                            Index=Index+1;
                            portIndices(Index)=objStruct.metadata(j).OriginalPortIndex;

                            validateattributes(ts{i},{'timeseries'},{'row'});
                            data{Index}=ts{i};%#ok<*AGROW> 

                        else
                            firstPortIndex=objStruct.metadata(j).OriginalPortIndex;
                            thisPlaybackData=ts{i};
                            validateattributes(thisPlaybackData,{'timeseries','cell','Simulink.SimulationData.Dataset'},{'row'});

                            switch(class(thisPlaybackData))


                            case 'Simulink.SimulationData.Dataset'
                                if objStruct.metadata(j).NumOutports==numElements(thisPlaybackData)
                                    for k=1:numElements(thisPlaybackData)
                                        Index=Index+1;
                                        portIndices(Index)=firstPortIndex+k-1;


                                        validateattributes(thisPlaybackData{k}.Values,{'timeseries'},{'row'});
                                        data{Index}=thisPlaybackData{k}.Values;
                                    end
                                else
                                    error(message('slrealtime:rootinport:IncorrectDatasetSize',thisPlaybackData.Name,arg{i}));
                                end


                            case 'timeseries'
                                if objStruct.metadata(j).NumOutports==1
                                    Index=Index+1;
                                    portIndices(Index)=firstPortIndex;
                                    data{Index}=thisPlaybackData;
                                else
                                    error(message('slrealtime:rootinport:IncorrectSingleOutportPlaybackInput',arg{i}));
                                end


                            case 'cell'
                                if iscell(thisPlaybackData{1})
                                    for k=1:length(thisPlaybackData)
                                        Index=Index+1;
                                        indexData=thisPlaybackData{k};
                                        portIndices(Index)=firstPortIndex+indexData{1}-1;


                                        validateattributes(indexData{2},{'timeseries'},{'row'});
                                        data{Index}=indexData{2};
                                    end
                                else
                                    if objStruct.metadata(j).NumOutports==1
                                        Index=Index+1;
                                        portIndices(Index)=firstPortIndex;


                                        validateattributes(thisPlaybackData{2},{'timeseries'},{'row'});
                                        data{Index}=thisPlaybackData{2};
                                    else
                                        error(message('slrealtime:rootinport:IncorrectSingleOutportPlaybackInput',arg{i}));
                                    end
                                end
                            end
                        end
                        break;
                    end
                end
            end
            this.reloadRootLevelInportDataPrivate(objStruct.metadata,portIndices,data);
        end
    end




    methods(Access=private)

        function confStruct=getRootInportConfiguration(~,modelName)

            appObj=slrealtime.Application(modelName);
            confStruct=[];



            fname=[modelName,'_RI.mat'];
            filePart=['/ri/',fname];
            parts=appObj.list();
            f=find(strcmp(parts,filePart),1);
            if~isempty(f)
                try
                    appObj.extract(filePart);
                    fname=fullfile(appObj.getWorkingDir,'ri',fname);
                    if exist(fname,'file')
                        confStruct=load(fname);



                        delete(fname);
                    end
                catch ME %#ok<NASGU>
                end
            end
        end

        function status=checkStatus(this,state)
            status=false;
            tc=this.Target.get('tc');
            blockStates=tc.StimulationState;
            for i=1:length(blockStates)
                for j=1:length(state)
                    if isequal(blockStates{i},state{j})
                        status=true;break;
                    end
                end
            end
        end

        function blockPaths=validateArg(this,arg,metadata)%#ok<*INUSD> 



            if iscell(arg)
                for i=1:length(arg)


                    if iscell(arg{i})
                        arg{i}=strjoin(arg{i},',');
                    end


                    if isa(arg{i},'Simulink.SimulationData.BlockPath')||isa(arg{i},'Simulink.BlockPath')
                        arg{i}=strjoin(arg{i}.convertToCell,',');
                    end


                    validateattributes(arg{i},{'char'},{'row'});
                end
            else

                arrayfun(@(x)(validateattributes(x,{'numeric'},{'positive'})),arg);
            end

            blockPaths=cell(1,length(arg));
            if isnumeric(arg)


                rootinput_metadata=metadata([]);
                index=1;

                for i=1:length(metadata)
                    if metadata(i).isInport
                        rootinput_metadata(index)=metadata(i);
                        index=index+1;
                    end
                end
                ports=sort(arg);

                if ports(end)-1<=rootinput_metadata(end).OriginalPortIndex&&ports(1)>0

                    for i=1:length(arg)
                        blockPaths(i)={rootinput_metadata(ports(i)).FullBlockPath};
                    end
                else
                    if ports(1)<1
                        error(message('slrealtime:rootinport:NoSuchInport',ports(1)));
                    else
                        error(message('slrealtime:rootinport:NoSuchInport',ports(end)));
                    end
                end
            end

            if iscellstr(arg)

                for i=1:length(arg)


                    cellBlockPaths={metadata(:).FullBlockPath};
                    [~,ia,~]=unique(cellBlockPaths);
                    uniqueMetadata=metadata(ia);
                    blockNameIndex=find(strcmp({uniqueMetadata(:).BlockName},arg{i}));

                    if isempty(blockNameIndex)

                        blockPathIndex=find(strcmp({uniqueMetadata(:).FullBlockPath},arg{i}));
                        if isempty(blockPathIndex)
                            error(message('slrealtime:rootinport:NoSuchInport',arg{i}));
                        else
                            blockPaths(i)={uniqueMetadata(blockPathIndex(1)).FullBlockPath};
                        end


                    elseif length(blockNameIndex)>1
                        error(message('slrealtime:rootinport:MultipleInputBlocks',arg{i}));
                    else
                        blockPaths(i)={uniqueMetadata(blockNameIndex).FullBlockPath};
                    end
                end
            end
        end

        function validateTargetConnectAndLoad(this,stimMethod)
            if~this.Target.isConnected()
                this.Target.connect();
            end

            if~this.Target.isLoaded()
                error(message('slrealtime:rootinport:StimNoAppLoaded',stimMethod));
            end
        end

        function reloadRootLevelInportDataPrivate(this,metadata,portIndices,ts)
            appObj=slrealtime.Application(this.Target.ModelStatus.ModelName);
            for i=1:length(ts)
                this.verifyPortDatatypes(metadata(portIndices(i)+1),ts{i}.Data);

                fname=['extinp',num2str(portIndices(i)),'.inp'];
                fpath=[appObj.getWorkingDir,filesep,fname];


                sampletime=metadata(portIndices(i)+1).SamplePeriod;



                tUnion=slrealtime.internal.ExternalInputManager.getUnionTimeVector(ts{i},metadata(portIndices(i)+1),sampletime);
                [ts{i},tsExtrapolation]=slrealtime.internal.ExternalInputManager.interpolateDataPoints(ts{i},tUnion,metadata(portIndices(i)+1));



                slrealtime.internal.ExternalInputManager.generateRootInportDataFileFromTimeseries(portIndices(i),ts{i},fpath,false);



                if strcmp(metadata(i).ExtrapolationAfterLastDataPoint,"Linear extrapolation")
                    slrealtime.internal.ExternalInputManager.generateRootInportDataFileFromTimeseries(portIndices(i),tsExtrapolation,fpath,true);
                end


                dstPath=strcat('/home/slrt/applications/',this.Target.ModelStatus.ModelName,'/ri/');
                srcFiles=fullfile(appObj.getWorkingDir,'*.inp');
                this.Target.sendFile(srcFiles,dstPath);
            end
        end




        function verifyPortDatatypes(~,signalMetadata,inputData)

            if isfi(inputData)
                if~(signalMetadata.IsFixedPoint&&...
                    signalMetadata.FixedPoint.FixedExp==inputData.FixedExponent&&...
                    signalMetadata.FixedPoint.Bias==inputData.Bias&&...
                    signalMetadata.FixedPoint.SlopeAdjFactor==inputData.SlopeAdjustmentFactor&&...
                    signalMetadata.FixedPoint.FractionLength==inputData.FractionLength&&...
                    signalMetadata.FixedPoint.WordLength==inputData.WordLength&&...
                    signalMetadata.FixedPoint.Signedness==inputData.Signed)
                    error(message('slrealtime:rootinport:DataTypeMismatch',signalMetadata.PortIndex+1,signalMetadata.FullBlockPath));
                end
            end

            if isenum(inputData)
                if~(signalMetadata.IsEnumType&&...
                    strcmp(signalMetadata.Enum.EnumClassName,class(inputData)))
                    error(message('slrealtime:rootinport:DataTypeMismatch',signalMetadata.PortIndex+1,signalMetadata.FullBlockPath));
                end
            end
        end
    end

end

