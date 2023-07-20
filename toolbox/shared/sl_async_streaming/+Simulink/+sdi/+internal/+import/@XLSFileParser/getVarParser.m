function varParsers=getVarParser(this,wksParser,fileName,varargin)



    sw=warning('off','SimulationData:Objects:InvalidAccessToDatasetElement');
    tmp=onCleanup(@()warning(sw));

    varParsers={};
    this.NumMetaDataRows=cell(this.NumSheets,1);
    this.UniqueBuses={};
    this.UniqueBusBlockPaths={};
    this.SignalMetaData={};
    this.CachedTableData=containers.Map;
    this.CachedTableTypes=containers.Map;
    this.TypeIDs=matlab.io.internal.TypeDetection.TypeID;

    p=inputParser;
    p.KeepUnmatched=true;
    p.addParameter('sheets',{});
    p.parse(varargin{:});
    params=p.Results;
    sheetsToImport=cellstr(params.sheets);


    [~,~,ext]=fileparts(fileName);
    this.WorkBook=matlab.io.spreadsheet.internal.createWorkbook(...
    erase(ext,'.'),fileName,false);
    this.SheetNames=this.WorkBook.SheetNames;
    this.NumSheets=length(this.SheetNames);


    invalidSheets=[];
    for sheetIdx=1:this.NumSheets
        currSheetName=this.SheetNames{sheetIdx};


        if~isempty(sheetsToImport)&&~any(strcmp(sheetsToImport,currSheetName))
            numVars=0;
        else
            currSheet=this.WorkBook.getSheet(sheetIdx);
            resolvedTypes=currSheet.types;
            this.CachedTableTypes(currSheetName)=resolvedTypes;
            metaRows=locGetMetaRows(resolvedTypes,'string');
            [~,numVars]=size(resolvedTypes);
        end

        if~numVars
            invalidSheets(end+1)=sheetIdx;%#ok<AGROW>
            this.SignalMetaData{sheetIdx}=struct();
            this.NumMetaDataRows{sheetIdx}=0;
            continue
        end

        numMetadataRows=metaRows-1;
        this.NumMetaDataRows{sheetIdx}=numMetadataRows;
        try


            [T_full,~]=this.readTableForSheet(currSheetName,sheetIdx);

            T_metadata=T_full(1:numMetadataRows+1,:);
            T_metadata=cell2table(T_metadata);
            numVars=width(T_metadata);


            T_metadata=rmmissing(T_metadata,'MinNumMissing',numVars);
            numMetadataRows=height(T_metadata)-1;
            this.NumMetaDataRows{sheetIdx}=numMetadataRows;


            signalNames=cell(numVars,1);
            for colIdx=1:numVars
                cellVal=T_metadata{1,colIdx};
                if isa(cellVal,'double')
                    signalNames{colIdx}='';
                else
                    signalNames{colIdx}=cellVal{1};
                end


                if strcmpi(signalNames{colIdx},'time')
                    md=T_metadata{2:end,colIdx};
                    if any(contains(md,'name:','IgnoreCase',true))
                        signalNames{colIdx}='<placeholder>';
                    end
                end
            end
        catch me %#ok<NASGU>

            invalidSheets(end+1)=sheetIdx;%#ok<AGROW>
            this.SignalMetaData{sheetIdx}=struct();
            continue
        end


        indices=locGetColIndices(this,signalNames);
        signalNames=signalNames(indices.signal);


        mdp=Simulink.sdi.internal.import.MetaDataParser;
        mdp.reset(signalNames,indices.signal);
        for sigIdx=1:numel(signalNames)
            sigMetadata=T_metadata{:,indices.signal(sigIdx)}(2:end);
            if iscell(sigMetadata)
                for metadataIdx=1:numMetadataRows
                    metaDataStr=strtrim(sigMetadata{metadataIdx});
                    mdp.parseRow(sigIdx,metaDataStr,false);
                end
            end
        end



        for timeIdx=1:numel(indices.time)
            timeMetadata=T_metadata{:,indices.time(timeIdx)}(2:end);
            for metadataIdx=1:numMetadataRows
                metaDataStr=timeMetadata{metadataIdx};
                metaDataStr=metaDataStr(find(~isspace(metaDataStr)));%#ok
                if~isempty(metaDataStr)

                    pos=find(indices.signal>indices.time(timeIdx));
                    if~isempty(pos)
                        sigIdx=pos(1);
                        mdp.parseRow(sigIdx,metaDataStr,true);
                    end
                end
            end
        end


        ds=mdp.constructDatasetFromMetaData();
        ds=locAddParameterSignals(this,ds,indices,currSheetName,sheetIdx);
        ds=this.getSignalDataFromSheet(ds,indices.signal,indices.time,sheetIdx);
        ds=locSortDatasetElements(this,ds,indices,sheetIdx);


        varParser=Simulink.sdi.internal.import.DatasetParser;
        varParser.VariableName=currSheetName;
        varParser.VariableValue=ds;
        varParser.TimeSourceRule='';
        varParser.WorkspaceParser=wksParser;
        varParsers{end+1}=varParser;%#ok
    end

    if~isempty(invalidSheets)
        this.NumMetaDataRows(invalidSheets)=[];
        this.SheetNames(invalidSheets)=[];
        this.SignalMetaData(invalidSheets)=[];
        this.NumSheets=length(this.SheetNames);
    end

    this.VarParsers=varParsers;
