classdef SelectorModel<handle




    properties
BlockHandle
BlockPath
ReferenceBlock
BlockInformation
BlockDefaultParameters
DataRepositoryRootDirectory
SelectedPart
Index
AvailableManufacturers
AvailableParts
TableData
ModelName
SelectedManufacturer
Status
DifferenceTableColumnOrder
RoundOffValue
    end

    properties(Access=private)
        AllManufacturersPartList={};
BlockLibraryType
    end

    events
ModelUpdated
StatusChanged
EnableReset
    end

    methods
        function obj=SelectorModel(block)



            obj.ModelName=get_param(bdroot(block),'Name');
            if isstring(block)
                block=char(block);
            end
            if ischar(block)
                obj.BlockHandle=get_param(block,'handle');
                obj.BlockPath=block;
            else
                obj.BlockHandle=block;
                obj.BlockPath=[get_param(block,'parent'),'/',get_param(block,'name')];
            end


            referenceBlock=get_param(block,'ReferenceBlock');
            obj.ReferenceBlock=referenceBlock;


            refBlockTokens=split(obj.ReferenceBlock,'/');
            obj.BlockLibraryType=refBlockTokens{1};


            thisBlock=foundation.internal.parameterization.BlockParameterSet;
            thisBlock.extractBlockParameters(obj.BlockHandle);
            obj.BlockDefaultParameters=struct;
            obj.BlockDefaultParameters.BlockInformation=[cellstr(thisBlock.Names)',thisBlock.Values'];
            obj.BlockDefaultParameters.Tag=get_param(obj.BlockHandle,'Tag');
            obj.BlockDefaultParameters.Attribute=get_param(obj.BlockHandle,'AttributesFormatString');


            obj.DifferenceTableColumnOrder=struct;
            obj.DifferenceTableColumnOrder.ParamName=1;
            obj.DifferenceTableColumnOrder.Source=2;
            obj.DifferenceTableColumnOrder.Override=3;
            obj.DifferenceTableColumnOrder.PartValue=4;
            obj.DifferenceTableColumnOrder.ParamValue=5;
            obj.DifferenceTableColumnOrder.Unit=6;

            obj.RoundOffValue=100000;



            tag=get_param(block,'tag');

            if isempty(tag)||strcmp('Factory Generic',tag)

                fullFilePath=which(obj.BlockLibraryType);
                libraryDirectory=fileparts(fullFilePath);
                obj.DataRepositoryRootDirectory=[fullfile(libraryDirectory,obj.BlockLibraryType),'_parts'];


                if numel(obj.AvailableManufacturers)>0
                    obj.SelectedManufacturer=obj.AvailableManufacturers{1};
                end

                availableParts=obj.AvailableParts;

                if~isempty(availableParts)&&...
                    ~isempty(availableParts{1})
                    obj.SelectedPart=availableParts{1}{1};
                end
            else

                tagInfo=eval(tag);


                if~strcmp(filesep,'/')
                    tagInfo=strrep(tagInfo,'/',filesep);
                end
                localPath=tagInfo{2};
                tagFilePath=tagInfo{1};
                if startsWith(tagFilePath,'toolbox')

                    filePath=fullfile(matlabroot,tagFilePath);
                else

                    filePath=tagFilePath;
                end
                obj.DataRepositoryRootDirectory=filePath;
                fileName=fullfile(filePath,localPath);


                if exist(fileName,'file')==2
                    xmlReader=foundation.internal.parameterization.XmlReader(fileName);
                    obj.SelectedManufacturer=...
                    getString(message('physmod:simscape:utils:BlockParameterizationManager:AllManufacturer'));
                    obj.SelectedPart=xmlReader.PartNumber;
                else


                    msgbox(pm_message('physmod:simscape:utils:BlockParameterizationManager:PartFileNotFound',fileName))


                    cachetag=get_param(block,'tag');
                    set_param(block,'tag','');
                    obj=foundation.internal.parameterization.SelectorModel(block);

                    set_param(block,'tag',cachetag);
                end
            end
        end

        function value=get.AvailableManufacturers(obj)
            manufacturers=findManufacturers(obj.DataRepositoryRootDirectory,obj.BlockHandle);

            value=[...
            {getString(message('physmod:simscape:utils:BlockParameterizationManager:AllManufacturer'))};...
            manufacturers];
        end

        function value=get.AvailableParts(obj)


            if~strcmp(obj.SelectedManufacturer,...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:AllManufacturer')))
                value=findParameterizations(...
                obj.DataRepositoryRootDirectory,obj.BlockHandle,obj.SelectedManufacturer);
            else
                if isempty(obj.AllManufacturersPartList)
                    value={};
                    availableManufacturers=obj.AvailableManufacturers;
                    for manufacturerIdx=2:length(availableManufacturers)

                        selectedManufacturerParts=findParameterizations(...
                        obj.DataRepositoryRootDirectory,obj.BlockHandle,availableManufacturers{manufacturerIdx});
                        if isempty(value)
                            value=[value;selectedManufacturerParts];%#ok<AGROW>
                        else
                            value={[value{1},selectedManufacturerParts{1}]...
                            ,[value{2},selectedManufacturerParts{2}]};
                        end
                    end
                    obj.AllManufacturersPartList=value;
                else
                    value=obj.AllManufacturersPartList;
                end
            end
        end

        function[variableNames,Data,row,column]=comparePartsTable(obj)
            availableParts=obj.AvailableParts;


            if~isempty(availableParts)&&...
                ~isempty(availableParts{2})
                partsCount=length(availableParts{2});
                partData={};


                for partIdx=1:partsCount
                    thisPart=foundation.internal.parameterization.XmlReader(...
                    fullfile(obj.DataRepositoryRootDirectory,availableParts{2}{partIdx}));
                    partTypeData=thisPart.getPartTypeData();
                    partValueTable=struct2table(partTypeData);
                    if isequal(partIdx,1)
                        partData=partValueTable{:,:};
                    else
                        valueColumn=partValueTable{:,2};
                        partData=[partData,valueColumn];%#ok<AGROW>
                    end
                end
                partData=partData';

                variableNames=[...
                {getString(message('physmod:simscape:utils:BlockParameterizationManager:PartNumber'))},...
                {getString(message('physmod:simscape:utils:BlockParameterizationManager:Manufacturer'))},...
                partData(1,:)]';


                partName=availableParts{1,1}(1,:)';
                partManufacturer=availableParts{1,1}(2,:)';
                partData=partData(2:end,:);
                partData=[partName,partManufacturer,partData];



                unitIdx=find(contains(variableNames,'_unit'));
                nonUnitIdx=find(~contains(variableNames,'_unit'));
                numericColumns=[];
                if~isempty(unitIdx)
                    for Idx=1:length(unitIdx)
                        columnNameWithUnit=variableNames{unitIdx(Idx)};
                        columnName=strsplit(columnNameWithUnit,'_unit');
                        columnIdx=find(strcmp(variableNames,columnName(1)));
                        if all(strcmp(partData(:,unitIdx(Idx)),partData(1,unitIdx(Idx))))


                            if~strcmp(partData{1,unitIdx(Idx)},'1')
                                variableNames(columnIdx)=strcat(variableNames(columnIdx),', ',partData{1,unitIdx(Idx)});
                            end
                        else
                            differentUnitIdx=~strcmp(partData(:,unitIdx(Idx)),partData(1,unitIdx(Idx)));
                            partIdx=find(~strcmp(partData(:,unitIdx(Idx)),partData(1,unitIdx(Idx))));
                            differentUnitVector=partData(differentUnitIdx,unitIdx(Idx));
                            differentMagnitudeVector=partData(differentUnitIdx,columnIdx);
                            sameUnitIdx=strcmp(partData(:,unitIdx(Idx)),partData(1,unitIdx(Idx)));
                            sameUnitVector=partData(sameUnitIdx,unitIdx(Idx));
                            referenceUnit=sameUnitVector{1};
                            for differentunitIdx=1:length(differentUnitVector)
                                extractedValue=simscape.Value(str2num(differentMagnitudeVector{differentunitIdx}),differentUnitVector{differentunitIdx});%#ok<ST2NM>
                                convertedValue=convert(extractedValue,referenceUnit);
                                partData(partIdx(differentunitIdx),columnIdx)={num2str(value(convertedValue))};
                                partData(partIdx(differentunitIdx),unitIdx(Idx))={referenceUnit};
                            end
                            if~strcmp(referenceUnit,'1')
                                variableNames(columnIdx)=strcat(variableNames(columnIdx),', ',referenceUnit);
                            end
                        end
                        numericColumns=[numericColumns;columnIdx];%#ok<AGROW>
                    end
                end


                [stringColumns,~]=setdiff(nonUnitIdx,numericColumns);
                columnsToDisplay=vertcat(stringColumns,numericColumns);
                Data=cell(height(partData),length(columnsToDisplay));
                Data(:,1:length(stringColumns))=partData(:,stringColumns);
                Data(:,length(stringColumns)+1:length(stringColumns)+length(numericColumns))=...
                cellfun(@str2num,partData(:,numericColumns),'UniformOutput',false);


                rowToHighlight=strcmp(partName,obj.SelectedPart);
                rowIdx=find(rowToHighlight);

                variableNames=variableNames(columnsToDisplay);

                row=ones(length(variableNames),1)*rowIdx;
                column=(1:length(variableNames))';
            else
                Data=[];
                variableNames=[];
                row=[];
                column=[];
            end
        end

        function value=get.TableData(obj)

            availableParts=obj.AvailableParts;

            if~isempty(availableParts{1})
                MenuItems=availableParts{1}(1,:);
                Files=availableParts{2};
                indx=strcmp(obj.SelectedPart,MenuItems);
                xmlFile=fullfile(obj.DataRepositoryRootDirectory,Files{indx});
                xmlReader=foundation.internal.parameterization.XmlReader(xmlFile);
                partSpecification=xmlReader.PartSpecification();
                note=wordWrapParameterizationNote(partSpecification.ParameterizationNote);


                partSpecification.ParameterizationNote=convertStringsToChars(note);

                value={getString(message('physmod:simscape:utils:BlockParameterizationManager:Manufacturer')),partSpecification.Manufacturer
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartNumber')),partSpecification.PartNumber
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartSeries')),partSpecification.PartSeries
                getString(message('physmod:simscape:utils:BlockParameterizationManager:WebLink')),partSpecification.WebLink
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartType')),partSpecification.PartType
                getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterizationDate')),partSpecification.ParameterizationDate
                getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterizationNote')),partSpecification.ParameterizationNote
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartDataFileLocation')),Files{indx}};
                obj.Index=indx;
            else

                value={getString(message('physmod:simscape:utils:BlockParameterizationManager:Manufacturer')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartNumber')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartSeries')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:WebLink')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartType')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterizationDate')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterizationNote')),''
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartDataFileLocation')),''};
            end
        end

        function[tag,localPath]=extractTag(obj)
            availableParts=obj.AvailableParts;


            if~isempty(availableParts{2})&&~isempty(obj.Index)
                localPath=availableParts{2}{obj.Index};


                repositoryFullFilePath=obj.DataRepositoryRootDirectory;
                matlabRoot=matlabroot;
                if contains(repositoryFullFilePath,matlabRoot)


                    filePath=repositoryFullFilePath(length(matlabRoot)+2:end);


                    filePath=strrep(filePath,'\','/');
                    localPath=strrep(localPath,'\','/');
                else

                    filePath=repositoryFullFilePath;
                end
                tag=['{''',filePath,''';''',localPath,'''}'];
            end
        end

        function updateBlockWithParameters(obj)

            if~isempty(obj.AvailableParts{2})&&~isempty(obj.Index)
                close_system(obj.BlockHandle)
                [tag,localPath]=obj.extractTag();
                fileName=fullfile(obj.DataRepositoryRootDirectory,localPath);
                blockParameterSet=foundation.internal.parameterization.BlockParameterSet();
                blockParameterSet.xmlRead(fileName);
                blockParameterSet.updateBlockParameters(obj.BlockHandle,tag);
            end
            obj.Status=getString(message('physmod:simscape:utils:BlockParameterizationManager:PartApplied'));
            notify(obj,'StatusChanged');
            notify(obj,'EnableReset');
        end

        function results=differenceBlockWithParameters(obj,~)

            availableParts=obj.AvailableParts;

            obj.SelectedPart=availableParts{1}{1,obj.Index};

            if~isempty(availableParts{2})&&~isempty(obj.Index)


                xmlFile=fullfile(obj.DataRepositoryRootDirectory,availableParts{2}{obj.Index});
                xmlReader=foundation.internal.parameterization.XmlReader(xmlFile);
                thisPart=struct;

                instanceData=xmlReader.getInstanceData();
                thisPart.Names=cellfun(@(x)string(x),{instanceData.Name});
                thisPart.Values={instanceData.Value};


                theBlock=foundation.internal.parameterization.SimscapeBlock(obj.BlockHandle);
                blocksPerTable=1;
                blockParameters=theBlock.getCombinedParameters(blocksPerTable);
                if isprop(blockParameters.Properties.CustomProperties,'DisplayRowNames')
                    paramName=blockParameters.Properties.CustomProperties.DisplayRowNames;
                end
                if isprop(blockParameters.Properties.CustomProperties,'RowIsEnum')
                    rowIsEnum=blockParameters.Properties.CustomProperties.RowIsEnum;
                end
                blockParameters=blockParameters(~rowIsEnum,:);
                blockParameters.Properties.CustomProperties.Visible=...
                blockParameters.Properties.CustomProperties.Visible(~rowIsEnum);
                obj.BlockInformation=blockParameters;


                paramName=paramName(~rowIsEnum,:);
                paramShortNames=blockParameters.Row;
                variableNames={getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterName')),...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:Parameterization')),...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:Override')),...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PartValue')),...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:PresentBlockValue')),...
                getString(message('physmod:simscape:utils:BlockParameterizationManager:Unit')),...
                };
                NoOfParameters=length(paramShortNames);
                results=table('Size',[NoOfParameters,length(fields(obj.DifferenceTableColumnOrder))],...
                'VariableTypes',{'string','string','logical','string','string','string'},'VariableNames',variableNames);
                for paramIdx=1:NoOfParameters
                    if any(strcmp(thisPart.Names,paramShortNames{paramIdx}))
                        results{paramIdx,...
                        obj.DifferenceTableColumnOrder.ParamName}=...
                        paramName(paramIdx);



                        if strcmp(obj.BlockLibraryType,'ee_lib')
                            results{paramIdx,...
                            obj.DifferenceTableColumnOrder.Source}=...
                            {getString(message(...
                            'physmod:simscape:utils:BlockParameterizationManager:Datasheet'))};
                        else
                            results{paramIdx,...
                            obj.DifferenceTableColumnOrder.Source}={'-'};
                        end






                        blockValueCell=blockParameters{paramIdx,1};
                        blockValue=blockValueCell{:};
                        if~isa(blockValue,'double')
                            if~isa(blockValue,'logical')
                                blockValue=strsplit(blockValue,'%');
                                blockValue=str2num(blockValue{1});%#ok<ST2NM>
                            else
                                blockValue=double(blockValue);
                            end
                        end
                        blockValue=fix(blockValue*obj.RoundOffValue)/obj.RoundOffValue;
                        results{paramIdx,...
                        obj.DifferenceTableColumnOrder.ParamValue}=...
                        cellstr(mat2str(blockValue));





                        blockUnitCell=blockParameters{paramIdx,2};
                        blockUnit=blockUnitCell{:};

                        blockParameter=simscape.Value(blockValue,blockUnit);


                        partValueIdx=strcmp(thisPart.Names,paramShortNames{paramIdx});
                        partValue=thisPart.Values(partValueIdx);
                        if isempty(str2num(partValue{:}))%#ok<ST2NM>
                            partValue=strsplit(partValue{:},'%');
                            if strcmp(partValue{2},...
                                getString(message(...
                                'physmod:simscape:utils:BlockParameterizationManager:ParameterNotSet')))
                                results{paramIdx,obj.DifferenceTableColumnOrder.Source}=...
                                {getString(message('physmod:simscape:utils:BlockParameterizationManager:ParameterNotSet'))};
                            else
                                results{paramIdx,obj.DifferenceTableColumnOrder.Source}=...
                                partValue(2);
                            end
                            partValue=str2num(partValue{1});%#ok<ST2NM>
                        else
                            partValue=str2num(partValue{:});%#ok<ST2NM>
                        end



                        partUnitIdx=strcmp(thisPart.Names,strcat(paramShortNames{paramIdx},'_unit'));
                        partUnit=thisPart.Values(partUnitIdx);
                        if~isempty(partUnit)







                            partUnit=partUnit{:};
                        else
                            continue
                        end

                        partParameter=simscape.Value(partValue,partUnit);







                        if~strcmp(blockUnit,partUnit)
                            partParameter=convert(partParameter,blockUnit);
                            partValue=value(partParameter);
                            partUnit=unit(partParameter);
                        end
                        partValue=fix(partValue*obj.RoundOffValue)/obj.RoundOffValue;
                        partParameter=simscape.Value(partValue,partUnit);

                        results{paramIdx,...
                        obj.DifferenceTableColumnOrder.PartValue}=...
                        cellstr(mat2str(partValue));

                        results{paramIdx,...
                        obj.DifferenceTableColumnOrder.Unit}=...
                        {blockUnit};


                        results{paramIdx,...
                        obj.DifferenceTableColumnOrder.Override}=...
                        checkOverrideStatus(blockParameter,partParameter);



                    end
                end
            end
            if isequal(nargin,2)
                obj.Status=getString(message('physmod:simscape:utils:BlockParameterizationManager:TableRefreshed'));
                notify(obj,'StatusChanged');
            end
        end

        function tableData=updateBlockColumn(obj,tableData)


            paramShortNames=obj.BlockInformation.Row;
            if~isequal(height(tableData),length(obj.BlockInformation.Row))
                paramShortNames=paramShortNames(obj.BlockInformation.Properties.CustomProperties.Visible);
            end
            blockValueColumn=cell(length(paramShortNames),1);
            for parameterIdx=1:length(paramShortNames)
                matchIdx=strcmp(obj.BlockDefaultParameters.BlockInformation(:,1),paramShortNames{parameterIdx});


                blockValueCell=obj.BlockDefaultParameters.BlockInformation(matchIdx,2);
                blockValue=blockValueCell{:};
                obj.updateBlockParameter(paramShortNames{parameterIdx},blockValue);
                if~isa(blockValue,'double')
                    blockValue=strsplit(blockValue,'%');
                    blockValue=str2num(blockValue{1});%#ok<ST2NM>
                end
                blockValue=fix(blockValue*obj.RoundOffValue)/obj.RoundOffValue;
                blockValueColumn{parameterIdx,1}=mat2str(blockValue);
            end


            tableData(:,obj.DifferenceTableColumnOrder.ParamValue)=blockValueColumn;
            blockValues=tableData(:,obj.DifferenceTableColumnOrder.ParamValue);
            partValues=tableData(:,obj.DifferenceTableColumnOrder.PartValue);
            tableData{:,obj.DifferenceTableColumnOrder.Override}=checkOverrideStatus(blockValues,partValues);


            set_param(obj.BlockHandle,'Tag',obj.BlockDefaultParameters.Tag);
            set_param(obj.BlockHandle,'AttributesFormatString',obj.BlockDefaultParameters.Attribute);
            notify(obj,'EnableReset');
        end

        function setBlockLinkWithPart(obj)
            [tag,~]=obj.extractTag();
            set_param(obj.BlockHandle,'Tag',tag);

            availableParts=obj.AvailableParts;

            manufacturerIdx=find(strcmp(availableParts{1}(1,:),obj.SelectedPart));
            manufacturerName=availableParts{1}{2,manufacturerIdx};%#ok<*FNDSB>
            attributeString=[manufacturerName,':',obj.SelectedPart];
            set_param(obj.BlockHandle,'AttributesFormatString',attributeString);
        end

        function updateBlockParameter(obj,paramName,paramValue)

            if ishandle(obj.BlockHandle)
                name=get_param(obj.BlockHandle,'Name');
                parent=get_param(obj.BlockHandle,'Parent');
                blockName=[parent,'/',name];
                blockHandle=obj.BlockHandle;
            else
                blockName=obj.BlockHandle;
                blockHandle=get_param(blockName,'handle');
            end
            set_param(blockName,paramName,paramValue);

            if~isempty(get_param(blockHandle,'AttributesFormatString'))
                set_param(blockHandle,'AttributesFormatString','');
            end

            if~isempty(get_param(blockHandle,'tag'))
                set_param(blockHandle,'tag','');
            end
            notify(obj,'EnableReset');
        end

        function[row,column]=highlightCellsInCompareWithBlock(obj,tableData)




            rowsToHighlight=...
            tableData{:,obj.DifferenceTableColumnOrder.Override}==true;
            rowIdx=find(rowsToHighlight);
            row=rowIdx;

            blockColumnNumber=obj.DifferenceTableColumnOrder.ParamValue;
            blockColumn=ones(length(rowIdx),1)*blockColumnNumber;
            column=blockColumn;

            if isempty(row)
                obj.Status=getString(message('physmod:simscape:utils:BlockParameterizationManager:NoCellsToHighlight'));
                notify(obj,'StatusChanged');
            else
                obj.Status=getString(message('physmod:simscape:utils:BlockParameterizationManager:ModifiedCellsHighlighted'));
                notify(obj,'StatusChanged');
            end
        end

        function[rowVector,columnVector]=highlightEditableColumns(obj,rows,columns)


            rowVector=repmat((1:rows)',length(columns),1);
            columnVector=[];

            for columnIdx=1:length(columns)
                singleColumnValue=ones([rows,1])*columns(columnIdx);
                columnVector=[columnVector;singleColumnValue];%#ok<AGROW>
            end

            obj.Status=getString(message('physmod:simscape:utils:BlockParameterizationManager:EditablecellsHighlighted'));
            notify(obj,'StatusChanged');
        end

        function createNewPart(obj,manufacturer,partNumber,partSeries,partType,webLink,parameterizationNote,databaseRootDirectory,~)

            thisPart=foundation.internal.parameterization.BlockParameterSet;
            thisPart.extractBlockParameters(obj.BlockHandle);
            thisPart.addMetadata(obj.BlockHandle,manufacturer,partNumber,partSeries,partType,webLink,parameterizationNote)


            referenceBlock=thisPart.ReferenceBlock;
            blockDirectory=mapReferenceBlockToPath(referenceBlock);
            manufacturerValidName=matlab.lang.makeValidName(replace(manufacturer,' ','_'));
            partNumberValidName=matlab.lang.makeValidName(replace(partNumber,' ','_'));
            filename=fullfile(databaseRootDirectory,blockDirectory,manufacturerValidName,...
            sprintf([partNumberValidName,'.xml']));


            targetDirectory=fullfile(databaseRootDirectory,blockDirectory,manufacturerValidName);
            if~exist(targetDirectory,'dir')&&~isempty(targetDirectory)

                mkdir(targetDirectory)
            end


            thisPart.xmlWrite(filename)
        end

    end
end

function value=wordWrapParameterizationNote(note)
    wordsInNote=strsplit(note,' ');
    wordsPerLine=9;
    if length(wordsInNote)>=wordsPerLine

        noOfLines=floor(length(wordsInNote)/wordsPerLine);
        lastLine=length(wordsInNote)-(noOfLines*wordsPerLine);
        if lastLine
            LineString=cell(noOfLines+1,1);
        else
            LineString=cell(noOfLines);
        end
        for lineIdx=1:noOfLines
            lineString="";
            for wordIdx=1:wordsPerLine
                lineString=strcat(lineString," ",wordsInNote{((lineIdx-1)*wordsPerLine)+wordIdx});

            end
            LineString{lineIdx}=lineString;

        end
        if lastLine
            lineString="";
            for wordIdx=1:lastLine
                lineString=strcat(lineString," ",wordsInNote{(lineIdx*wordsPerLine)+wordIdx});
            end
            LineString{lineIdx+1}=lineString;
        end
        value=sprintf("%s\n",LineString{:});

    else
        value=sprintf("%s",note);
    end
end

function overrideStatus=checkOverrideStatus(blockParameter,partValue)

    if isa(blockParameter,'table')
        matchIdx=~strcmp(blockParameter{:,1},partValue{:,1});
    elseif isa(blockParameter,'simscape.Value')
        if isequal(size(blockParameter),size(partValue))
            if all(blockParameter==partValue)
                matchIdx=false;
            else
                matchIdx=true;
            end
        else
            matchIdx=true;
        end
    end
    overrideStatus=matchIdx;
end

