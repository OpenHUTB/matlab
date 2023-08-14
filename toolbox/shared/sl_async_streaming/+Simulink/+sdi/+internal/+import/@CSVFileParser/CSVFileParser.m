classdef CSVFileParser<Simulink.sdi.internal.import.FileParser











    methods


        function runID=import(this,varParser,~,addToRunID,varargin)
            setupData=locGetSetupData(this.Filename);
            setupData.appName='sdi';
            message.publish('/sdi2/progressUpdate',setupData);
            tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',...
            struct('dataIO','end','appName',setupData.appName)));




            toBeImportedList=logical(ones(1,length(varParser)));%#ok
            for idx=1:length(toBeImportedList)
                if~isVariableChecked(varParser{idx})
                    toBeImportedList(idx)=false;
                end
            end

            try
                runID=importFromCSV(...
                this,...
                this.Filename,...
                this.RunName,...
                this.CmdLine,...
                addToRunID,...
                toBeImportedList);
            catch

                msgID='CSVImport:InvalidTime';
                msg=getString(message('SDI:sdi:TimeNotIncMonotonicallyErr'));
                impEx=MException(msgID,msg);
                throw(impEx);
            end
        end


        function extension=getFileExtension(~)
            extension={'.csv'};
        end


        function runID=importFromCSV(~,filename,runName,isBlocking,addToRunID,toBeImportedList)
            [runID,~]=Simulink.sdi.importTimeseriesDataFromCSV(...
            filename,...
            runName,...
            isBlocking,...
            addToRunID,...
            toBeImportedList);
            if~runID
                runID=[];
            end
        end


        function varParsers=getVarParser(this,wksParser,fileName,varargin)
            [fPath,fName,ext]=fileparts(fileName);
            fileFound=true;%#ok
            if isempty(fPath)


                currentFolder=cd;
                fileFound=exist(fullfile(currentFolder,[fName,ext]),...
                'file')==2;
            else


                fileFound=isequal(exist(fileName,'file'),2);
            end
            if~fileFound


                msgID='SDIImport:Cancelled';
                msg=getString(message('SDI:sdi:ImportFileNotFound'));
                impEx=MException(msgID,msg);
                throw(impEx);
            end
            varParsers={};
            metadata=Simulink.sdi.parseMetaDataFromCSV(fileName,this.RunName,this.CmdLine,0);
            numSignals=length(metadata);
            colIndices=zeros(1,numSignals);
            signalNames=cell(1,numSignals);
            mdp=Simulink.sdi.internal.import.MetaDataParser;
            for sigIdx=1:numSignals
                signalNames{sigIdx}=metadata(sigIdx).SignalName;
                colIndices(sigIdx)=metadata(sigIdx).ColumnIndex;
            end
            mdp.reset(signalNames,colIndices);
            for sigIdx=1:numSignals
                signalMetadata=locGetSignalMetadataCellArray(metadata(sigIdx));
                for metadataIdx=1:length(signalMetadata)
                    metaDataStr=strtrim(signalMetadata{metadataIdx});
                    mdp.parseRow(sigIdx,metaDataStr,false);
                end

            end
            ds=mdp.constructDatasetFromMetaData();
            uniqueSigNames=matlab.lang.makeUniqueStrings(signalNames);
            for idx=1:numel(ds)
                varParser=Simulink.sdi.internal.import.DatasetElementParser;
                varParser.VariableName=signalNames{idx};
                varParser.VariableValue=ds{idx};
                varParser.TimeSourceRule='';
                varParser.WorkspaceParser=wksParser;
                varParser.setUniqueKeyStr([uniqueSigNames{idx},'.Values']);
                varParsers{end+1}=varParser;%#ok
            end
            this.VarParsers=varParsers;
        end
    end

    properties(Access=private)
        VarParsers={};
    end
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


function ret=locGetSignalMetadataCellArray(sigMetadata)
    ret={};
    if~isempty(sigMetadata.DataType)
        ret{end+1}=['Type: ',sigMetadata.DataType];
    end
    if~isempty(sigMetadata.Units)
        ret{end+1}=['Units: ',sigMetadata.Units];
    end
    if~isempty(sigMetadata.Interpolation)
        ret{end+1}=['Interp: ',sigMetadata.Interpolation];
    end
    if~isempty(sigMetadata.Blockpath)
        ret{end+1}=['BlockPath: ',sigMetadata.Blockpath];
    end
    if~isempty(sigMetadata.PortIndex)
        pIndex='';
        if~isequal(sigMetadata.PortIndex,0)
            pIndex=num2str(sigMetadata.PortIndex);
        end
        ret{end+1}=['PortIndex: ',pIndex];
    end
end