end


function indices=locGetColIndices(this,signalNames)



    signalNames=lower(signalNames);


    indices.time=strcmp(signalNames,'time');


    indices.param=strcmp(signalNames,'parameter:');
    if any(indices.param)
        indices.param_val=strcmp(signalNames,'value:');
        indices.param_path=strcmp(signalNames,'blockpath:')|strcmp(signalNames,'maskblockpath:');
        locValidateParamColumns(this,indices);
    else
        indices.param_val=false(size(signalNames));
        indices.param_path=false(size(signalNames));
    end



    indices.signal=find(~indices.time&~indices.param&~indices.param_val&~indices.param_path);

    indices.time=find(indices.time);
    indices.param=find(indices.param);
    indices.param_val=find(indices.param_val);
    indices.param_path=find(indices.param_path);
end


function locValidateParamColumns(this,indices)
    bIsError=false;
    paramCols=find(indices.param);
    numParamCol=numel(paramCols);


    valCols=find(indices.param_val);
    if numParamCol~=numel(valCols)
        bIsError=true;
    elseif valCols~=paramCols+1
        bIsError=true;
    end


    pathCols=find(indices.param_path);
    if numel(pathCols)>numParamCol
        bIsError=true;
    elseif any(pathCols<3)
        bIsError=true;
    else
        for idx=1:numel(pathCols)
            if~indices.param(pathCols(idx)-2)
                bIsError=true;
                break;
            end
        end
    end

    if bIsError
        err=message('SDI:sdi:XLInvalidParamImport');
        if~this.CmdLine
            locShowXLImportErrorDlg(getString(err));
        end
        error(err);
    end
end


function locShowXLImportErrorDlg(msgStr)
    titleStr=getString(message('SDI:sdi:ImportError'));
    okStr=getString(message('SDI:sdi:OKShortcut'));
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    ctrl=Simulink.sdi.internal.controllers.ImportDialog.getController();
    fw.displayMsgBox(...
    'default',...
    titleStr,...
    msgStr,...
    {okStr},...
    0,...
    -1,...
    [],...
    'clientID',ctrl.ClientID);
end


function ds=locAddParameterSignals(this,ds,indices,sheetName,sheetIdx)
    if isempty(indices.param)
        return
    end


    mdp=Simulink.sdi.internal.import.MetaDataParser;
    [tab,~]=this.readTableForSheet(sheetName,sheetIdx);
    for idx=1:numel(indices.param)

        colIdx=indices.param(idx);
        paramNames=tab(2:end,colIdx);
        paramVals=tab(2:end,colIdx+1);
        bHasPath=any(indices.param_path==colIdx+2);
        if bHasPath
            paramPaths=tab(2:end,colIdx+2);
        end



        mdp.reset(paramNames,linspace(colIdx,colIdx+0.9,numel(paramNames)));


        for idx2=1:numel(paramNames)
            if isvarname(paramNames{idx2})&&~isempty(paramVals{idx2})
                try
                    val=eval(paramVals{idx2});
                catch me %#ok<NASGU>
                    val=string(paramVals{idx2});
                end
                el=Simulink.SimulationData.Parameter;
                el.Name=paramNames{idx2};
                if isstring(val)
                    el.Values=timeseries(0,0,'Name',paramNames{idx2});
                    el.Values.Data=val;
                else
                    el.Values=timeseries(val,0,'Name',paramNames{idx2});
                end
                if bHasPath
                    el.BlockPath=paramPaths{idx2};
                end
                el=el.setVisualizationMetadata(mdp.getSignalMetadata(idx2));
                ds{end+1}=el;%#ok
            end
        end
    end
