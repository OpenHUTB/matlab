classdef ExcelFile<iofile.File














    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
        Version=1.0;
    end

    properties(Access='private')
ExcelReader
    end

    methods

        function theExcelFile=ExcelFile(varargin)
            theExcelFile=theExcelFile@iofile.File(varargin{:});

            try
                theExcelFile.ExcelReader=sl_iofile.ExcelReader(theExcelFile.FileName);
            catch err
                errorJSON=jsondecode(err.message);
                error(sprintf('sl_iofile:excelfile:%s',errorJSON.ErrorId),errorJSON.ErrorMessage);
            end

        end


        function validateFileName(theExcelFile,str)


            theExcelFile.verifyFileName(str);

        end

        function loadAVariable(theExcelFile,varName,varargin)
            try
                jsonReturned=theExcelFile.ExcelReader.import(varName);

                Simulink.sdi.internal.flushStreamingBackend();
            catch err
                Simulink.sdi.internal.flushStreamingBackend();
                errorJSON=jsondecode(err.message);
                error(sprintf('sl_iofile:excelfile:%s',errorJSON.ErrorId),errorJSON.ErrorMessage);
            end

            if nargin==2

                theExcelFile.exportToBaseWorkspace(jsonReturned,[]);
            elseif nargin==3

                configStruct=varargin{1};
                if all(isfield(configStruct,{'Signals','DataType'}))&&...
                    length(configStruct)==1
                    theExcelFile.exportToBaseWorkspace(jsonReturned,configStruct);
                else
                    error(message('sl_iofile:excelfile:wrongCastingInformation'));
                end
            else
                error(message('sl_iofile:excelfile:wrongCastingInformation'));
            end

        end

        function exportToBaseWorkspace(~,jsonReturned,configStruct)
            json2str=jsondecode(jsonReturned);
            arrayOfJson=json2str.arrayOfListItems;

            aFactory=starepository.repositorysignal.Factory;
            sheetId=0;
            for id=1:length(arrayOfJson)
                if strcmp(arrayOfJson(id).Type,'DataSet')
                    sheetId=sheetId+1;
                    idOfDataSet=str2double(arrayOfJson(id).ID);

                    concreteExtractor=aFactory.getSupportedExtractor(idOfDataSet);


                    [dataValue,dataVarName]=concreteExtractor.extractValue(idOfDataSet);

                    if sheetId<=length(configStruct)
                        signals=configStruct(sheetId).Signals;
                        dtType=configStruct(sheetId).DataType;
                        if isempty(dtType)&&isempty(signals)


                        elseif isempty(dtType)||~(iscellstr(dtType)||isstring(dtType))
                            error(message('sl_iofile:excelfile:wrongCastingInformation'));
                        elseif isempty(signals)

                            dtType=iofile.ExcelFile.locConvertStringsToChars(dtType);
                            for dsEleId=1:dataValue.numElements
                                dsEle=dataValue.get(dsEleId);
                                dsEle.Data=starepository.slCastData(dsEle.Data,dtType{1});
                                dataValue=dataValue.setElement(dsEleId,dsEle,dsEle.Name);
                            end
                        else
                            dtType=iofile.ExcelFile.locConvertStringsToChars(dtType);
                            for sigcellId=1:length(signals)
                                if~iscell(signals{sigcellId})

                                    error(message('sl_iofile:excelfile:wrongCastingInformation'));
                                end
                                for sigId=1:length(signals{sigcellId})
                                    dsEleId=signals{sigcellId}{sigId};
                                    if ischar(dsEleId)||isstring(dsEleId)
                                        dsEleId=iofile.ExcelFile.locConvertStringsToChars(dsEleId);
                                        [~,dsEleId]=dataValue.find(dsEleId);
                                    end
                                    if isempty(dsEleId)||dsEleId>dataValue.numElements
                                        continue;
                                    end
                                    dsEle=dataValue.get(dsEleId);
                                    dsEle.Data=starepository.slCastData(dsEle.Data,dtType{sigcellId});
                                    dataValue=dataValue.setElement(dsEleId,dsEle,dsEle.Name);
                                end
                            end
                        end
                    end


                    assignin('base',dataVarName,dataValue);
                end

            end
        end

        function jsonReturned=load(theExcelFile,varargin)
            try
                jsonReturned=theExcelFile.ExcelReader.importAll();

                Simulink.sdi.internal.flushStreamingBackend();
            catch err
                Simulink.sdi.internal.flushStreamingBackend();
                errorJSON=jsondecode(err.message);
                error(sprintf('sl_iofile:excelfile:%s',errorJSON.ErrorId),errorJSON.ErrorMessage);
            end

            if nargin==1
                theExcelFile.exportToBaseWorkspace(jsonReturned,[]);
            elseif nargin==2

                configStruct=varargin{1};
                if all(isfield(configStruct,{'Signals','DataType'}))
                    theExcelFile.exportToBaseWorkspace(jsonReturned,configStruct);
                else
                    error(message('sl_iofile:excelfile:wrongCastingInformation'));

                end
            else
                error(message('sl_iofile:excelfile:wrongCastingInformation'));
            end

        end


        function whoSTR=whos(theExcelFile)

            try
                aList=jsondecode(theExcelFile.ExcelReader.importMetaData());
                arrayOfJson=aList.arrayOfListItems;
                whoSTR=struct('name','');
                dataSetCount=1;
                for id=1:length(arrayOfJson)
                    if strcmp(arrayOfJson(id).Type,'DataSet')
                        whoSTR(dataSetCount).name=arrayOfJson(id).Name;
                        dataSetCount=dataSetCount+1;
                    end
                end
            catch err
                errorJSON=jsondecode(err.message);
                error(sprintf('sl_iofile:excelfile:%s',errorJSON.ErrorId),errorJSON.ErrorMessage);
            end
        end

    end

    methods(Static,Access='private')
        function output=locConvertStringsToChars(input)


            output=convertStringsToChars(input);
            if ischar(output)



                output={output};
            end
        end
    end

    methods(Static)
        function setDataTypeMetaInfo(jsonReturned,configStruct)
            json2str=jsondecode(jsonReturned);
            arrayOfJson=json2str.arrayOfListItems;
            sheetId=0;
            for id=1:length(arrayOfJson)
                if strcmp(arrayOfJson(id).Type,'DataSet')
                    sheetId=sheetId+1;
                    if sheetId<=length(configStruct)
                        signals=configStruct(sheetId).Signals;
                        dtType=configStruct(sheetId).DataType;
                        if isempty(dtType)&&isempty(signals)


                        elseif isempty(dtType)||~(iscellstr(dtType)||isstring(dtType))
                            error(message('sl_iofile:excelfile:wrongCastingInformation'));
                        elseif isempty(signals)
                            dtType=iofile.ExcelFile.locConvertStringsToChars(dtType);

                            repo=starepository.RepositoryUtility();
                            signalids=repo.getChildrenIds(str2double(arrayOfJson(id).ID));
                            for dsEleId=1:length(signalids)
                                setMetaDataByName(repo,signalids(dsEleId),'CastToDataType',dtType{1});
                            end
                        else

                            dtType=iofile.ExcelFile.locConvertStringsToChars(dtType);
                            repo=starepository.RepositoryUtility();
                            signalids=repo.getChildrenIds(str2double(arrayOfJson(id).ID));
                            for sigcellId=1:length(signals)
                                for sigId=1:length(signals{sigcellId})
                                    dsEleId=signals{sigcellId}{sigId};
                                    if ischar(dsEleId)


                                        error(message('sl_iofile:excelfile:wrongCastingInformation'));
                                    end
                                    if isempty(dsEleId)||dsEleId>length(signalids)
                                        continue;
                                    end
                                    setMetaDataByName(repo,signalids(dsEleId),'CastToDataType',dtType{sigcellId});
                                end
                            end
                        end
                    end
                end

            end

        end

        function SheetName=variableNameToSheetName(VariableName,SheetNames)















            if isstring(VariableName)&&isscalar(VariableName)

                VariableName=char(VariableName);

            end

            if~ischar(VariableName)
                error(message('sl_iofile:excelfile:InvalidVariableName'));
            end


            if isstring(SheetNames)&&~isscalar(SheetNames)

                SheetNames=cellstr(SheetNames);

            end

            if~iscell(SheetNames)||...
                ~(size(SheetNames,1)==1||size(SheetNames,2)==1)
                error(message('sl_iofile:excelfile:InvalidSheetNames'));
            end

            if any(cellfun(@(x)~ischar(x),SheetNames))
                error(message('sl_iofile:excelfile:InvalidSheetNames'));
            end

            if any(strcmp(VariableName,SheetNames))
                SheetName=VariableName;
            else

                VariableNames=iofile.ExcelFile.sheetNamesToVariableNames(SheetNames);
                comparisonResults=strcmpi(VariableName,VariableNames);
                if any(comparisonResults)
                    SheetName=SheetNames{comparisonResults};
                else
                    SheetName='';
                end

            end

        end


        function VariableNames=sheetNamesToVariableNames(SheetNames)












            if~iscell(SheetNames)||...
                ~(size(SheetNames,1)==1||size(SheetNames,2)==1)
                error(message('sl_iofile:excelfile:InvalidSheetNames'));
            end

            if any(cellfun(@(x)~ischar(x),SheetNames))
                error(message('sl_iofile:excelfile:InvalidSheetNames'));
            end

            VariableNames=cell(size(SheetNames));
            for id=1:length(SheetNames)

                if~isvarname(SheetNames{id})

                    newSheetName=matlab.lang.makeValidName(SheetNames{id});



                    if any(strcmpi(newSheetName,[SheetNames,VariableNames{1:id}]))

                        UniqueVarNames=matlab.lang.makeUniqueStrings([SheetNames,VariableNames{1:id},{newSheetName}]);



                        VariableNames{id}=UniqueVarNames{end};

                    else

                        VariableNames{id}=newSheetName;
                    end

                else

                    VariableNames{id}=SheetNames{id};
                end

            end

        end

    end

    methods(Access=private)

        function status=verifyFileName(~,fileName)
            status=1;

            if(isempty(fileName))
                error(message('sl_iofile:excelfile:emptyFileName'));

            end


            if(~exist(fileName,'file'))
                error(message('sl_iofile:excelfile:invalidFile',fileName));
            end
        end

    end
end
