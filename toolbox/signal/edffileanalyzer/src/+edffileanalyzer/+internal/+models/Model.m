

classdef Model<handle


    properties(Access=private)
SignalMgr
FileInfo
    end

    methods

        function this=Model(signalMgr,inputSignal)
            this.SignalMgr=signalMgr;
            this.FileInfo=struct;
            if~isempty(inputSignal)
                this.setFileInfo(inputSignal,false);
            end
        end


        function signalData=getSignalData(this,fileName)
            fileInfo=this.getFileInfo();
            signalIDs=fileInfo.SignalIDs;
            signalData.SignalIDs=signalIDs;
            edfData=edfread(fileName);
            signalData.SignalData=this.getDataToBePlottedByFileType(edfData);
            signalData.PlottingMap.SignalIDs=signalIDs;
            signalData.PlottingMap.LegendLabels=fileInfo.Info.SignalLabels;
            signalData.PlottingMap.PhysicalDimensions=fileInfo.Info.PhysicalDimensions;
        end

        function dataToBePlotted=getDataToBePlottedByFileType(this,edfData)
            [fileType,recordingType]=signal.internal.edf.write.getFileType(this.FileInfo.Info.Reserved,true);

            columnNames=edfData.Properties.VariableNames;
            dataToBePlotted=[];
            dataRecordDuration=this.FileInfo.DataDurationFunc(this.FileInfo.Info.DataRecordDuration);
            numDataRecords=this.FileInfo.Info.NumDataRecords;
            sampleRates=[];
            for idx=1:numel(columnNames)
                columnData=edfData.(columnNames{idx});
                if iscell(columnData)
                    columnData=cell2mat(columnData);
                end
                [~,sampleRate]=signal.internal.edf.write.calculateSamples({columnData(:)},numDataRecords,dataRecordDuration);
                sampleRates=[sampleRates;sampleRate];
            end
            maxSampleRate=max(sampleRates);

            this.FileInfo.xMultiplier=1/maxSampleRate;
            if fileType=="EDF"||recordingType=="Continuous"
                for idx=1:numel(columnNames)
                    [P,Q]=rat(maxSampleRate/sampleRates(idx));
                    columnData=edfData.(columnNames{idx});
                    if iscell(columnData)
                        columnData=cell2mat(columnData);
                    end
                    resampledData=resample(columnData,P,Q);
                    dataToBePlotted=[dataToBePlotted,{resampledData}];
                end
            else
                for idx=1:numel(columnNames)

                    columnDataCellArray=edfData.(columnNames{idx});
                    columnDataMatrix=[columnDataCellArray{:}];
                    [~,sampleRate]=signal.internal.edf.write.calculateSamples({columnDataMatrix(:)},numDataRecords,dataRecordDuration);
                    recordTime=this.FileInfo.DataDurationFunc(edfData.("Record Time"));

                    timeGap=recordTime(1);
                    signalData=nan(sampleRate*timeGap,1);
                    for recordTimeIdx=1:numel(recordTime)-1


                        timeGap=recordTime(recordTimeIdx+1)-recordTime(recordTimeIdx)-dataRecordDuration;
                        insertArray=nan(round(sampleRate*timeGap),1);
                        signalData=[signalData;columnDataMatrix(:,recordTimeIdx);insertArray];
                    end

                    signalData=[signalData;columnDataMatrix(:,recordTimeIdx+1)];
                    [P,Q]=rat(maxSampleRate/sampleRates(idx));
                    resampledData=resample(signalData,P,Q);
                    dataToBePlotted=[dataToBePlotted,{resampledData}];
                end
            end
        end


        function tableData=getDataForSignalsTable(this)






            tableData=[];
            fileInfo=this.FileInfo;
            signalLabels=fileInfo.Info.SignalLabels;
            for idx=1:numel(signalLabels)
                rowData=[];
                rowData=[rowData,fileInfo.SignalIDs(idx)];%#ok<*AGROW>
                rowData=[rowData,signalLabels(idx)];
                rowData=[rowData,"1"];



                rowData=[rowData,"#ffffff"];
                tableData=[tableData;rowData];
            end
        end

        function tableData=getDataForHeaderPropertiesTable(this)






            fileInfo=this.FileInfo.Info;
            tableData=["Version",fileInfo.Version];%#ok<*AGROW>
            tableData=[tableData;["Patient",fileInfo.Patient]];
            tableData=[tableData;["Recording",fileInfo.Recording]];
            tableData=[tableData;["StartDate",fileInfo.StartDate]];
            tableData=[tableData;["HeaderBytes",fileInfo.HeaderBytes]];
            tableData=[tableData;["NumDataRecords",fileInfo.NumDataRecords]];
            tableData=[tableData;["DataRecordDuration",string(fileInfo.DataRecordDuration)]];
            tableData=[tableData;["NumSignals",fileInfo.NumSignals]];
        end

        function tableData=getDataForSignalPropertiesTable(this,signalID)






            isFileHasSignals=isfield(this.FileInfo,'SignalIDs');
            if nargin<2&&isFileHasSignals
                index=1;
            elseif isFileHasSignals
                index=this.FileInfo.SignalIDs==signalID;
            else

                tableData=[];
                return;
            end

            fileInfo=this.FileInfo.Info;
            tableData=["SignalLabel",fileInfo.SignalLabels(index)];
            tableData=[tableData;["TransducerType",fileInfo.TransducerTypes(index)]];
            tableData=[tableData;["PhysicalDimension",fileInfo.PhysicalDimensions(index)]];
            tableData=[tableData;["PhysicalMin",fileInfo.PhysicalMin(index)]];
            tableData=[tableData;["PhysicalMax",fileInfo.PhysicalMax(index)]];
            tableData=[tableData;["DigitalMin",fileInfo.DigitalMin(index)]];
            tableData=[tableData;["DigitalMax",fileInfo.DigitalMax(index)]];
            tableData=[tableData;["Prefilter",fileInfo.Prefilter(index)]];
            tableData=[tableData;["NumSamples",fileInfo.NumSamples(index)]];
            tableData=[tableData;["SignalReserved",fileInfo.SignalReserved(index)]];
        end

        function tableData=getDataForAnnotationsTable(this)






            tableData=[];
            annotations=this.FileInfo.Info.Annotations;
            for idx=1:size(annotations,1)
                rowData=[annotations.Annotations(idx),string(annotations.Onset(idx)),string(annotations.Duration(idx))];
                tableData=[tableData;rowData];
            end
        end


        function signalIDs=resetModel(this)
            signalIDs=this.FileInfo.SignalIDs;
            delete(this.FileInfo.Info);
            this.FileInfo=struct;
            this.SignalMgr.release();
        end

        function[validFileNameFlag,errorMsg]=setFileInfo(this,fileName,isImportFromApp)
            [validFileNameFlag,errorMsg]=this.isFileNameValid(fileName);
            if~validFileNameFlag
                return;
            end
            if isImportFromApp

                try
                    this.FileInfo.Info=edfinfo(fileName);
                catch ME
                    errorMsg=ME.message;
                    validFileNameFlag=false;
                end
                if~validFileNameFlag
                    return;
                end
            else

                this.FileInfo.Info=edfinfo(fileName);
            end
            this.FileInfo.FileName=fileName;
            this.FileInfo.DataDurationFunc=this.getDataDurationFunc();
            validFileNameFlag=true;
        end

        function[isValid,errorMsg]=isFileNameValid(~,fileName)
            isValid=true;
            [~,~,extension]=fileparts(fileName);
            errorMsg="";
            if~strcmpi(extension,".edf")
                errorMsg=getString(message("signal_edffileanalyzer:edffileanalyzer:invalidExtension"));
                isValid=false;
            elseif exist(fileName,"file")~=2
                errorMsg=getString(message("signal_edffileanalyzer:edffileanalyzer:invalidFileName"));
                isValid=false;
            end
        end

        function createSignalIDs(this)
            numberOfSignalLabels=numel(this.FileInfo.Info.SignalLabels);
            if numberOfSignalLabels
                this.FileInfo.SignalIDs=this.SignalMgr.createSignalIDs(numberOfSignalLabels);
            end
        end

        function removeSignalIDs(this,signalIDs)
            this.SignalMgr.removeSignalIDs(signalIDs);
        end



        function fileName=getFileName(this)
            fileInfo=this.FileInfo;
            fileName="";
            if isfield(fileInfo,"FileName")
                fileName=fileInfo.FileName;
            end
        end

        function dataDurationFunc=getDataDurationFunc(this)
            dataRecordDurationStr=string(this.FileInfo.Info.DataRecordDuration);
            splitStr=split(dataRecordDurationStr," ");
            unitStr=splitStr(end);
            switch unitStr
            case{"sec",getString(message("signal_edffileanalyzer:edffileanalyzer:axesXLabelUnitSeconds"))}
                dataDurationFunc=str2func("seconds");
                xLabelCatalogKey="axesXLabelUnitSeconds";
            case{"min",getString(message("signal_edffileanalyzer:edffileanalyzer:axesXLabelUnitMinutes"))}
                dataDurationFunc=str2func("minutes");
                xLabelCatalogKey="axesXLabelUnitMinutes";
            case{"hr",getString(message("signal_edffileanalyzer:edffileanalyzer:axesXLabelUnitHours"))}
                dataDurationFunc=str2func("hours");
                xLabelCatalogKey="axesXLabelUnitHours";
            case{"day","days",getString(message("signal_edffileanalyzer:edffileanalyzer:axesXLabelUnitDays"))}
                dataDurationFunc=str2func("days");
                xLabelCatalogKey="axesXLabelUnitDays";
            case{"yr","yrs",getString(message("signal_edffileanalyzer:edffileanalyzer:axesXLabelUnitYears"))}
                dataDurationFunc=str2func("years");
                xLabelCatalogKey="axesXLabelUnitYears";
            otherwise
                dataDurationFunc=str2func("seconds");
                xLabelCatalogKey="axesXLabelUnitSeconds";
            end
            this.FileInfo.xLabel=getString(message("signal_edffileanalyzer:edffileanalyzer:"+xLabelCatalogKey));
        end

        function xLabel=getXLabel(this)
            xLabel=this.FileInfo.xLabel;
        end

        function xMultiplier=getXMulitplier(this)
            xMultiplier=this.FileInfo.xMultiplier;
        end

        function fileInfo=getFileInfo(this)
            fileInfo=this.FileInfo;
        end

        function isAppHasSignal=isAppHasSignals(this)
            isAppHasSignal=isfield(this.FileInfo,'SignalIDs');
        end
    end
end