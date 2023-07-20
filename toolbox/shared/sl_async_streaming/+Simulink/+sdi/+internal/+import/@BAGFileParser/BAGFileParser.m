classdef BAGFileParser<Simulink.sdi.internal.import.FileParser





    methods

        function runID=import(this,varParsers,repo,addToRunID,varargin)
            runID=importFromBag(this,repo,varParsers,addToRunID);
        end


        function runID=importFromBag(this,repo,varParsers,addToRunID)
            existingSignalIDs=[];
            if addToRunID<=0

                runID=repo.createEmptyRun(this.RunName,0,'sdi',true);
            else

                runID=addToRunID;
                existingSignalIDs=repo.getAllSignalIDs(runID,'all');
            end
            try
                Simulink.sdi.internal.safeTransaction(...
                @locImportDataFromBag,repo,varParsers,this,runID);
            catch me
                if~isempty(me)
                    warning(me.message);
                end
                if addToRunID<=0

                    repo.removeRun(runID);
                    runID=0;
                    return;
                end

                newSignalIDs=repo.getAllSignalIDs(runID,'all');
                for i=length(existingSignalIDs)+1:length(newSignalIDs)
                    repo.remove(newSignalIDs(i))
                end
            end
        end


        function extension=getFileExtension(~)
            extension={'.bag'};
        end


        function varParsers=getVarParser(this,wksParser,fileName,varargin)
            varParsers={};
            this.Bag=rosbag(fileName);
            availableTopics=this.Bag.AvailableTopics;


            for msgId=1:length(this.ValidMessages)
                currentMessage=this.ValidMessages{msgId};
                currentTopics=availableTopics.Row(availableTopics.MessageType==currentMessage);
                for topicId=1:length(currentTopics)
                    currentTopic=currentTopics{topicId};
                    bagSelect=select(this.Bag,'Topic',currentTopic);
                    if bagSelect.NumMessages>0
                        switch currentMessage
                        case this.ValidMessages{1}
                            varParser=this.getNavigationDataParser(currentTopic,wksParser);
                        case this.ValidMessages{2}
                            varParser=this.getVideoDataParser(currentTopic,wksParser);
                        end
                        varParsers{end+1}=varParser;%#ok
                        this.VarParserTypes{end+1}=currentMessage;
                    end
                end
            end
        end


        function msg=getValidMessageById(this,msgId)
            msg=this.ValidMessages{msgId};
        end


        function bag=getBagObject(this)
            bag=this.Bag;
        end


        function parserTypes=getParserTypes(this)
            parserTypes=this.VarParserTypes;
        end
    end


    methods(Access=private)

        function varParser=getNavigationDataParser(~,currentTopic,wksParser)
            gpsSignals={'Latitude','Longitude','Altitude'};
            gpsDataset=Simulink.SimulationData.Dataset();
            for idx=1:length(gpsSignals)
                gpsSigTs=timeseries(0,'Name',gpsSignals{idx});
                gpsDataset=gpsDataset.addElement(gpsSigTs);
            end
            varParser=Simulink.sdi.internal.import.DatasetParser;
            varParser.VariableName=currentTopic;
            varParser.VariableValue=gpsDataset;
            varParser.TimeSourceRule='';
            varParser.WorkspaceParser=wksParser;
        end


        function varParser=getVideoDataParser(~,currentTopic,wksParser)
            varParser=Simulink.sdi.internal.import.TimeseriesParser;
            varParser.VariableName=currentTopic;
            varParser.VariableValue=timeseries(0,'name',currentTopic);
            varParser.TimeSourceRule='';
            varParser.WorkspaceParser=wksParser;
        end
    end

    properties(Access=private)
        ValidMessages={
        'sensor_msgs/NavSatFix',...
'sensor_msgs/Image'
        };
        Bag;
        VarParserTypes={};
    end
end


function locImportDataFromBag(repo,varParsers,bagFileParserObj,runID)
    parserTypes=bagFileParserObj.getParserTypes();
    for parserId=1:length(varParsers)
        currentParserType=parserTypes{parserId};
        switch currentParserType
        case bagFileParserObj.getValidMessageById(1)

            varParserNav=varParsers{parserId};
            locImportNavigationDataFromBag(repo,varParserNav,bagFileParserObj,runID);
        case bagFileParserObj.getValidMessageById(2)

            varParserVideo=varParsers{parserId};
            if~isVariableChecked(varParserVideo)
                disp('signal unchecked');
            end
            locImportVideoFromBag(varParserVideo,bagFileParserObj,runID);
        end
    end
