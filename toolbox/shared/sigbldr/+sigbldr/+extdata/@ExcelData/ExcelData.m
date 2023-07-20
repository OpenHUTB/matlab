

classdef ExcelData<sigbldr.extdata.SBImportData

    properties
        parentH=[];
    end


    methods
        function this=ExcelData(fullPathName,varargin)

            if(nargin==2)
                this.parentH=varargin{1};
            end

            sigbldr.ui.progressBar('create',[],this.parentH);
            sigbldr.ui.progressBar('update',DAStudio.message('Sigbldr:import:PBReadingExcelFile'));
            try
                sigbldr.extdata.SBImportData.verifyFileName(fullPathName);
            catch ME
                sigbldr.ui.progressBar('destroy');
                ME.rethrow();
            end



            try













                [fileType,SheetNames]=xlsfinfo(fullPathName);



                isRead=strcmp(fileType,'Microsoft Excel Spreadsheet')&&...
                ~isempty(SheetNames);
            catch ME %#ok<NASGU>


                isRead=false;
            end

            if(~isRead)
                [~,fileName,fileExt]=fileparts(fullPathName);
                shortName=[fileName,fileExt];
                sigbldr.ui.progressBar('destroy');
                DAStudio.error('Sigbldr:import:ExcelDataInvalidFile',shortName);
            end



            this.Type='EXCEL';
            this.StatusMessage='';
            this.GroupSignalData=[];
            try
                [localtime,localdata,sigNames,grpNames]=this.readFile(fullPathName,SheetNames);
            catch ME
                sigbldr.ui.progressBar('destroy');
                ME.throw();
            end
            sigbldr.ui.progressBar('destroy');
            [newstatus,msg]=this.setGroupSignalData(localtime,localdata,sigNames,grpNames);
            if(~newstatus)
                DAStudio.error('Sigbldr:import:ExcelCVSMATData',msg)
            end
        end
    end
    methods(Access=protected)



        function[outtime,outdata,sigNames,grpNames]=readFile(this,varargin)
            fullPathName=varargin{1};
            SheetNames=varargin{2};
            timeColumn=1;
            [~,fileName,fileExt]=fileparts(fullPathName);
            shortName=[fileName,fileExt];
            premsg=DAStudio.message('Sigbldr:import:nonCompliantFormat',shortName);

            sheetCnt=length(SheetNames);
            outtime=cell(sheetCnt,1);
            outdata=cell(sheetCnt,1);
            allSigNames=cell(sheetCnt,1);


            sigbldr.ui.progressBar('fireProcess');
            for k=1:sheetCnt
                message=DAStudio.message('Sigbldr:import:PBReadingExcelFileWorksheets',k,sheetCnt);
                [status,error]=sigbldr.ui.progressBar('monitorProcess',message,k/sheetCnt);
                if(status==0)
                    sigbldr.ui.progressBar('destroy');
                    DAStudio.error(error);
                elseif(status==-1)
                    sigbldr.ui.progressBar('destroy');
                    DAStudio.error('Sigbldr:import:PBReadingCancel');
                end
                warnState=warning('off','MATLAB:xlsread:Mode');

                try
                    try
                        [~,~,rawData]=xlsread(fullPathName,SheetNames{k},'','basic');
                    catch ME_xlsread_basic %#ok<NASGU>
                        [~,~,rawData]=xlsread(fullPathName,SheetNames{k});
                    end

                catch ME

                    warning(warnState);
                    DAStudio.error('Sigbldr:import:ExcelDataInvalidFile',shortName);
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
                    [~,~,columnDataChk]=xlsread(fullPathName,SheetNames{k},range);

                    warning(rangeWarnState);
                    if size(columnDataChk,1)>1
                        isEmptyFirstColumn=true;

                        for rowId=2:size(columnDataChk,1)
                            if~isnan(columnDataChk{rowId,1})
                                isEmptyFirstColumn=false;
                            end
                        end
                        if isEmptyFirstColumn

                            DAStudio.error('Sigbldr:import:ExcelDataNonNumericValues',premsg,k);
                        end
                    end
                    clear columnDataChk;

                end
                dataSize=size(rawData);




                if dataSize(1)==0||(numel(rawData)==1&&isnan(rawData{1}))
                    DAStudio.error('Sigbldr:import:ExcelDataEmptyWorksheet',premsg,k);
                end

                headerStatus=isThereAHeader(rawData(1,:));
                allSigNames{k}={};
                if(headerStatus==1)

                    startRow=2;
                    allSigNames{k}=rawData(1,2:end);
                    tmpSigNames=allSigNames{k}';
                    tmpSigNames=trimRowTrailingNaNs(tmpSigNames);
                    allSigNames{k}=tmpSigNames';
                    rawData=rawData(startRow:end,:);
                    if isempty(rawData)
                        DAStudio.error('Sigbldr:import:ExcelDataEmptyWorksheet',premsg,k);
                    end

                    if(k>1)
                        if isempty(allSigNames{k-1})


                            DAStudio.error('Sigbldr:import:ExcelDataDifferentHeaders',premsg,k-1,k);
                        else



                            if(length(allSigNames{k})~=length(allSigNames{k-1}))
                                DAStudio.error('Sigbldr:import:ExcelDataDifferentNoOfSignals',premsg,k-1,k);
                            end
                            curNames=allSigNames{k};
                            preNames=allSigNames{k-1};
                            for i=1:length(allSigNames{k})
                                if((ischar(curNames{i})&&ischar(preNames{i})&&(strcmpi(curNames{i},preNames{i})~=1))||...
                                    (~ischar(curNames{i})&&ischar(preNames{i}))||...
                                    (ischar(curNames{i})&&~ischar(preNames{i})))

                                    DAStudio.error('Sigbldr:import:ExcelDataDifferentSignalsNames',premsg,k-1,k);
                                end
                            end
                        end
                    end
                else

                    if(k>1)&&~isempty(allSigNames{k-1})
                        DAStudio.error('Sigbldr:import:ExcelDataDifferentHeaders',premsg,k-1,k);
                    end
                end






                rawData=trimRowTrailingNaNs(rawData);
                rawData=trimColumnTrailingNaNs(rawData);

                dataSize=size(rawData);
                colCnt=dataSize(2);
                allSheetSize(k,:)=dataSize;


                if~(all(cellfun(@isnumeric,rawData(:))))
                    DAStudio.error('Sigbldr:import:ExcelDataNonNumericValues',premsg,k);
                end



                if k>1

                    if colCnt~=allSheetSize(k-1,2)
                        DAStudio.error('Sigbldr:import:ExcelDataDifferentNoOfSignals',premsg,k-1,k);
                    end
                end
                outtime{k}=converToNumeric(rawData(:,timeColumn));
                outdata{k}=converToNumeric(rawData(:,timeColumn+1:end));
            end

            g5=sprintf('   %s\n',SheetNames{:});

            if~isempty(allSigNames{k})
                tmpSigNames=allSigNames{k};
                s5=sprintf('   %s\n',tmpSigNames{:});

                this.StatusMessage=DAStudio.message('Sigbldr:import:ExcelDataFileInfoWithSignalNames',shortName,sheetCnt,g5,colCnt-1,s5);
            else
                this.StatusMessage=DAStudio.message('Sigbldr:import:ExcelDataFileInfoNoSignalNames',shortName,sheetCnt,g5,colCnt-1);
            end
            sigNames=allSigNames{1};
            grpNames=SheetNames;
        end



        function[status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames)

            grpCnt=length(grpNames);
            sigCnt=length(sigNames);

            time=cell(1,grpCnt);
            data=cell(sigCnt,grpCnt);
            for gidx=1:grpCnt
                time{1,gidx}=intime{gidx}';
                for sidx=1:sigCnt
                    td=indata{gidx};
                    data{sidx,gidx}=td(:,sidx)';
                end
            end
            try
                this.GroupSignalData=SigSuite(time,data,sigNames,grpNames);
                msg='';
                status=true;
            catch ME
                msg=ME.message;
                status=false;
            end
        end




        function[status,msg]=setGroupSignalData(this,intime,indata,sigNames,grpNames)






















            signalCount=size(indata{1,1},2);
            groupCount=size(indata,1);
            [sigNames,grpNames]=sigbldr.extdata.SBImportData.updateGroupSignalNames(signalCount,groupCount,sigNames,grpNames);
            [status,msg]=converttoSBObj(this,intime,indata,grpNames,sigNames);
        end
    end

end

function headerStatus=isThereAHeader(sNames)
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

function Data=trimRowTrailingNaNs(Data)


    column=Data(:,1);


    lastNaNIndex=find(cellfun(@(x)~all(isnan(x)),column),1,'last');

    Data=Data(1:lastNaNIndex,:);
end


function Data=trimColumnTrailingNaNs(Data)


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



function Data=converToNumeric(Data)


    if(iscell(Data))
        if(all(cellfun(@isnumeric,Data(:)))||all(cellfun(@islogical,Data(:))));
            Data=cell2mat(Data);
        end
    end
end

