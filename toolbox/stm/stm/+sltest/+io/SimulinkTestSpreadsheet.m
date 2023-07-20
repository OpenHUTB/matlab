classdef SimulinkTestSpreadsheet<Simulink.io.FileType





    properties(Access='protected')

        isExcel=false;

    end



    methods


        function theReader=SimulinkTestSpreadsheet(filename)

            theReader=theReader@Simulink.io.FileType(filename);

            if~isempty(filename)

                if xls.internal.WriteTable.isValidExtension(filename)
                    theReader.isExcel=true;
                else
                    error(message('sl_xls:WriteTable:InvalidFileExtension',xls.internal.WriteTable.SpreadsheetExts.join(', ')));
                end

            end

        end

    end




    methods(Hidden)


        function aList=whosImpl(theReader)


            if theReader.isExcel
                sheets=sheetnames(theReader.FileName);

                aList=struct('name',deblank(sheets).cellstr.');

            end

        end


        function varOut=loadAVariableImpl(theReader,varName)

            aFieldName=matlab.lang.makeValidName(deblank(varName));
            varOut.(aFieldName)=readExcelSheet(theReader,varName);
        end


        function inputs=loadImpl(theReader)
            inputs=struct;


            sheets=sheetnames(theReader.FileName);

            for el=1:length(sheets)
                sheetName=sheets(el);
                aFieldName=matlab.lang.makeValidName(deblank(sheetName));
                inputs.(aFieldName)=readExcelSheet(theReader,sheetName);
            end

        end


        function validateFileNameImpl(~,str)
            isSupported=sltest.io.SimulinkTestSpreadsheet.isFileSupported(str);

            if~isSupported
                error(message('sl_xls:WriteTable:InvalidFileExtension',xls.internal.WriteTable.SpreadsheetExts.join(', ')));
            end
        end



        function[didWrite,errMsg]=exportImpl(~,fileName,cellOfVarNames,cellOfVarValues,~)

            didWrite=false;
            errMsg='';

            numOfScenarios=length(cellOfVarNames);
            for idx=1:numOfScenarios

                [sheets,~]=matlab.lang.makeUniqueStrings(cellOfVarNames);
                sheet=sheets(idx);
                in=cellOfVarValues(idx);

                if(~isempty(in))
                    try
                        xls.internal.util.writeDatasetToSheet(in{1,1},fileName,...
                        sheet,'',xls.internal.SourceTypes.Input);
                    catch me
                        errMsg=me.message;
                        return;
                    end
                end
            end
            didWrite=true;
        end


        function dupeToInstanceMatch=getDuplicateInfo(~,dupeTimeValues,allTimesFromDatasetIncludingDupes)

            dupeToInstanceMatch=cell(length(dupeTimeValues),2);
            for kDupe=1:length(dupeTimeValues)
                dupeToInstanceMatch{kDupe,1}=dupeTimeValues(kDupe);
                dupeToInstanceMatch{kDupe,2}=...
                find(dupeTimeValues(kDupe)==allTimesFromDatasetIncludingDupes);
            end
        end

    end


    methods(Access='protected')


        function varOut=readExcelSheet(theReader,sheetName)

            readTable=xls.internal.ReadTable(theReader.FileName,'Sheets',sheetName);
            varOut=readTable.readMetadata(xls.internal.SourceTypes.Input);

        end


        function Data=converToNumeric(~,Data)


            if(iscell(Data))
                if(all(cellfun(@isnumeric,Data(:)))||all(cellfun(@islogical,Data(:))))
                    Data=cell2mat(Data);
                end
            end
        end


        function headerStatus=isThereAHeader(~,sNames)
            nameNotString=~cellfun('isclass',sNames,'char');

            if all(nameNotString)

                headerStatus=0;
            else

                headerStatus=1;

            end
        end


        function timeVals=getTimeValsFromVariable(theReader,varIn)

            if isa(varIn,'timeseries')
                timeVals=varIn.Time;
            else


                timeVals=getTimeValsFromVariable(theReader,varIn.Values);
            end
        end


        function dataVals=getDataValsFromVariable(theReader,varIn)

            if isa(varIn,'timeseries')
                dataVals=varIn.Data;
            else


                dataVals=getDataValsFromVariable(theReader,varIn.Values);
            end
        end

    end


    methods(Static)


        function aFileReaderDescription=getFileTypeDescription()
            aFileReaderDescription=DAStudio.message('sl_xls:Source:excelFileType');
        end


        function isSupported=isFileSupported(fileLocation)

            [~,~,ext]=fileparts(fileLocation);

            if any(strcmpi(ext,{'.xls','.xlsx','.xlsm'}))

                if exist(fileLocation,'file')
                    isSupported=sltest.io.SimulinkTestSpreadsheet.isSupportedExcelFile(fileLocation);
                else


                    isSupported=true;
                end
            else

                isSupported=false;
            end
        end

    end


    methods(Hidden,Static)


        function isExcelForm=isSupportedExcelFile(filename)

            try

                isExcelForm=xls.internal.WriteTable.isValidExtension(filename);

            catch ME %#ok<NASGU>

                isExcelForm=false;
            end

        end

    end

end