end


function locImportNavigationDataFromBag(repo,varParserNav,bagFileParserObj,runID)
    if~isVariableChecked(varParserNav)
        return;
    end
    bag=bagFileParserObj.getBagObject();
    gpsTopic=varParserNav.VariableName;
    gpsDataSelect=select(bag,'Topic',gpsTopic);
    gpsDataStructs=readMessages(gpsDataSelect,'DataFormat','struct');
    nOfMessages=length(gpsDataStructs);
    timeVals=gpsDataSelect.MessageList.Time;

    t0=timeVals(1);
    timeVector=0;
    for i=2:length(timeVals)
        timeVector(i)=timeVals(i)-t0;%#ok
    end
    latitudeArray=zeros(nOfMessages,1);
    longitudeArray=zeros(nOfMessages,1);
    altitudeArray=zeros(nOfMessages,1);
    for i=1:length(gpsDataStructs)
        latitudeArray(i)=gpsDataStructs{i}.Latitude;
        longitudeArray(i)=gpsDataStructs{i}.Longitude;
        altitudeArray(i)=gpsDataStructs{i}.Altitude;
    end
    childParsers=getChildren(varParserNav);

    parentSignalID=locCreateSignal(repo,runID,int32.empty,varParserNav);
    if parentSignalID>0
        for idx=1:length(childParsers)
            currSigVals=zeros(nOfMessages,1);
            currSigName=childParsers{idx}.VariableValue.Name;
            for idx1=1:length(gpsDataStructs)
                currSigVals(idx1)=gpsDataStructs{idx1}.(currSigName);
            end
            ts=timeseries(currSigVals,timeVector,'Name',currSigName);
            childParsers{idx}.VariableValue=ts;
            locCreateSignal(repo,runID,parentSignalID,childParsers{idx});
        end
    end
end


function locImportVideoFromBag(varParserVid,bagFileParserObj,runID)
    if~isVariableChecked(varParserVid)
        return;
    end

    bag=bagFileParserObj.getBagObject();
    imgTopic=varParserVid.VariableName;
    bagSelect=select(bag,'Topic',imgTopic);
    imgTopic=strrep(imgTopic,'/','_');
    videoFileName=['VideoSignal',imgTopic];
    v=VideoWriter(videoFileName,'MPEG-4');
    open(v);
    for idx=1:bagSelect.NumMessages
        currentFrameCell=readMessages(bagSelect,idx);
        currentFrame=currentFrameCell{1};
        currentImg=readImage(currentFrame);
        try
            writeVideo(v,currentImg);
        catch
        end
    end
    close(v);

    videoSignalPath=[videoFileName,'.mp4'];
    destPath=[matlabroot,'\toolbox\shared\sdi\web\MainView\',videoSignalPath];
    movefile(videoSignalPath,destPath,'f');
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.createVideoSignal(...
    runID,...
    videoFileName,...
    'FromFile',['\toolbox\shared\sdi\web\MainView\',videoSignalPath]);
end


function sigID=locCreateSignal(repo,runID,parentSigID,varParser)
    if~isVariableChecked(varParser)
        sigID=0;
        return
    end

    sampleDims=int32(getSampleDims(varParser));
    timeDim=int32(getTimeDim(varParser));
    dataVals=getTimeAndDataForSignalConstruction(varParser);
    hasData=~isempty(dataVals.Data);
    if~hasData
        dataVals=[];
    end
    bpath=getBlockSource(varParser);
    signalName=getSignalLabel(varParser);

    if hasData
        channelIdx=int32(1);
    else
        channelIdx=int32.empty;
    end
    sigID=repo.add(...
    repo,...
    runID,...
    getRootSource(varParser),...
    getTimeSource(varParser),...
    getDataSource(varParser),...
    dataVals,...
    bpath,...
    getModelSource(varParser),...
    signalName,...
    timeDim,...
    sampleDims,...
    int32(getPortIndex(varParser)),...
    channelIdx,...
    getSID(varParser),...
    getMetaData(varParser),...
    int32(parentSigID),...
    getRootSource(varParser),...
    getInterpolation(varParser),...
    getUnit(varParser));
    if hasData
        repo.setSignalDataValues(sigID,dataVals);
    end
end
