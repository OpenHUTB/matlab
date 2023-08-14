classdef ExternalInputManager






    methods(Static)

        function generateArtifacts(appObj,modelName,buildDir,hasPlaybackBlk)



            loaded_bds=find_system('type','block_diagram');
            model_loaded=any(strcmp(loaded_bds,modelName));
            if~model_loaded
                warning(message('slrealtime:rootinport:ModelNotLoaded'));
                return;
            end

            loadexternalinput=get_param(modelName,'LoadExternalInput');


            if strcmp(loadexternalinput,'off')&&~hasPlaybackBlk

                return;
            end



            [metadata,externalInputPlayback]=getCachedMetadata(modelName,buildDir,hasPlaybackBlk,loadexternalinput);

            if isempty(metadata)

                return;
            end
            externalInputRootInport=get_param(modelName,'ExternalInput');
            numInputPorts=length(metadata);



            for i=1:numInputPorts
                if strcmp(metadata(i).StorageClass,'ImportedExternPointer')
                    error(message('slrealtime:rootinport:CannotGenerateInportData','Storage class cannot be ImportedExternPointer'));
                end
            end



            slrealtime.internal.ExternalInputManager.updateRootLevelInportDataPrivate(appObj,modelName,metadata,externalInputRootInport,externalInputPlayback,loadexternalinput);

            gbDir=RTW.getBuildDir(modelName);
            codeDescDir=gbDir.BuildDirectory;



            stimdbjson=generateInputStreamDatabase(modelName,codeDescDir,metadata);



            addArtifactsToApplication(appObj,modelName,stimdbjson,...
            metadata,...
            externalInputRootInport,...
            loadexternalinput,...
            externalInputPlayback);
        end

        function updateRootLevelInportDataPrivate(appObj,modelName,metadata,externalInputRootInport,externalInputPlayback,loadexternalinput)

            if isempty(metadata)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'))
            end

            if isempty(externalInputRootInport)&&isempty(externalInputPlayback)
                error(message('slrealtime:rootinport:ExtInpEmpty'))
            end

            inp=[];

            if~isempty(externalInputRootInport)&&strcmp(loadexternalinput,'on')
                inp=findRootInportData(modelName,externalInputRootInport);
            end

            if~isempty(externalInputPlayback)
                playbackInput=findPlaybackData(externalInputPlayback);
                inp=[inp;playbackInput];
            end

            if isempty(inp)
                error(message('slrealtime:rootinport:ExtInpCannotEval',externalInputRootInport));
            end

            numInputElements=length(inp);

            if numInputElements==0
                error(message('slrealtime:rootinport:ExtInpEmpty'))
            end






            numDatasets=0;
            for i=1:numInputElements
                if isa(inp{i},'Simulink.SimulationData.Dataset')
                    numDatasets=numDatasets+1;
                end
            end

            if numDatasets>1
                error(message('Simulink:SimInput:MultipleDatasets'))
            end

            if isa(inp{1},'Simulink.SimulationData.Dataset')


                tmp=inp{1};
                inp=[];
                for i=1:tmp.numElements
                    inp{i}=tmp.getElement(i);%#ok<AGROW>
                end
            end

            ds=generateDataset(appObj,modelName,inp,metadata);



            for i=1:ds.numElements

                fname=['extinp',num2str(i-1),'.inp'];
                fpath=[appObj.getWorkingDir,filesep,fname];
                filePart=['/ri/',fname];



                try
                    appObj.remove(filePart);
                catch ME %#ok<NASGU>

                end


                sampletime=metadata(i).SamplePeriod;




                switch class(ds.getElement(i))
                case 'Simulink.SimulationData.Dataset'
                    ts=getAllTimeseriesFromDataset(ds.getElement(i));
                case 'timeseries'
                    ts=ds.getElement(i);
                otherwise
                    assert(true)
                end



                tUnion=slrealtime.internal.ExternalInputManager.getUnionTimeVector(ts,metadata(i),sampletime);
                [ts,tsExtrapolation]=slrealtime.internal.ExternalInputManager.interpolateDataPoints(ts,tUnion,metadata(i));



                slrealtime.internal.ExternalInputManager.generateRootInportDataFileFromTimeseries(i-1,ts,fpath,false);



                if strcmp(metadata(i).ExtrapolationAfterLastDataPoint,"Linear extrapolation")
                    slrealtime.internal.ExternalInputManager.generateRootInportDataFileFromTimeseries(i-1,tsExtrapolation,fpath,true);
                end



                if exist(fpath,'file')
                    appObj.add(filePart,fpath);
                end

            end
        end





        function updateRootLevelInportData(varargin)

            appObj=varargin{1};
            modelName=varargin{2};


            objStruct=getRootInportConfiguration(appObj,modelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'))
            end

            if nargin>2

                externalinput=varargin{3};
            else

                externalinput=objStruct.externalInputRootInport;
            end

            try

                slrealtime.internal.ExternalInputManager.updateRootLevelInportDataPrivate(appObj,modelName,objStruct.metadata,externalinput,[],'on');
            catch ME
                ME.throwAsCaller
            end
        end






        function str=getRootLevelInportMapping(varargin)

            appObj=varargin{1};
            modelName=varargin{2};


            objStruct=getRootInportConfiguration(appObj,modelName);
            if isempty(objStruct)
                error(message('slrealtime:rootinport:InportMappingNotAvailable'))
            end

            str=objStruct.externalInputRootInport;

        end



        function t=getUnionTimeVector(ts,metadata,sampletime)
            t=0;
            tUnion=[];
            for i=1:length(ts)
                t1=ts(i).Time;
                tUnion=union(tUnion,t1);
            end

            if~isempty(tUnion)
                tFirst=tUnion(1);
                t=union(t,tUnion);


                if strcmp(metadata.ExtrapolationBeforeFirstDataPoint,"Linear extrapolation")
                    nSamples=floor(tFirst/sampletime);
                    tSamples=(0:nSamples)*sampletime;
                    t=union(t,tSamples);
                end

                if metadata.Interpolation
                    nSamples=floor(t(end)/sampletime);
                    tSamplesAll=(0:nSamples)*sampletime;
                    tSamples=tSamplesAll(tSamplesAll>=tFirst);
                    t=union(t,tSamples);
                end
            end
        end

        function[ts,tsExtrapolation]=interpolateDataPoints(ts,tUnion,metadata)
            tsExtrapolation=timeseries.empty(length(ts),0);
            for i=1:length(ts)
                t=ts(i).Time;
                d=ts(i).Data;


                nd=ndims(d);
                if nd>2
                    tdim=nd;
                else
                    tdim=1;
                end


                sz=size(d);
                numSamples=sz(tdim);


                sz(tdim)=1;
                numVectors=prod(sz(1:end));


                if~isempty(t)
                    tVectorBeforeFirstPoint=tUnion(tUnion<t(1));
                    extrapolatedData=[];


                    if~isempty(tVectorBeforeFirstPoint)
                        if strcmp(metadata.ExtrapolationBeforeFirstDataPoint,"Linear extrapolation")
                            dInput2d=processDataVector(d,nd,numVectors,numSamples,true);
                            if isinteger(dInput2d)||isfi(dInput2d)
                                dInput2d=double(dInput2d);
                            end

                            extrapolatedData=zeros(length(tVectorBeforeFirstPoint),numVectors);


                            for l=1:numVectors
                                if islogical(dInput2d)

                                    extrapolatedData(:,l)=interp1(t,double(dInput2d(:,l)),tVectorBeforeFirstPoint,'nearest','extrap');
                                else
                                    extrapolatedData(:,l)=interp1(t,dInput2d(:,l),tVectorBeforeFirstPoint,'linear','extrap');
                                end
                            end
                        else
                            dInput2d=processDataVector(d,nd,numVectors,numSamples,false);
                            if strcmp(metadata.ExtrapolationBeforeFirstDataPoint,"Hold first value")
                                extrapolatedData=ones(height(dInput2d),length(tVectorBeforeFirstPoint)).*dInput2d(:,1);
                            else
                                extrapolatedData=zeros(height(dInput2d),length(tVectorBeforeFirstPoint));
                            end

                            extrapolatedData=extrapolatedData.';
                        end
                    end


                    tVectorBetweenFirstLastPoint=tUnion(length(tVectorBeforeFirstPoint)+1:end);
                    interpolatedData=[];
                    if metadata.Interpolation&&length(t)>1
                        if length(t)<length(tVectorBetweenFirstLastPoint)
                            dInput2d=processDataVector(d,nd,numVectors,numSamples,true);
                            if isinteger(dInput2d)||isfi(dInput2d)
                                dInput2d=double(dInput2d);
                            end

                            interpolatedData=zeros(length(tVectorBetweenFirstLastPoint),numVectors);


                            for l=1:numVectors

                                if islogical(dInput2d)

                                    interpolatedData(:,l)=interp1(t,double(dInput2d(:,l)),tVectorBetweenFirstLastPoint,'nearest');
                                else
                                    interpolatedData(:,l)=interp1(t,dInput2d(:,l),tVectorBetweenFirstLastPoint,'linear','extrap');
                                end
                            end
                        end
                    else
                        dInput2d=processDataVector(d,nd,numVectors,numSamples,false);
                        interpolatedData=dInput2d.';
                    end


                    if strcmp(metadata.ExtrapolationAfterLastDataPoint,"Linear extrapolation")&&numSamples>1
                        dInput2d=processDataVector(d,nd,numVectors,numSamples,false);
                        transposedData=dInput2d.';


                        secondLastTime=ts(i).Time(end-1);
                        secondLastData=transposedData(end-1,:);
                        tsExtrapolation(i)=timeseries(secondLastData,secondLastTime);
                    end


                    if~isempty(extrapolatedData)||~isempty(interpolatedData)
                        dFinal=cast([extrapolatedData;interpolatedData],"like",d);
                        ts(i)=timeseries(dFinal,tUnion);
                    end
                else

                    dFinal=0;
                    ts(i)=timeseries(dFinal,tUnion);
                end
            end
        end



        function generateRootInportDataFileFromTimeseries(pid,ts,fileName,overwrite)

            if overwrite&&isempty(ts)
                return;
            end

            PidSize=8;
            TimestampSize=8;

            nTs=length(ts);
            tsdata=cell(1,nTs);
            tstime=cell(1,nTs);

            for k=1:nTs
                tsdata{k}=ts(k).Data;
                tstime{k}=ts(k).Time;
            end

            n=length(tstime{1});

            recordSize=PidSize+TimestampSize;
            dataLength=zeros(1,nTs);
            byteSize=zeros(1,nTs);

            for i=1:nTs
                var=tsdata{i}(1);



                if isa(var,'embedded.fi')
                    tsdata{i}=storedInteger(tsdata{i});
                    var=tsdata{i}(1);
                end

                info=whos('var');


                byteSize(i)=info.bytes;
                if~isreal(tsdata{i})&&isreal(var)

                    byteSize(i)=2*byteSize(i);
                end





                if islogical(tsdata{i})
                    tsdata{i}=uint8(tsdata{i});
                end


                if isenum(tsdata{i})
                    tsdata{i}=int32(tsdata{i});
                end


                dims=size(tsdata{i});
                if ndims(tsdata{i})>2 %#ok<ISMAT>
                    dataLength(i)=prod(dims(1:end-1));
                else
                    dataLength(i)=dims(2);
                end

                recordSize=recordSize+dataLength(i)*byteSize(i);
            end


            inputData=zeros(1,recordSize*n,'uint8');
            count=1;

            offset=1;
            for i=1:n
                ti=tstime{1}(i);


                inputData(offset:offset+PidSize-1)=typecast(pid,'uint8');
                offset=offset+PidSize;


                inputData(offset:offset+TimestampSize-1)=typecast(ti,'uint8');
                offset=offset+TimestampSize;


                for k=1:nTs
                    isComplex=~isreal(tsdata{k});
                    if ndims(tsdata{k})>2 %#ok<ISMAT>
                        for j=1:dataLength(k)
                            if i==1
                                count=count+1;
                            end
                            d=tsdata{k}((i-1)*dataLength(k)+j);
                            if isComplex
                                d=[real(d),imag(d)];
                            end

                            inputData(offset:offset+byteSize(k)-1)=typecast(d,'uint8');
                            offset=offset+byteSize(k);
                        end
                    else
                        for j=1:dataLength(k)
                            if i==1
                                count=count+1;
                            end
                            d=tsdata{k}(i,j);
                            if isComplex
                                d=[real(d),imag(d)];
                            end
                            inputData(offset:offset+byteSize(k)-1)=typecast(d,'uint8');
                            offset=offset+byteSize(k);
                        end
                    end

                end
            end



            if overwrite
                f=fopen(fileName,'a');
            else
                f=fopen(fileName,'w');
            end
            fwrite(f,inputData);
            fclose(f);
        end
    end
end



function confStruct=getRootInportConfiguration(appObj,modelName)

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

function ts=getAllTimeseriesFromDataset(ds)
    ts=[];
    for i=1:ds.numElements
        if isa(ds.getElement(i),'Simulink.SimulationData.Dataset')
            ts=[ts,getAllTimeseriesFromDataset(ds.getElement(i))];%#ok<AGROW>
        else
            ts=[ts,ds.getElement(i)];%#ok<AGROW>
        end
    end
end



function[md,externalSignalPlayback]=getCachedMetadata(modelName,buildDir,hasPlaybackBlk,loadexternalinput)

    currentDir=pwd;
    cleanup=onCleanup(@()cd(currentDir));
    cd(buildDir)
    slrt_task_info=fullfile(buildDir,'slrealtime_task_info.m');
    codeDescriptor=coder.internal.getCodeDescriptorInternal(buildDir,247362);

    metadataStruct=([]);
    index=1;
    metadataPortIndex=0;


    searchOption=Simulink.FindOptions('SearchDepth',1);
    inportBlks=cellstr(getfullname(Simulink.findBlocksOfType(modelName,'Inport',searchOption)));

    for i=1:length(inportBlks)
        inportBlk=inportBlks{i};

        portindex=1;
        try
            signal=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(inportBlk,portindex);
            signalInfo=slrealtime.internal.streamingSignalInfoUtil.getSignalsFromCodeDescriptor(signal,codeDescriptor,slrt_task_info);
        catch ME
            codeDescriptor=[];%#ok<NASGU> 
            rethrow(ME);
        end
        metadataStruct(index).BlockName=get_param(inportBlk,'Name');
        metadataStruct(index).BlockPath=inportBlk;
        metadataStruct(index).FullBlockPath=strjoin(signalInfo.blockPath,',');
        metadataStruct(index).Dimensions=signalInfo.dimensions;
        metadataStruct(index).SamplePeriod=str2double(signalInfo.sampleTimeString);
        metadataStruct(index).SigLabel=signalInfo.signalName;
        metadataStruct(index).PortIndex=signalInfo.portNumber;
        metadataStruct(index).BlockType='Inport';



        interpolate=get_param(inportBlk,'Interpolate');
        if strcmp(interpolate,'off')
            metadataStruct(index).Interpolation=0;
            metadataStruct(index).ExtrapolationBeforeFirstDataPoint='Ground value';
            metadataStruct(index).ExtrapolationAfterLastDataPoint='Ground value';
        else
            metadataStruct(index).Interpolation=1;
            metadataStruct(index).ExtrapolationBeforeFirstDataPoint='Linear extrapolation';
            metadataStruct(index).ExtrapolationAfterLastDataPoint='Linear extrapolation';
        end


        if signalInfo.isString||signalInfo.isMessageLine
            error(message('slrealtime:rootinport:UnsupportedMessageOrStringSignal',metadataStruct(index).FullBlockPath));
        end


        portHandles=get_param(inportBlk,'PortHandles');
        metadataStruct(index).StorageClass=get_param(portHandles.Outport,'StorageClass');
        if strcmp(get_param(portHandles.Outport,'TestPoint'),'on')
            metadataStruct(index).TestPoint='yes';
        else
            metadataStruct(index).TestPoint='no';
        end

        metadataStruct(index).OriginalPortIndex=metadataPortIndex;


        metadataStruct(index).IsEnumType=signalInfo.isEnum;
        metadataStruct(index).Enum.EnumStorageTypeId=-1;
        metadataStruct(index).Enum.EnumClassification=signalInfo.enumClassification;
        metadataStruct(index).Enum.EnumClassName=signalInfo.enumClassName;
        metadataStruct(index).Enum.EnumLabels=signalInfo.enumLabels;
        metadataStruct(index).Enum.EnumValues=signalInfo.enumValues;


        metadataStruct(index).IsFixedPoint=signalInfo.isFixedPoint;
        metadataStruct(index).FixedPoint.FixedExp=signalInfo.fxpFixedExponent;
        metadataStruct(index).FixedPoint.Bias=signalInfo.fxpBias;
        metadataStruct(index).FixedPoint.Slope=signalInfo.fxpSlopeAdjFactor;
        metadataStruct(index).FixedPoint.SlopeAdjFactor=signalInfo.fxpSlopeAdjFactor;
        metadataStruct(index).FixedPoint.FractionLength=signalInfo.fxpFractionLength;
        metadataStruct(index).FixedPoint.WordLength=signalInfo.fxpWordLength;
        metadataStruct(index).FixedPoint.Signedness=signalInfo.fxpSignedness;

        metadataStruct(index).IsBus=signalInfo.isNVBus;
        metadataStruct(index).DataType=signalInfo.dataTypeName;

        if isempty(signalInfo.structElements)
            metadataStruct(index).NumElements=0;
        else
            metadataStruct(index).NumElements=signalInfo.structElements;
        end
        metadataStruct(index).TID=signalInfo.tid;

        metadataStruct(index).targetAddress=uint64(signalInfo.targetAddress);
        metadataStruct(index).dataTypeID=signalInfo.dataTypeID;
        metadataStruct(index).dataTypeSize=uint64(signalInfo.dataTypeSize);
        metadataStruct(index).isComplex=signalInfo.isComplex;
        metadataStruct(index).isInport=true;
        metadataStruct(index).NumOutports=1;

        metadataStruct(index).SignalID=0;
        index=index+1;
        metadataPortIndex=metadataPortIndex+1;
    end


    if strcmp(loadexternalinput,'on')&&isempty(metadataStruct)
        error(message('slrealtime:rootinport:RootLevelInputNotUsed'));
    end


    externalSignalPlayback=[];
    if hasPlaybackBlk
        [metadataStruct,externalSignalPlayback]=getCachedPlaybackMetadata(modelName,metadataStruct,{},slrt_task_info,codeDescriptor,externalSignalPlayback);
    end
    md=metadataStruct;
end


function[playbackData,externalSignalPlayback]=getCachedPlaybackMetadata(modelName,metadataStruct,modelBlockPath,slrt_task_info,codeDescriptor,externalSignalPlayback)

    index=length(metadataStruct)+1;
    pbIndex=length(externalSignalPlayback)+1;
    if isempty(metadataStruct)
        metadataPortIndex=0;
    else
        metadataPortIndex=metadataStruct(length(metadataStruct)).OriginalPortIndex+1;
    end


    searchOption=Simulink.FindOptions('IncludeCommented',false);
    playbackBlks=cellstr(getfullname(Simulink.findBlocksOfType(modelName,'Playback',searchOption)));

    for i=1:length(playbackBlks)
        playbackBlk=playbackBlks{i};
        signalIDs=str2num(get_param(playbackBlk,'SignalIDs'));%#ok<ST2NM> %Get the signalID associated with the block

        portHandles=get_param(playbackBlk,'PortHandles');
        fullPlaybackBlkPath=[modelBlockPath,playbackBlk];
        for j=1:length(portHandles.Outport)
            portindex=j;
            try
                signal=slrealtime.internal.instrument.Util.checkAndFormatSignalArgs(fullPlaybackBlkPath,portindex);
                signalInfo=slrealtime.internal.streamingSignalInfoUtil.getSignalsFromCodeDescriptor(signal,codeDescriptor,slrt_task_info);
            catch ME
                codeDescriptor=[];%#ok<NASGU> 
                rethrow(ME);
            end
            metadataStruct(index).BlockName=get_param(playbackBlk,'Name');
            metadataStruct(index).BlockPath=playbackBlk;
            metadataStruct(index).FullBlockPath=strjoin(signalInfo.blockPath,',');
            metadataStruct(index).Dimensions=signalInfo.dimensions;
            metadataStruct(index).SamplePeriod=str2double(signalInfo.sampleTimeString);
            metadataStruct(index).SigLabel=signalInfo.signalName;
            metadataStruct(index).PortIndex=signalInfo.portNumber;
            metadataStruct(index).BlockType='Playback';


            metadataStruct(index).ExtrapolationBeforeFirstDataPoint=get_param(playbackBlk,'ExtrapolationBeforeFirstDataPoint');
            metadataStruct(index).ExtrapolationAfterLastDataPoint=get_param(playbackBlk,'ExtrapolationAfterLastDataPoint');


            if signalInfo.isEnum
                if strcmp(get_param(playbackBlk,'ExtrapolationBeforeFirstDataPoint'),"Linear extrapolation")
                    metadataStruct(index).ExtrapolationBeforeFirstDataPoint="Hold first value";
                end

                if strcmp(get_param(playbackBlk,'ExtrapolationAfterLastDataPoint'),"Linear extrapolation")
                    metadataStruct(index).ExtrapolationAfterLastDataPoint="Hold last value";
                end
            end


            if signalInfo.isFixedPoint&&(strcmp(get_param(playbackBlk,'ExtrapolationBeforeFirstDataPoint'),"Linear extrapolation")||...
                strcmp(get_param(playbackBlk,'ExtrapolationAfterLastDataPoint'),"Linear extrapolation"))
                error(message('slrealtime:rootinport:UnsupportedLinearInterpolationExtrapolationSignal',signalInfo.signalName,metadataStruct(index).FullBlockPath));
            end

            if signalIDs(j)~=0
                sigObj=Simulink.sdi.getSignal(signalIDs(j));
                if strcmp(sigObj.InterpMethod,'linear')
                    if signalInfo.isEnum
                        metadataStruct(index).Interpolation=0;
                    else
                        metadataStruct(index).Interpolation=1;
                    end

                    if signalInfo.isFixedPoint
                        error(message('slrealtime:rootinport:UnsupportedLinearInterpolationExtrapolationSignal',signalInfo.signalName,metadataStruct(index).FullBlockPath));
                    end
                elseif strcmp(sigObj.InterpMethod,'zoh')
                    metadataStruct(index).Interpolation=0;

                    if strcmp(get_param(playbackBlk,'ExtrapolationBeforeFirstDataPoint'),"Linear extrapolation")
                        metadataStruct(index).ExtrapolationBeforeFirstDataPoint="Hold first value";
                    end

                    if strcmp(get_param(playbackBlk,'ExtrapolationAfterLastDataPoint'),"Linear extrapolation")
                        metadataStruct(index).ExtrapolationAfterLastDataPoint="Hold last value";
                    end
                else

                    error(message('slrealtime:rootinport:UnsupportedMessageOrStringSignal',metadataStruct(index).FullBlockPath));
                end
            else
                metadataStruct(index).Interpolation=0;
            end


            if signalInfo.isString||signalInfo.isMessageLine
                error(message('slrealtime:rootinport:UnsupportedMessageOrStringSignal',metadataStruct(index).FullBlockPath));
            end


            metadataStruct(index).StorageClass=get_param(portHandles.Outport(j),'StorageClass');
            if strcmp(get_param(portHandles.Outport(j),'TestPoint'),'on')
                metadataStruct(index).TestPoint='yes';
            else
                metadataStruct(index).TestPoint='no';
            end

            metadataStruct(index).OriginalPortIndex=metadataPortIndex;


            metadataStruct(index).IsEnumType=signalInfo.isEnum;
            metadataStruct(index).Enum.EnumStorageTypeId=-1;
            metadataStruct(index).Enum.EnumClassification=signalInfo.enumClassification;
            metadataStruct(index).Enum.EnumClassName=signalInfo.enumClassName;
            metadataStruct(index).Enum.EnumLabels=signalInfo.enumLabels;
            metadataStruct(index).Enum.EnumValues=signalInfo.enumValues;


            metadataStruct(index).IsFixedPoint=signalInfo.isFixedPoint;
            metadataStruct(index).FixedPoint.FixedExp=signalInfo.fxpFixedExponent;
            metadataStruct(index).FixedPoint.Bias=signalInfo.fxpBias;
            metadataStruct(index).FixedPoint.Slope=signalInfo.fxpSlopeAdjFactor;
            metadataStruct(index).FixedPoint.SlopeAdjFactor=signalInfo.fxpSlopeAdjFactor;
            metadataStruct(index).FixedPoint.FractionLength=signalInfo.fxpFractionLength;
            metadataStruct(index).FixedPoint.WordLength=signalInfo.fxpWordLength;
            metadataStruct(index).FixedPoint.Signedness=signalInfo.fxpSignedness;

            metadataStruct(index).IsBus=signalInfo.isNVBus;
            metadataStruct(index).DataType=signalInfo.dataTypeName;

            if isempty(signalInfo.structElements)
                metadataStruct(index).NumElements=0;
            else
                metadataStruct(index).NumElements=signalInfo.structElements;
            end

            metadataStruct(index).TID=signalInfo.tid;
            metadataStruct(index).targetAddress=uint64(signalInfo.targetAddress);
            metadataStruct(index).dataTypeID=signalInfo.dataTypeID;
            metadataStruct(index).dataTypeSize=uint64(signalInfo.dataTypeSize);
            metadataStruct(index).isComplex=signalInfo.isComplex;
            metadataStruct(index).isInport=false;
            metadataStruct(index).NumOutports=length(portHandles.Outport);

            metadataStruct(index).SignalID=signalIDs(j);

            externalSignalPlayback(pbIndex)=signalIDs(j);
            pbIndex=pbIndex+1;
            index=index+1;
            metadataPortIndex=metadataPortIndex+1;
        end
    end




    [~,mdlBlks]=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
    for nMdlBlk=1:length(mdlBlks)
        mdlBlk=mdlBlks(nMdlBlk);

        if strcmp(char(get_param(mdlBlk,'ProtectedModel')),'on')
            continue;
        end

        mdlBlkPath=[modelBlockPath,mdlBlk];
        [metadataStruct,externalSignalPlayback]=getCachedPlaybackMetadata(char(get_param(mdlBlk,'ModelName')),metadataStruct,mdlBlkPath,slrt_task_info,codeDescriptor,externalSignalPlayback);
    end
    playbackData=metadataStruct;
end

function[entries,dataSize]=generateSignalStreamEntryFromNonBusInput(entries,dtSize,dataSize,interpolation,portIndex,blockName,dtid,addressOffset,isComplex)
    e=struct('address',[],'size',[],'dtid',[],'portnumber',[],"blockpath",'');
    e.portnumber=portIndex;
    blockName=strrep(blockName,'\n',' ');
    e.blockpath=blockName;


    if interpolation
        e.dtid=dtid;
    else
        e.dtid=0;
    end
    e.address=addressOffset;


    if(isComplex==1)
        dtSize=dtSize*2;
    end
    e.size=dtSize;

    if isempty(entries)
        entries=e;
    else
        entries(end+1)=e;
    end
    dataSize=dataSize+dtSize;
end


function[entries,dataSize]=generateSignalStreamEntryFromBusInput(modelName,entries,dataSize,interpolation,portIndex,blockName,structElements,addressOffset)

    elements=structElements;


    for bi=1:length(elements)
        width=prod(elements(bi).dimensions);
        addressOffsetElement=addressOffset+uint64(elements(bi).structElementOffset);
        for i=1:width
            addressOffsetDimension=addressOffsetElement+uint64((i-1)*elements(bi).dataTypeSize);
            if elements(bi).isNVBus
                busElements=elements(bi).structElements;
                [entries,dataSize]=generateSignalStreamEntryFromBusInput(modelName,entries,dataSize,interpolation,portIndex,blockName,busElements,addressOffsetDimension);
            else
                datatypeSize=uint64(elements(bi).dataTypeSize);
                dataTypeID=elements(bi).dataTypeID;
                [entries,dataSize]=generateSignalStreamEntryFromNonBusInput(entries,datatypeSize,dataSize,interpolation,portIndex,blockName,dataTypeID,addressOffsetDimension,elements(bi).isComplex);
            end
        end
    end

end

function stimdbjson=generateInputStreamDatabase(modelName,codeDescDir,metadata)



    ri=1;
    numInputPorts=length(metadata);


    for i=1:numInputPorts


        entries=[];
        dataSize=0;
        width=prod(metadata(i).Dimensions);
        blockName=metadata(i).FullBlockPath;

        for j=1:width
            addressOffset=metadata(i).targetAddress+(j-1)*metadata(i).dataTypeSize;
            if metadata(i).IsBus
                [entries,dataSize]=generateSignalStreamEntryFromBusInput(modelName,entries,dataSize,metadata(i).Interpolation,...
                metadata(i).OriginalPortIndex,blockName,metadata(i).NumElements,addressOffset);
            else
                isComplex=metadata(i).isComplex;
                [entries,dataSize]=generateSignalStreamEntryFromNonBusInput(entries,metadata(i).dataTypeSize,dataSize,metadata(i).Interpolation,...
                metadata(i).OriginalPortIndex,blockName,metadata(i).dataTypeID,addressOffset,isComplex);
            end
        end
        stimListDatabase.channels(ri).entries=entries;
        stimListDatabase.channels(ri).data_size=dataSize;
        stimListDatabase.channels(ri).tid=metadata(i).TID;
        if strcmp(metadata(i).ExtrapolationAfterLastDataPoint,"Linear extrapolation")
            stimListDatabase.channels(ri).extrapolationAfterLastDataPoint=0;
        elseif strcmp(metadata(i).ExtrapolationAfterLastDataPoint,"Hold last value")
            stimListDatabase.channels(ri).extrapolationAfterLastDataPoint=1;
        else
            stimListDatabase.channels(ri).extrapolationAfterLastDataPoint=2;
        end
        ri=ri+1;
    end

    stimListDatabase.num_entries=length(entries);



    codeDesc=coder.getCodeDescriptor(codeDescDir,247362);
    dmr_model=codeDesc.getMF0FullModel;

    scm=SharedCodeManager.ModelInterface(fullfile(codeDescDir,dmr_model.sharedCodeManagerPath,'shared_file.dmr'));
    modelData=scm.retrieveModelData(modelName,'SLBUILD');

    stimListDatabase.model_checksum=modelData.ModelChecksum;


    stimdbjson=jsonencode(stimListDatabase);
end



function addArtifactsToApplication(appObj,modelName,stimdbjson,metadata,externalInputRootInport,loadexternalinput,externalInputPlayback)


    jsonFileName='inputdb.json';
    jsonFilePath=[appObj.getWorkingDir,filesep,'inputdb.json'];


    f=fopen(jsonFilePath,'w');
    fprintf(f,stimdbjson);
    fclose(f);


    appObj.add(['/ri/',jsonFileName],jsonFilePath);

    matFileName=[modelName,'_RI.mat'];
    matFilePath=[appObj.getWorkingDir,filesep,matFileName];
    save(matFilePath,'metadata','externalInputRootInport','loadexternalinput','stimdbjson','externalInputPlayback');


    appObj.add(['/ri/',matFileName],matFilePath);

end


function ds=generateTimeseriesFromLegacyDoubleInput(~,input,metadata)

    ds=Simulink.SimulationData.Dataset;


    dataArray=input;

    nDataVectors=size(dataArray,2)-1;

    numInputPorts=length(metadata);
    sumOfAllDimensions=0;
    for i=1:numInputPorts
        sumOfAllDimensions=sumOfAllDimensions+prod(metadata(i).Dimensions);
    end



    if nDataVectors~=sumOfAllDimensions
        error(message('Simulink:Logging:UTInvDim',nDataVectors,sumOfAllDimensions))
    end


    t=dataArray(:,1);


    u=dataArray(:,2:end);



    portIndex=1;
    for i=1:length(metadata)
        ts=timeseries;
        ts.Time=t;

        dim=size(metadata(i).Dimensions);
        if dim(2)==1
            Dimension=metadata(i).Dimensions(1);
        else
            Dimension=metadata(i).Dimensions(2);
        end

        for j=1:Dimension
            ts.Data(:,j)=u(:,portIndex);
            portIndex=portIndex+1;
        end
        ds=ds.addElement(ts);
    end

end


function ds=generateTimeseriesFromLegacyStructInput(ds,appObj,inputStruct,metadata,portIndex,numExternalInputs)

    numInputPorts=length(metadata);
    sumOfAllDimensions=0;
    for i=1:numInputPorts
        sumOfAllDimensions=sumOfAllDimensions+prod(metadata(i).Dimensions);
    end



    inputStruct=inputStruct(1);


    if~isfield(inputStruct,'signals')...
        ||~isstruct(inputStruct.signals)...
        ||~isfield(inputStruct.signals,'values')

        error(message('Simulink:Logging:ExtInpEvalErr'));
    end

    numSignals=length(inputStruct.signals);

    if numExternalInputs~=1&&numSignals~=1
        error(message('Simulink:SimInput:FromwksMultipleSignals','external input',appObj.File,numSignals,1))
    end

    if numExternalInputs==1&&numSignals~=numInputPorts
        if length(inputStruct.signals)==1
            error(message('Simulink:Logging:UTInvDim',numSignals,sumOfAllDimensions))
        else
            error(message('slrealtime:rootinport:NumExtInpMismatch',numInputPorts,numSignals))
        end
    end

    for i=1:length(inputStruct.signals)

        if numExternalInputs==1
            portIndex=i;
        end


        sampletime=metadata(i).SamplePeriod;

        values=inputStruct.signals(i).values;
        dims=size(values);
        dim=dims(ndims(values));

        if dim~=prod(metadata(portIndex).Dimensions)
            error(message('Simulink:SimInput:InportPortDimsMismatch',portIndex,dim,prod(metadata(portIndex).Dimensions)))
        end

        nSamples=size(values,1);
        if isempty(inputStruct.time)
            t=(0:(nSamples-1))*sampletime;
        else
            t=inputStruct.time;
            if nSamples~=length(inputStruct.time)
                error(message('Simulink:SimInput:FromwksDifferentNumRows','external input',appObj.File))
            end
        end
        ds=ds.addElement(timeseries(values,t));
    end
end

function ds=generateDataset(appObj,modelName,input,metadata)


    ds=Simulink.SimulationData.Dataset;

    numInputPorts=length(metadata);
    numExternalInputs=length(input);

    if numExternalInputs~=numInputPorts&&numExternalInputs~=1
        error(message('Simulink:Logging:InvInputLoadNameList',numInputPorts,numExternalInputs))
    end

    for k=1:numExternalInputs
        inputData=input{k};




        if~metadata(k).IsBus
            switch class(inputData)
            case 'double'
                ds=generateTimeseriesFromLegacyDoubleInput(appObj,inputData,metadata);
                return
            case 'struct'
                ds=generateTimeseriesFromLegacyStructInput(ds,appObj,inputData,metadata,k,numExternalInputs);
                continue
            end
        end








        dimension=size(metadata(k).Dimensions);
        if dimension(2)==1
            dim=metadata(k).Dimensions(1);
        else
            dim=metadata(k).Dimensions(2);
        end


        sampletime=metadata(k).SamplePeriod;

        if metadata(k).IsBus
            ds1=Simulink.SimulationData.Dataset;
            portWidth=prod(metadata(k).Dimensions);
            for i=1:dim
                if i<=length(inputData)

                    ds1=generateTimeSeriesFromBusInput(ds1,modelName,metadata(k).DataType,metadata,k,portWidth,inputData(i),1,sampletime);
                else
                    ds1=generateTimeSeriesFromBusInput(ds1,modelName,metadata(k).DataType,metadata,k,portWidth,[],1,sampletime);
                end
            end
            ds=ds.addElement(ds1);
        else
            ds=generateTimeseriesFromNonBusInput(ds,inputData,sampletime);








        end
    end
end

function ds=generateTimeSeriesFromBusInput(ds,modelName,busName,metadata,portIndex,portWidth,inputStruct,dim,sampletime)

    bus=findRootInportData(modelName,busName);
    if iscell(bus)
        bus=bus{1,1};
    end
    if isempty(bus)

        return
    end

    if isa(inputStruct,'Simulink.SimulationData.Signal')

        inputStruct=inputStruct.Values;
    end


    if isempty(inputStruct)||~isstruct(inputStruct)

        leafElements=bus.getLeafBusElements;
        for i=1:length(leafElements)
            width=prod(leafElements(i).Dimensions);
            gnd=zeros(1,width,leafElements(i).DataType);
            ds=ds.addElement(timeseries(gnd,0));
        end
        return
    end







    elements=bus.Elements;
    for i=1:dim
        for bi=1:length(elements)
            dt=elements(bi).DataType;
            width=prod(elements(bi).Dimensions);
            if strncmp(dt,'Bus: ',5)
                childBusName=dt(6:end);

                if~isfield(inputStruct,elements(bi).Name)||i>length(inputStruct)
                    ds=generateTimeSeriesFromBusInput(ds,modelName,childBusName,metadata,portIndex,portWidth,[]);
                else
                    ds=generateTimeSeriesFromBusInput(ds,modelName,childBusName,metadata,portIndex,portWidth,inputStruct(i).(elements(bi).Name),elements(bi).Dimensions,sampletime);
                end
            else
                if~isfield(inputStruct,elements(bi).Name)||i>length(inputStruct)
                    gnd=zeros(1,width,elements(bi).DataType);
                    ds=ds.addElement(timeseries(gnd,0));
                else
                    ds=generateTimeseriesFromNonBusInput(ds,inputStruct(i).(elements(bi).Name),sampletime);
                end
            end
        end
    end
end


function ds=generateTimeseriesFromNonBusInput(ds,inputData,~)

    switch class(inputData)
    case 'Simulink.SimulationData.Signal'

        ds=ds.addElement(inputData.Values);
    case 'timeseries'

        ds=ds.addElement(inputData);
    case 'timetable'

        if size(inputData.Properties.VariableNames,1)>1
            error(message('slrealtime:rootinport:IncorrectTimeTableInput'));
        end

        time=time2number(inputData.Time);
        data=inputData.Variables;
        ds=ds.addElement(timeseries(data,time));
    otherwise
        error(message('Simulink:SimInput:MdlUTNotSupportedFormat'));
    end

end

function data=findRootInportData(modelName,varName)



    data=[];%#ok<NASGU> 
    try
        data=evalin('base',['{',varName,'}']);



    catch
        data=Simulink.data.evalinGlobal(modelName,varName);
    end
end

function data=findPlaybackData(signalIDs)

    data=cell(length(signalIDs),1);
    for i=1:length(signalIDs)
        sigID=signalIDs(i);
        if sigID==0
            data{i}=timeseries();
        else
            sigObj=Simulink.sdi.getSignal(sigID);
            data{i}=sigObj.Values;
        end
    end
end

function[processedData]=processDataVector(inputData,dimension,numVectors,numSamples,interpolated)
    if interpolated

        if dimension>2
            processedData=reshape(inputData,[numVectors,numSamples]);
            processedData=processedData.';
        else
            processedData=reshape(inputData,[numSamples,numVectors]);
        end
    else

        if dimension>2
            processedData=reshape(inputData,[numVectors,numSamples]);
        else
            processedData=reshape(inputData,[numSamples,numVectors]);
            processedData=processedData.';
        end
    end
end

function[X,timeUnit]=time2number(T)
    timeUnit=getDefaultUnits(T);
    X=utilConvertDurationToNumeric(T,timeUnit);
end

function timeUnit=getDefaultUnits(t)

    IsDateTime=isdatetime(t);
    if IsDateTime
        t=t-t(1);
    end

    if isduration(t)
        if IsDateTime||any(strcmp(t.Format,{'hh:mm:ss','dd:hh:mm:ss','mm:ss','hh:mm'}))

            if isscalar(t)
                M=seconds(t);
            else
                M=seconds(mean(diff(t)));
            end

            if M>3600*24*365
                timeUnit="years";
            elseif M>=3600*24
                timeUnit="days";
            elseif M>=3600
                timeUnit="hours";
            elseif M>=60
                timeUnit="minutes";
            else
                timeUnit="seconds";
            end
        else
            switch t.Format
            case 's'
                timeUnit="seconds";
            case 'h'
                timeUnit="hours";
            case 'm'
                timeUnit="minutes";
            case 'd'
                timeUnit="days";
            case 'y'
                timeUnit="years";
            otherwise
                timeUnit="seconds";
            end
        end
    else
        timeUnit="";
    end
end

function[num,start]=utilConvertDurationToNumeric(dvalue,units)

    if isempty(units)||strcmpi(units,"")
        units="seconds";
    else
        units=string(units);
    end

    start=dvalue(1);
    if isdatetime(dvalue)
        dvalue=dvalue-start;
    end

    if(isduration(dvalue))
        switch units
        case{"seconds","s","sec","second"}
            num=seconds(dvalue);
        case{"minutes","m","min","minute"}
            num=minutes(dvalue);
        case{"hours","hr","h","hour"}
            num=hours(dvalue);
        case{"days","d","day"}
            num=days(dvalue);
        case{"years","y","yr","year"}
            num=years(dvalue);
        otherwise
            try
                timeUnit=getDefaultUnits(dvalue);
                [num,start]=utilConvertDurationToNumeric(dvalue,timeUnit);
            catch
                error(message('slrealtime:rootinport:IncorrectDurationFormat'));
            end
        end
    else
        num=dvalue;
    end
end