end


function ds=locSortDatasetElements(this,ds,indices,sheetIdx)


    if isempty(indices.param)||isempty(indices.signal)
        return
    end


    numEl=ds.numElements();
    colKeys=zeros(1,numEl);
    elVals=cell(1,numEl);
    for idx=1:numEl
        elVals{idx}=ds.getElement(idx);

        md=elVals{idx}.getVisualizationMetadata();
        if iscell(md)
            colKeys(idx)=double(md{1}.OrigColIdx);
            md{1}.OrigDatasetPos=idx;
        elseif isstruct(md)
            colKeys(idx)=double(md.OrigColIdx);
            md.OrigDatasetPos=idx;
        end

        elVals{idx}=elVals{idx}.setVisualizationMetadata(md);
    end


    sm=containers.Map(colKeys,elVals);
    sortedEls=sm.values;


    dsName=ds.Name;
    ds=Simulink.SimulationData.Dataset;
    ds.Name=dsName;
    orderedSigData=struct.empty();
    for idx=1:numEl
        ds=ds.addElement(sortedEls{idx});

        md=sortedEls{idx}.getVisualizationMetadata();
        if iscell(md)
            origIdx=md{1}.OrigDatasetPos;
        else
            origIdx=md.OrigDatasetPos;
        end

        if isempty(orderedSigData)
            orderedSigData=this.SignalMetaData{sheetIdx}(origIdx);
        else
            orderedSigData(idx)=this.SignalMetaData{sheetIdx}(origIdx);
        end
    end

    numParams=length(this.SignalMetaData{sheetIdx})-length(orderedSigData);
    if numParams>0
        paramStartIdx=length(orderedSigData)+1;
        paramEndIdx=length(this.SignalMetaData{sheetIdx});
        for idx=paramStartIdx:paramEndIdx
            orderedSigData(end+1)=this.SignalMetaData{sheetIdx}(idx);%#ok
        end
    end
    this.SignalMetaData{sheetIdx}=orderedSigData;
end

function colNum=locXlsColStr2Num(colChar)
    colNum=cellfun(@(x)(sum((double(x)-64).*26.^(length(x)-1:-1:0))),...
    colChar);
end

function metaRows=locGetMetaRows(typeIDs,readVarNames)
    persistent enum
    persistent typenames

    if isempty(typenames)
        enum.NUMBER=matlab.io.spreadsheet.internal.Sheet.NUMBER;
        enum.STRING=matlab.io.spreadsheet.internal.Sheet.STRING;
        enum.DATETIME=matlab.io.spreadsheet.internal.Sheet.DATETIME;
        enum.BOOLEAN=matlab.io.spreadsheet.internal.Sheet.BOOLEAN;
        enum.EMPTY=matlab.io.spreadsheet.internal.Sheet.EMPTY;
        enum.BLANK=matlab.io.spreadsheet.internal.Sheet.BLANK;
        enum.ERROR=matlab.io.spreadsheet.internal.Sheet.ERROR;


        typenames={'double','char','datetime','logical','','','','duration','hexadecimal','binary'};
    end

    if~exist('readVarNames','var')
        readVarNames=true;
    end

    textmask=(typeIDs==enum.STRING)|...
    (typeIDs==enum.BLANK)|...
    (typeIDs==enum.ERROR)|...
    (typeIDs==enum.EMPTY);


    metaRows=min([size(typeIDs,1),find(~all(textmask,2),1)-1]);



    if metaRows==size(typeIDs,1)

        metaRows=min(size(typeIDs,1),double(readVarNames));
        return
    end


    typeIDs=double(typeIDs);

    typeIDs(typeIDs==enum.BLANK|typeIDs==enum.ERROR|typeIDs==enum.EMPTY)=NaN;

    dominantType=mode(typeIDs((metaRows+1):end,:),1);

    if any(dominantType~=enum.STRING)&&(metaRows>0)

        isStrings=(dominantType==enum.STRING);

        for i=1:metaRows
            rowTypes=typeIDs(i,:);
            isBlankOrText=isStrings|ismissing(rowTypes);
            if~all(isBlankOrText)...
                &&all(isBlankOrText|(rowTypes==dominantType))
                metaRows=i-1;
                break;
            end
        end
    elseif all(dominantType==enum.STRING)&&(metaRows>0)


        metaRows=min(size(typeIDs,1),double(readVarNames));
    end
end

