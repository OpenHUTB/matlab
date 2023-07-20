classdef SignalBuilderSpreadsheet<Simulink.io.FileType






    properties(Access='protected')

        isExcel=false;
        isCSV=false;


    end



    methods


        function theReader=SignalBuilderSpreadsheet(varargin)

            theReader=theReader@Simulink.io.FileType(varargin{:});

            if~isempty(varargin)

                [~,~,ext]=fileparts(varargin{:});

                if any(strcmpi(ext,{'.xls','.xlsx'}))
                    theReader.isExcel=true;
                elseif strcmpi(ext,'.csv')
                    theReader.isCSV=true;
                else
                    DAStudio.error('sl_web_widgets:customfiles:nonCSVorSpreadsheet');
                end
            end

        end

    end




    methods(Hidden)


        function aList=whosImpl(theReader)


            if theReader.isExcel
                [fileType,SheetNames]=xlsfinfo(theReader.FileName);

                aList=struct;






                isExcelForm=strcmp(fileType,'Microsoft Excel Spreadsheet')&&...
                ~isempty(SheetNames);




                if~ispc&&~isExcelForm
                    aList=[];
                    return;
                end


                for kCell=1:length(SheetNames)
                    resolvedName=deblank(SheetNames{kCell});
                    aList(kCell).name=resolvedName;

                    aList(kCell).type=message('sl_web_widgets:customfiles:datasetType').getString;
                end

            else

                aList.name='Imported_Group1';
            end

        end


        function varOut=loadAVariableImpl(theReader,varName)

            aFieldName=matlab.lang.makeValidName(deblank(varName));

            if theReader.isExcel
                varOut.(aFieldName)=readExcelSheet(theReader,varName,1,{},[]);
            else
                varOut.(aFieldName)=readCSV(theReader);
            end
        end


        function matFileData=loadImpl(theReader)
            matFileData=struct;


            if theReader.isExcel

                [fileType,SheetNames]=xlsfinfo(theReader.FileName);

                isExcelForm=strcmp(fileType,'Microsoft Excel Spreadsheet')&&...
                ~isempty(SheetNames);




                if~ispc&&~isExcelForm
                    DAStudio.error('sl_web_widgets:customfiles:ExcelDataInvalidFile',theReader.FileName);
                end

                allSigNames=cell(length(SheetNames),1);
                allSheetSize=[];


                for kSheet=1:length(SheetNames)


                    if~isempty(deblank(SheetNames{kSheet}))

                        theFieldName=SheetNames{kSheet};
                        if~isvarname(SheetNames{kSheet})
                            theFieldName=matlab.lang.makeValidName(SheetNames{kSheet});
                        end

                        [matFileData.(theFieldName),allSigNames,allSheetSize]=...
                        readExcelSheet(theReader,SheetNames{kSheet},...
                        kSheet,allSigNames,allSheetSize);
                    else
                        [varFromSheet,allSigNames,allSheetSize]=readExcelSheet(theReader,(SheetNames{kSheet}),kSheet,allSigNames,allSheetSize);
                        matFileData=setfield(matFileData,['Imported_Group',num2str(kSheet)],varFromSheet);%#ok<SFLD>
                    end
                end
            else
                matFileData.Imported_Group1=readCSV(theReader);
            end


        end


        function validateFileNameImpl(theReader,str)
            isSupported=Simulink.io.SignalBuilderSpreadsheet.isFileSupported(str);

            if~isSupported
                DAStudio.error('sl_web_widgets:customfiles:nonCSVorSpreadsheet');
            end
        end


        function[didWrite,errMsg]=exportImpl(theReader,fileName,cellOfVarNames,cellOfVarValues,isAppend)

            didWrite=false;%#ok<NASGU>
            errMsg='';


            if isstring(cellOfVarNames)
                cellOfVarNames=cellstr(cellOfVarNames);
            end

            if~iscellstr(cellOfVarNames)
                DAStudio.error('sl_web_widgets:customfiles:cellOfVarNames');
            end


            if length(cellOfVarValues)~=length(cellOfVarNames)
                DAStudio.error('sl_web_widgets:customfiles:cellOfVarNamesAndVals');
            end




            TimeVals=[];%#ok<NASGU>
            for k=1:length(cellOfVarValues)

                sheet_name=cellOfVarNames{k};


                if~isa(cellOfVarValues{k},'Simulink.SimulationData.Dataset')
                    DAStudio.error('sl_web_widgets:customfiles:groupNonDataset',k);
                end

                numSignals=cellOfVarValues{k}.numElements;

                if numSignals==0
                    DAStudio.error('sl_web_widgets:customfiles:emptyDatasetNotAllowed');
                end

                array_ofData=[];%#ok<NASGU>

                sigNames=cellOfVarValues{k}.getElementNames;


                for kSig=1:numSignals

                    if~Simulink.io.SignalBuilderSpreadsheet.isVariableASupportedSignalType(cellOfVarValues{k}.get(kSig))
                        DAStudio.error('sl_web_widgets:customfiles:nontimeseriesortimetable',sigNames{kSig},sheet_name)
                    end

                end

                [allTimesFromDataset,...
                allTimesFromDatasetIncludingDupes]=...
                getAllTimesFromSignals(theReader,cellOfVarValues{k});

                numTimeVals=length(allTimesFromDatasetIncludingDupes);
                array_ofData=cell(numTimeVals+1,numSignals+1);
                array_ofData{1,1}='Time';

                kSig=1;


                for kPoint=1:numTimeVals


                    array_ofData{kPoint+1,kSig}=double(allTimesFromDatasetIncludingDupes(kPoint));

                end

                [uniqueA,idx,jdx]=unique(allTimesFromDatasetIncludingDupes,'first');%#ok<NCOMMA,ASGLU>
                indexToDupes=find(not(ismember(1:numel(allTimesFromDatasetIncludingDupes),idx)));

                if~isempty(indexToDupes)


                    dupeTimeValues=allTimesFromDatasetIncludingDupes(indexToDupes);

                    dupeToInstanceMatch=theReader.getDuplicateInfo(dupeTimeValues,allTimesFromDatasetIncludingDupes);
                else
                    dupeTimeValues=[];%#ok<NASGU>
                    dupeToInstanceMatch={};
                end


                for kSig=1:numSignals


                    sigTimes=getTimeValsFromVariable(theReader,...
                    cellOfVarValues{k}.get(kSig));
                    dataVals=getDataValsFromVariable(theReader,cellOfVarValues{k}.get(kSig));


                    if isinteger(dataVals)||islogical(dataVals)
                        interpName='nearest';
                    else
                        interpName=getInterpFromVariable(theReader,cellOfVarValues{k}.get(kSig));
                    end

                    [uniquesigTimes,sigTimesidx,sigTimesjdx]=unique(sigTimes,'first');%#ok<ASGLU>


                    if length(sigTimes)==length(uniquesigTimes)

                        if length(allTimesFromDatasetIncludingDupes)>1
                            dataVals=interp1(getTimeValsFromVariable(theReader,...
                            cellOfVarValues{k}.get(kSig)),double(dataVals'),...
                            allTimesFromDatasetIncludingDupes',interpName,'extrap')';


                            allTimesFromDatasetWithDupesForSig=allTimesFromDatasetIncludingDupes;
                        else
                            allTimesFromDatasetWithDupesForSig=sigTimes;
                        end
                    else



                        indexTosigTimesDupes=find(not(ismember(1:numel(sigTimes),sigTimesidx)));

                        dupeToInstanceMatchSignal=theReader.getDuplicateInfo(unique(sigTimes(indexTosigTimesDupes)),sigTimes);%#ok<FNDSB>



                        [dataVals,allTimesFromDatasetWithDupesForSig]=theReader.pieceWiseInterp(dupeToInstanceMatchSignal,sigTimes,...
                        dataVals,allTimesFromDataset,interpName);

                    end



                    if~isempty(dupeToInstanceMatch)
                        [M,N]=size(dupeToInstanceMatch);%#ok<ASGLU>
                        timeAdd=[];
                        for kDupeMatch=1:M
                            DID_ADD=false;
                            if~isempty(timeAdd)&&...
                                any(timeAdd==dupeToInstanceMatch{kDupeMatch,1})

                                DID_ADD=(sum(double((timeAdd==dupeToInstanceMatch{kDupeMatch,1})))+...
                                sum(double((allTimesFromDatasetWithDupesForSig==dupeToInstanceMatch{kDupeMatch,1}))))...
                                >=length(dupeToInstanceMatch{kDupeMatch,2});
                            end

                            numFound=sum(allTimesFromDatasetWithDupesForSig==dupeToInstanceMatch{kDupeMatch,1});

                            if numFound~=length(dupeToInstanceMatch{kDupeMatch,2})&&~DID_ADD
                                numdupesToAdd=length(dupeToInstanceMatch{kDupeMatch,2})-numFound;

                                valueToAdd=dataVals(dupeToInstanceMatch{kDupeMatch,2}(1));

                                rearVals=dataVals(dupeToInstanceMatch{kDupeMatch,2}(2):end);

                                dataVals=[dataVals(1:dupeToInstanceMatch{kDupeMatch,2}(1))',valueToAdd*ones(numdupesToAdd,1)',rearVals']';

                                timeAdd=[timeAdd,dupeToInstanceMatch{kDupeMatch,1}*ones(1,numdupesToAdd)];%#ok<AGROW>
                            end
                        end

                        allTimesFromDatasetWithDupesForSig=sort([allTimesFromDatasetWithDupesForSig',timeAdd]');%#ok<TRSRT>

                    end

                    array_ofData{1,kSig+1}=sigNames{kSig};

                    for kPoint=1:length(allTimesFromDatasetWithDupesForSig)



                        array_ofData{kPoint+1,kSig+1}=dataVals(kPoint);

                    end

                    try
                        Simulink.io.SignalBuilderSpreadsheet.areDataAndTimeCompatible([array_ofData{2:end,1}],[array_ofData{2:end,kSig+1}]);
                    catch ME
                        DAStudio.error('sl_web_widgets:customfiles:csvDataInconsistency',theReader.FileName,ME.message);
                    end
                end


                mTable=cell2table(array_ofData);

                if~isAppend&&k==1


                    writetable(mTable,fileName,'Sheet',sheet_name,...
                    'WriteVariableNames',false,'WriteMode','replacefile');
                else
                    writetable(mTable,fileName,'Sheet',sheet_name,...
                    'WriteVariableNames',false,'WriteMode','overwritesheet');
                end

            end

            didWrite=true;

        end


        function[allUniqueTimesFromDataset,allTimesFromDatasetForSheet]=getAllTimesFromSignals(theReader,dsIn)

            allTimesFromDatasetForSheet=[];
            ARE_TIMES_UNIQUE=boolean(zeros(1,dsIn.numElements));
            dupeTimesBySignal=[];
            for k=1:dsIn.numElements
                timeVals=getTimeValsFromVariable(theReader,dsIn{k});
                allTimesFromDatasetForSheet=[allTimesFromDatasetForSheet,timeVals'];%#ok<AGROW>


                [uniqueTimeVals,idx,jdx]=unique(timeVals,'first');%#ok<ASGLU>
                ARE_TIMES_UNIQUE(k)=length(timeVals)==length(uniqueTimeVals);


                if~ARE_TIMES_UNIQUE(k)

                    indexToDupes=find(not(ismember(1:numel(timeVals),idx)));

                    dupeToInstanceMatchSignal=theReader.getDuplicateInfo(...
                    unique(timeVals(indexToDupes)),timeVals);%#ok<FNDSB>

                    [nDupe,mDupe]=size(dupeToInstanceMatchSignal);%#ok<ASGLU>
                    for kSigDupe=1:nDupe

                        if isempty(dupeTimesBySignal)
                            dupeTimesBySignal=[dupeTimesBySignal,repmat(...
                            dupeToInstanceMatchSignal{kSigDupe,1},1,...
                            length(dupeToInstanceMatchSignal{kSigDupe,2}))];%#ok<AGROW>
                        else

                            dupesMatching=dupeTimesBySignal==dupeToInstanceMatchSignal{kSigDupe,1};
                            numMathingExisting=sum(double(dupesMatching));

                            if numMathingExisting>0&&numMathingExisting<length(dupeToInstanceMatchSignal{kSigDupe,2})


                                dupeTimesBySignal(dupesMatching)=[];%#ok<AGROW>

                                dupeTimesBySignal=[dupeTimesBySignal,repmat(...
                                dupeToInstanceMatchSignal{kSigDupe,1},1,...
                                length(dupeToInstanceMatchSignal{kSigDupe,2}))];%#ok<AGROW>
                            else

                                dupeTimesBySignal=[dupeTimesBySignal,repmat(...
                                dupeToInstanceMatchSignal{kSigDupe,1},1,...
                                length(dupeToInstanceMatchSignal{kSigDupe,2}))];%#ok<AGROW>
                            end
                        end

                    end
                end
            end

            allUniqueTimesFromDataset=unique(allTimesFromDatasetForSheet');

            if all(ARE_TIMES_UNIQUE)


                allTimesFromDatasetForSheet=allUniqueTimesFromDataset;
            else
                allTimesFromDatasetForSheet=sort(allTimesFromDatasetForSheet');%#ok<TRSRT>

                if~isempty(dupeTimesBySignal)

                    valsToRemove=unique(dupeTimesBySignal);

                    allTimesFromDatasetForSheet=allUniqueTimesFromDataset;
                    for kRemove=1:length(valsToRemove)

                        allTimesFromDatasetForSheet(allTimesFromDatasetForSheet==valsToRemove(kRemove))=[];

                    end

                    allTimesFromDatasetForSheet=[allTimesFromDatasetForSheet',dupeTimesBySignal];
                    allTimesFromDatasetForSheet=sort(allTimesFromDatasetForSheet)';

                end

            end


        end


        function dupeToInstanceMatch=getDuplicateInfo(~,dupeTimeValues,allTimesFromDatasetIncludingDupes)

            dupeToInstanceMatch=cell(length(dupeTimeValues),2);
            for kDupe=1:length(dupeTimeValues)
                dupeToInstanceMatch{kDupe,1}=dupeTimeValues(kDupe);
                dupeToInstanceMatch{kDupe,2}=...
                find(dupeTimeValues(kDupe)==allTimesFromDatasetIncludingDupes);
            end
        end


        function[yOut,allTimesFromDataset]=pieceWiseInterp(theReader,dupeToInstanceMatchSignal,sigTimes,...
            dataVals,allTimesFromDataset,interpName)

            [M,N]=size(dupeToInstanceMatchSignal);%#ok<ASGLU>
            for kSet=1:M
                allTimesFromDataset(end+1)=dupeToInstanceMatchSignal{kSet,1};%#ok<AGROW>
            end

            allTimesFromDataset=sort(allTimesFromDataset);
            yOut=[];
            frontIndex=1;
            frontIndexAllTimes=1;
            sigTimesToForceOn=[];
            for kDuplicateTimeVal=1:M

                frontPieceIDXRange=frontIndex:dupeToInstanceMatchSignal{kDuplicateTimeVal,2}(1);
                frontPieceTime=sigTimes(frontPieceIDXRange);
                frontPieceDataVals=dataVals(frontPieceIDXRange);

                frontIndexAllTimeBookEndIndex=find(frontPieceTime(end)==allTimesFromDataset,1);
                frontEndAllTimesPiece=allTimesFromDataset(frontIndexAllTimes:frontIndexAllTimeBookEndIndex);

                if length(frontPieceTime)>1
                    pieceWiseVals=interp1(frontPieceTime,...
                    double(frontPieceDataVals),...
                    frontEndAllTimesPiece,interpName,'extrap');
                else
                    pieceWiseVals=double(frontPieceDataVals);






                    if kDuplicateTimeVal==1&&length(frontEndAllTimesPiece)~=1
                        pieceWiseVals=repmat(pieceWiseVals,length(frontEndAllTimesPiece),1);
                    end
                end


                if length(dupeToInstanceMatchSignal{kDuplicateTimeVal,2})>2

                    pieceWiseVals=[pieceWiseVals'...
                    ,dataVals(dupeToInstanceMatchSignal{kDuplicateTimeVal,2}(2:end-1))']';
                    frontIndex=dupeToInstanceMatchSignal{kDuplicateTimeVal,2}(end);
                    frontIndexAllTimes=frontIndexAllTimeBookEndIndex+1;
                    sigTimesToForceOn=[sigTimesToForceOn,sigTimes((dupeToInstanceMatchSignal{kDuplicateTimeVal,2}(2:end-1)))'];%#ok<AGROW>
                else
                    frontIndex=dupeToInstanceMatchSignal{kDuplicateTimeVal,2}(end);
                    frontIndexAllTimes=frontIndexAllTimeBookEndIndex+1;
                end

                yOut=[yOut,pieceWiseVals'];%#ok<AGROW>
            end

            frontPieceIDXRange=frontIndex:length(sigTimes);
            frontPieceTime=sigTimes(frontPieceIDXRange);
            frontPieceDataVals=dataVals(frontPieceIDXRange);

            frontIndexAllTimeBookEndIndex=find(frontPieceTime(end)==allTimesFromDataset,1);%#ok<NASGU>
            frontEndAllTimesPiece=allTimesFromDataset(frontIndexAllTimes:end);



            if length(frontPieceTime)>1
                pieceWiseVals=interp1(frontPieceTime,...
                double(frontPieceDataVals),...
                frontEndAllTimesPiece,interpName,'extrap');
                yOut=[yOut,pieceWiseVals']';
            else


                yOut=[yOut,double(frontPieceDataVals)]';
            end

            if~isempty(sigTimesToForceOn)

                allTimesFromDataset=sort([allTimesFromDataset',sigTimesToForceOn]');%#ok<TRSRT>

            end
        end
    end


    methods(Access='protected')


        function[varOut,allSigNames,allSheetSize]=readExcelSheet(theReader,sheetName,k,allSigNames,allSheetSize)

            warnState=warning('off','MATLAB:xlsread:Mode');
            [~,filename,ext]=fileparts(theReader.FileName);
            try
                try
                    [~,~,rawData]=xlsread(theReader.FileName,sheetName,'','basic');
                catch ME_xlsread_basic %#ok<NASGU>
                    [~,~,rawData]=xlsread(theReader.FileName,sheetName);
                end

            catch ME

                warning(warnState);
                DAStudio.error('sl_web_widgets:customfiles:ExcelDataInvalidFile',[filename,ext]);
            end
            warning(warnState);

















            if size(rawData,2)>1

                isEmptyHeader=true;


                for id=2:size(rawData,2)

                    if~isnan(rawData{1,id})
                        isEmptyHeader=false;
                    end

                end

                if isEmptyHeader

                    rawData=rawData(2:end,:);
                end






                rangeWarnState=warning('off','MATLAB:xlsread:RangeIncompatible');





                range=sprintf('A1:A%d',size(rawData,1));
                [~,~,columnDataChk]=xlsread(theReader.FileName,sheetName,range);

                warning(rangeWarnState);
                if size(columnDataChk,1)>1

                    isEmptyFirstColumn=true;

                    for rowId=2:size(columnDataChk,1)

                        if~isnan(columnDataChk{rowId,1})
                            isEmptyFirstColumn=false;
                        end
                    end

                    if isEmptyFirstColumn

                        DAStudio.error('sl_web_widgets:customfiles:signalBuilderNonNumeric',sheetName);
                    end

                end
                clear columnDataChk;

            end
            dataSize=size(rawData);




            if dataSize(1)==0||(numel(rawData)==1&&isnan(rawData{1}))
                DAStudio.error('sl_web_widgets:customfiles:signalBuilderEmptySheet',sheetName);
            end



            headerStatus=isThereAHeader(theReader,rawData(1,:));
            allSigNames{k}={};
            if(headerStatus==1)

                startRow=2;
                allSigNames{k}=rawData(1,2:end);
                tmpSigNames=allSigNames{k}';
                tmpSigNames=trimRowTrailingNaNs(theReader,tmpSigNames);
                allSigNames{k}=tmpSigNames';
                rawData=rawData(startRow:end,:);
                if isempty(rawData)
                    DAStudio.error('sl_web_widgets:customfiles:signalBuilderEmptySheet',sheetName);
                end

                if(k>1)
                    if isempty(allSigNames{k-1})


                        DAStudio.error('sl_web_widgets:customfiles:signalBuilderDifferentHeaders',k-1,k);
                    else



                        if(length(allSigNames{k})~=length(allSigNames{k-1}))
                            DAStudio.error('sl_web_widgets:customfiles:ExcelDataDifferentNoOfSignals',k-1,k,k-1,length(allSigNames{k-1}),k,length(allSigNames{k}));
                        end
                        curNames=allSigNames{k};
                        preNames=allSigNames{k-1};
                        for i=1:length(allSigNames{k})
                            if((ischar(curNames{i})&&ischar(preNames{i})&&(strcmpi(curNames{i},preNames{i})~=1))||...
                                (~ischar(curNames{i})&&ischar(preNames{i}))||...
                                (ischar(curNames{i})&&~ischar(preNames{i})))

                                DAStudio.error('sl_web_widgets:customfiles:ExcelDataDifferentSignalsNames',k-1,k);
                            end
                        end
                    end
                end
            else

                if(k>1)&&~isempty(allSigNames{k-1})
                    DAStudio.error('sl_web_widgets:customfiles:signalBuilderDifferentHeaders',k-1,k);
                end
            end





            rawData=trimRowTrailingNaNs(theReader,rawData);
            rawData=trimColumnTrailingNaNs(theReader,rawData);

            dataSize=size(rawData);
            colCnt=dataSize(2);
            allSheetSize(k,:)=dataSize;


            if~(all(cellfun(@isnumeric,rawData(:))))
                DAStudio.error('sl_web_widgets:customfiles:signalBuilderNonNumeric',sheetName);
            end



            if k>1

                if colCnt~=allSheetSize(k-1,2)
                    DAStudio.error('sl_web_widgets:customfiles:ExcelDataDifferentNoOfSignals',...
                    k-1,k,k-1,allSheetSize(k-1,2)-1,k,colCnt-1);
                end
            end
            timeColumn=1;
            outtime=converToNumeric(theReader,rawData(:,timeColumn));
            outdata=converToNumeric(theReader,rawData(:,timeColumn+1:end));

            [~,numSig]=size(outdata);

            varOut=Simulink.SimulationData.Dataset;
            tmpAllSigNames=allSigNames{k};
            for k=1:numSig

                try
                    Simulink.io.SignalBuilderSpreadsheet.areDataAndTimeCompatible(outtime,outdata(:,k));
                catch ME
                    DAStudio.error('sl_web_widgets:customfiles:spreadsheetDataInconsistency',theReader.FileName,sheetName,ME.message);
                end


                ts=timeseries(outdata(:,k),outtime);

                if~isempty(tmpAllSigNames)
                    varOut=varOut.addElement(ts,tmpAllSigNames{k});
                else
                    varOut=varOut.addElement(ts,['Imported_Signal ',num2str(k)]);
                end
            end
        end


        function varOut=readCSV(theReader)

            allData=dlmread(theReader.FileName);
            outtime=allData(:,1);
            outdata=allData(:,2:end);

            ds=Simulink.SimulationData.Dataset();

            [~,N]=size(outdata);

            if N==0
                DAStudio.error('sl_web_widgets:customfiles:emptyCSVData',theReader.FileName);
            end

            for kCol=1:N

                try
                    Simulink.io.SignalBuilderSpreadsheet.areDataAndTimeCompatible(outtime,outdata(:,kCol));
                catch ME
                    DAStudio.error('sl_web_widgets:customfiles:csvDataInconsistency',theReader.FileName,ME.message);
                end

                ds{kCol}=timeseries(outdata(:,kCol),outtime);
            end
            varOut=ds;
        end


        function Data=trimRowTrailingNaNs(theReader,Data)%#ok<*INUSL>


            column=Data(:,1);


            lastNaNIndex=find(cellfun(@(x)~all(isnan(x)),column),1,'last');

            Data=Data(1:lastNaNIndex,:);
        end


        function Data=trimColumnTrailingNaNs(theReader,Data)


            rowCount=size(Data,1);
            lastNaNIndices=zeros(1,rowCount);


            for i=1:rowCount
                row=Data(i,:);


                lastNaNIndex=find(cellfun(@(x)~all(isnan(x)),row),1,'last');
                if(~isempty(lastNaNIndex))
                    lastNaNIndices(i)=lastNaNIndex;
                end

            end


            Data=Data(:,1:max(lastNaNIndices));
        end


        function Data=converToNumeric(theReader,Data)


            if(iscell(Data))
                if(all(cellfun(@isnumeric,Data(:)))||all(cellfun(@islogical,Data(:))))
                    Data=cell2mat(Data);
                end
            end
        end


        function headerStatus=isThereAHeader(theReader,sNames)
            nameNotString=~cellfun('isclass',sNames,'char');

            if all(nameNotString)

                headerStatus=0;
            else

                headerStatus=1;
                numIndex=find(cellfun('isclass',sNames,'double'));
                nanCnt=0;
                for i=numIndex
                    if isnan(sNames{i})
                        nanCnt=nanCnt+1;
                        sNames{i}=['Imported_Signal ',num2str(nanCnt)];
                    else
                        sNames{i}=num2str(sNames{i});
                    end
                end
            end
        end


        function timeVals=getTimeValsFromVariable(theReader,varIn)

            if isa(varIn,'timeseries')
                timeVals=varIn.Time;
            elseif isSLTimeTable(varIn)
                time_varName=varIn.Properties.DimensionNames{1};
                durationTypeString=getDurationString(theReader,varIn.(time_varName));
                fcnH=str2func(durationTypeString);
                timeVals=double(fcnH(varIn.(time_varName)));
            else


                timeVals=getTimeValsFromVariable(theReader,varIn.Values);
            end


        end


        function dataVals=getDataValsFromVariable(theReader,varIn)

            if isa(varIn,'timeseries')
                dataVals=varIn.Data;
            elseif isSLTimeTable(varIn)
                dataVals=varIn.(varIn.Properties.VariableNames{1});
            else


                dataVals=getDataValsFromVariable(theReader,varIn.Values);
            end


        end


        function interpName=getInterpFromVariable(theReader,varIn)

            if isa(varIn,'timeseries')
                interpName=varIn.DataInfo.Interpolation.name;
            elseif isSLTimeTable(varIn)

                if~isempty(varIn.Properties.VariableContinuity)
                    interpName=varIn.Properties.VariableContinuity(1);
                    interpName=char(interpName);
                else

                    interpName='linear';
                end

            else


                interpName=getInterpFromVariable(theReader,varIn.Values);
            end

            if strcmpi(interpName,'continuous')
                interpName='linear';
            end

            if strcmpi(interpName,'step')||strcmpi(interpName,'zoh')
                interpName='nearest';
            end

        end


        function durationTypeString=getDurationString(~,Time)

            IS_YEARS=strcmp('y',Time.Format);
            IS_HOURS=strcmp('h',Time.Format);
            IS_MINUTES=strcmp('m',Time.Format);
            IS_SECONDS=strcmp('s',Time.Format);

            if IS_YEARS
                durationTypeString='years';
            elseif IS_HOURS
                durationTypeString='hours';
            elseif IS_MINUTES
                durationTypeString='minutes';
            elseif IS_SECONDS
                durationTypeString='seconds';
            else

                durationTypeString='seconds';
            end
        end

    end


    methods(Static)


        function isSupported=isFileSupported(fileLocation)
            isSupported=false;

            [~,~,ext]=fileparts(fileLocation);

            if any(strcmpi(ext,{'.xls','.xlsx'}))

                if exist(fileLocation,'file')
                    isSupported=Simulink.io.SignalBuilderSpreadsheet.isSupportedExcelFile(fileLocation);
                else


                    isSupported=true;
                end
            elseif(strcmpi(ext,'.csv'))
                isSupported=Simulink.io.SignalBuilderSpreadsheet.isSupportedCsv(fileLocation);
            end

        end


        function aFileReaderDescription=getFileTypeDescription()
            aFileReaderDescription=DAStudio.message('sl_web_widgets:customfiles:spreadsheetDescription');
        end

    end


    methods(Hidden,Static)


        function isExcelForm=isSupportedExcelFile(fileLocation)
            isExcelForm=false;

            [~,~,ext]=fileparts(fileLocation);

            if any(strcmpi(ext,{'.xls','.xlsx','.csv'}))

                isExcelForm=true;
                return;
            end


        end


        function isCsv=isSupportedCsv(fileLocation)
            try



                allData=dlmread(fileLocation);
                outtime=allData(:,1);
                outdata=allData(:,2:end);

                if~all(isnumeric(outtime))||...
                    ~all(isnumeric(outdata))

                    isCsv=false;
                    return;
                end
                isCsv=true;
            catch ME %#ok<NASGU>
                isCsv=false;

            end
        end


        function isTimeSupported(timeIn)

            if~isnumeric(timeIn)
                DAStudio.error('sl_web_widgets:customfiles:VectorOrCellTimeData','TIME');
            end


            if~isreal(timeIn)
                DAStudio.error('sl_web_widgets:customfiles:TimeDataRealValue','TIME');
            end


            if any(~isfinite(timeIn))
                DAStudio.error('sl_web_widgets:customfiles:TimeDataFiniteNumericValue','TIME');
            end


            if any(diff(timeIn)<0)
                DAStudio.error('sl_web_widgets:customfiles:TimeMonotonicallyIncreasing');
            end
        end


        function isDataSupported(dataIn)

            if~isnumeric(dataIn)||...
                (iscellstr(dataIn)||isstring(dataIn))
                DAStudio.error('sl_web_widgets:customfiles:VectorOrCellTimeData','DATA');
            end

            if~isreal(dataIn)
                DAStudio.error('sl_web_widgets:customfiles:TimeDataRealValue','DATA');
            end

            if any(~isfinite(dataIn))
                DAStudio.error('sl_web_widgets:customfiles:TimeDataFiniteNumericValue','DATA');
            end
        end


        function areDataAndTimeCompatible(timeIn,dataIn)

            try
                Simulink.io.SignalBuilderSpreadsheet.isTimeSupported(timeIn);
            catch ME
                throwAsCaller(ME);
            end

            try
                Simulink.io.SignalBuilderSpreadsheet.isDataSupported(dataIn);
            catch ME
                throwAsCaller(ME);
            end

            if length(timeIn(:))~=length(dataIn(:))
                DAStudio.error('sl_web_widgets:customfiles:GroupTimeDataMismatch',...
                length(timeIn(:)),length(dataIn(:)));
            end

        end


        function boolIsValidVarType=isVariableASupportedSignalType(varIn)

            if~isa(varIn,'timeseries')||...
                ~isSLTimeTable(varIn)

                theProps=properties(varIn);

                if isempty(theProps)
                    boolIsValidVarType=false;
                    return;
                end

                if any(strcmp(theProps,'Values'))&&...
                    (~isa(varIn.Values,'timeseries')&&...
                    ~isSLTimeTable(varIn.Values))
                    boolIsValidVarType=false;
                    return;
                end

            end

            boolIsValidVarType=true;

        end


        function nameOut=makeValidVariableName(nameIn)
            nameOut=matlab.lang.makeValidName(nameIn);
        end

    end

end
