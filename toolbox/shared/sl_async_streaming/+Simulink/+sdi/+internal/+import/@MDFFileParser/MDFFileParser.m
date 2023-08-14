classdef MDFFileParser<Simulink.sdi.internal.import.FileParser













    methods

        function runID=import(this,varParsers,~,addToRunID,varargin)
            setupData=locGetSetupData(this.Filename);
            setupData.appName='sdi';
            message.publish('/sdi2/progressUpdate',setupData);
            tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',...
            struct('dataIO','end','appName',setupData.appName)));

            toBeImportedList=logical(ones(1,length(varParsers)));%#ok
            for idx=1:length(toBeImportedList)
                if~isVariableChecked(varParsers{idx})
                    toBeImportedList(idx)=false;
                end
            end

            runID=importFromMDF(...
            this,...
            this.Filename,...
            this.RunName,...
            this.CmdLine,...
            addToRunID,...
            toBeImportedList);
        end


        function extension=getFileExtension(~)
            extension=[{'.mf4'},{'.mf3'},{'.mdf'},{'.data'},{'.dat'}];
        end


        function runID=importFromMDF(this,filename,runName,~,addToRunID,toBeImportedList)
            [runID,~]=Simulink.sdi.importTimeseriesDataFromMDF(...
            filename,...
            runName,...
            this.CmdLine,...
            addToRunID,...
            toBeImportedList);
            if~runID
                runID=[];
            end
        end


        function varParsers=getVarParser(this,wksParser,filename,varargin)
            varParsers=this.parseMDFObject(wksParser,filename);
        end
    end


    methods(Access=private)


        function varParsers=parseMDFObject(this,wksParser,filename)
            this.SignalMetaData={};
            varParsers={};
            channelGroupData=Simulink.sdi.parseMetaDataFromMDF(...
            filename,...
            this.RunName,...
            this.CmdLine,...
            0);



            foundSupportedSignal=false;
            for chGrpIt=1:length(channelGroupData)
                chNames=channelGroupData(chGrpIt).ChannelNames;
                if channelGroupData(chGrpIt).NumSamples>0
                    for chNameIt=1:length(chNames)-1
                        chDataType=channelGroupData(chGrpIt).ChannelDataTypes{chNameIt};

                        if chDataType>=0&&chDataType<=5
                            ts=timeseries(0);
                            ts.Name=chNames{chNameIt};
                            this.SignalMetaData{chGrpIt}{chNameIt}.Unit=channelGroupData(chGrpIt).ChannelUnits{chNameIt};
                            tsParser=setTimeSeriesParser(ts,chNames{chNameIt},wksParser);
                            varParsers{end+1}=tsParser;%#ok
                            foundSupportedSignal=true;
                        end
                    end
                end
            end
            if~foundSupportedSignal

                errorStr=getString(message('SDI:sdi:MDFUnsupportedDataTypeErr'));
                ME=MException('MDFImport:UnsupportedDataType',...
                errorStr);
                throw(ME);
            end
        end

    end

    properties(Access=private)
        SignalMetaData={};
    end
end


function tsParser=setTimeSeriesParser(ts,channelName,wksParser)
    tsParser=Simulink.sdi.internal.import.TimeseriesParser;
    tsParser.VariableName=channelName;
    tsParser.VariableValue=ts;
    tsParser.WorkspaceParser=wksParser;
end


function setupData=locGetSetupData(fileName)
    setupData=struct;
    [~,shortFilename,~]=fileparts(fileName);
    setupData.dataIO='begin';
    setupData.isMldatx=true;
    setupData.isModal=true;
    setupData.statusMsg=getString(message('SDI:sdi:InitializingProgress'));
    setupData.fileName=shortFilename;
    setupData.currentVal=0;
end