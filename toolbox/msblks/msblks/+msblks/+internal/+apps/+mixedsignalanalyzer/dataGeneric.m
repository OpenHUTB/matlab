classdef dataGeneric<handle




    properties
        simulationsDB={};
csvFileName
fullPathCsvFileName
    end

    methods
        function obj=dataGeneric(fullPathCsvFileName,csvFileName,isGetCursoryDataOnly)
            try
                obj.csvFileName=csvFileName;
                obj.fullPathCsvFileName=fullPathCsvFileName;
                if isa(obj.fullPathCsvFileName,'msblks.internal.mixedsignalanalysis.SimulationsDB')

                    obj.simulationsDB=obj.fullPathCsvFileName;
                    obj.fullPathCsvFileName=[];
                elseif isGetCursoryDataOnly

                    obj.getCursoryDataOnly();
                else

                    obj.getWaveforms();
                end
            catch err
                uiwait(warndlg(err.message));
            end
        end

        function getCursoryDataOnly(obj)
            if isempty(obj.fullPathCsvFileName)
                return;
            end
            [fileID,msg]=fopen(obj.fullPathCsvFileName,'r');
            if fileID==-1
                error(msg);
                fclose(fileID);
                return;
            end
            line=fgetl(fileID);
            while ischar(line)
                if~startsWith(line,'Database#')&&...
                    ~startsWith(line,'Data Source:')&&...
                    ~startsWith(line,'File Name:')&&...
                    ~startsWith(line,'File Path:')&&...
                    ~startsWith(line,'Simulation')
                    line=fgetl(fileID);
                    continue;
                end
                fields=parseLine(line);
                if isempty(fields)||~iscell(fields)||length(fields)<2
                    line=fgetl(fileID);
                    continue;
                end
                switch fields{1}
                case 'Database#'

                    obj.simulationsDB{end+1}=msblks.internal.mixedsignalanalysis.SimulationsDB;
                case 'Data Source:'
                    obj.simulationsDB{end}.sourceType=fields{2};
                case 'File Name:'
                    obj.simulationsDB{end}.matFileName=[fields{2},' (GDB)'];
                case 'File Path:'
                    obj.simulationsDB{end}.fullPathMatFileName=fields{2};
                otherwise
                    if startsWith(fields{1},'Simulation')&&endsWith(fields{1},':')

                        simulationResults=msblks.internal.mixedsignalanalysis.SimulationResults;
                        simulationResults.setParam('tableName',fields{2});
                        simulationResults.setParam('wfDBIndex',length(obj.simulationsDB));
                        obj.simulationsDB{end}.setSimulationResults(fields{2},simulationResults);
                    end
                end
                line=fgetl(fileID);
            end
            fclose(fileID);
        end

        function getWaveforms(obj)
            if isempty(obj.fullPathCsvFileName)
                return;
            end
            [fileID,msg]=fopen(obj.fullPathCsvFileName,'r');
            if fileID==-1
                error(msg);
                fclose(fileID);
                return;
            end
            simulationResults=[];
            line=fgetl(fileID);
            while ischar(line)
                fields=parseLine(line);
                if isempty(fields)||~iscell(fields)||length(fields)<2
                    line=fgetl(fileID);
                    continue;
                end
                switch fields{1}
                case 'Database#'

                    obj.simulationsDB{end+1}=msblks.internal.mixedsignalanalysis.SimulationsDB;
                case 'Data Source:'
                    obj.simulationsDB{end}.sourceType=fields{2};
                case 'File Name:'
                    obj.simulationsDB{end}.matFileName=[fields{2},' (GDB)'];
                case 'File Path:'
                    obj.simulationsDB{end}.fullPathMatFileName=fields{2};
                case 'Simulation Count'

                case 'Parameter Count'

                case 'Waveform Count'


                    if~isempty(paramValues)

                        setParamValues(simulationResults,paramValues)
                    end
                case 'X-axis label:'
                    simulationResults.XaxisLabels=fields(2);
                    simulationResults.isSameLabelsX=true;
                case 'Y-axis label:'
                    simulationResults.YaxisLabels=fields(2);
                    simulationResults.isSameLabelsY=true;
                case 'X-axis units:'
                    simulationResults.XaxisUnits=fields(2);
                    simulationResults.isSameUnitsX=true;
                case 'Y-axis units:'
                    simulationResults.YaxisUnits=fields(2);
                    simulationResults.isSameUnitsY=true;
                case 'X-axis scale:'
                    simulationResults.XaxisScales=fields(2);
                    simulationResults.isSameScalesX=true;
                case 'Y-axis scale:'
                    simulationResults.YaxisScales=fields(2);
                    simulationResults.isSameScalesY=true;
                case 'Max XY Data Points'
                    maxXYdataPoints=str2double(fields{2});
                otherwise
                    if startsWith(fields{1},'Simulation')&&endsWith(fields{1},':')
                        if~isempty(simulationResults)

                            setShortColumnNamesAndColumnValues(simulationResults);
                        end


                        simulationResults=msblks.internal.mixedsignalanalysis.SimulationResults;
                        simulationResults.setParam('tableName',fields{2});
                        simulationResults.setParam('wfDBIndex',length(obj.simulationsDB));
                        obj.simulationsDB{end}.setSimulationResults(fields{2},simulationResults);


                        designParamsCount=0;
                        paramNames={};
                        paramValues={};
                        maxXYdataPoints=Inf;
                        waveformTypes={};
                        nodes={};
                    elseif startsWith(fields{1},'Parameter')&&contains(fields{1},':')

                        values{length(fields)-2}=[];%#ok<AGROW>
                        for i=3:length(fields)
                            values{i-2}=fields{i};
                        end
                        if contains(fields{1},'Metric')
                            values=stringCellArray2NumericCellArray(values);
                        end
                        simulationResults.setParam(fields{2},values);
                        if contains(fields{1},'Design')
                            designParamsCount=designParamsCount+1;
                            simulationResults.setParam('designParamsCount',designParamsCount);
                        end
                        if contains(fields{1},'Design')||contains(fields{1},'Metric')
                            paramNames{end+1}=fields{2};%#ok<AGROW>
                            simulationResults.setParam('paramNames',paramNames);
                            simulationResults.setParam('paramNames_ShortMetrics',paramNames);
                            if isempty(paramValues)
                                paramValues=values';
                            else
                                paramValues(:,end+1)=values';%#ok<AGROW> Add column of values.
                            end
                        end
                    elseif startsWith(fields{1},'Waveform name (')&&endsWith(fields{1},'):')

                        simulationResults.WaveNames{end+1}=fields{2};
                        [~,simType,nodeName,~]=unpackWaveformName(fields{2});
                        if~any(strcmp(waveformTypes,simType))
                            waveformTypes{end+1}=simType;%#ok<AGROW>
                            simulationResults.setParam('waveformTypes',waveformTypes);
                        end
                        if~any(strcmp(nodes,nodeName))
                            nodes{end+1}=nodeName;%#ok<AGROW>
                            simulationResults.setParam('nodes',nodes);
                        end
                    elseif startsWith(fields{1},'X-axis label (')&&endsWith(fields{1},'):')

                        simulationResults.XaxisLabels{end+1}=fields{2};
                    elseif startsWith(fields{1},'Y-axis label (')&&endsWith(fields{1},'):')

                        simulationResults.YaxisLabels{end+1}=fields{2};
                    elseif startsWith(fields{1},'X-axis units (')&&endsWith(fields{1},'):')

                        simulationResults.XaxisUnits{end+1}=fields{2};
                    elseif startsWith(fields{1},'Y-axis units (')&&endsWith(fields{1},'):')

                        simulationResults.YaxisUnits{end+1}=fields{2};
                    elseif startsWith(fields{1},'X-axis scale (')&&endsWith(fields{1},'):')

                        simulationResults.XaxisScales{end+1}=fields{2};
                    elseif startsWith(fields{1},'Y-axis scale (')&&endsWith(fields{1},'):')

                        simulationResults.YaxisScales{end+1}=fields{2};
                    elseif strcmpi(fields{1},'X')&&strcmpi(fields{end},'Y')

                        waveformsXY=getWaveformsXY(fileID,fields,maxXYdataPoints);
                        simulationResults.XaxisValues=waveformsXY{1};
                        simulationResults.YaxisValues=waveformsXY{2};
                        simulationResults.isSameValuesX=true;
                        simulationResults.isSameValuesY=true;
                    elseif strcmpi(fields{1},'X')

                        waveformsXY=getWaveformsXY(fileID,fields,maxXYdataPoints);
                        simulationResults.XaxisValues=waveformsXY{1};
                        simulationResults.isSameValuesX=true;
                        for column=2:length(waveformsXY)
                            simulationResults.YaxisValues{end+1}=waveformsXY{column};
                        end
                    elseif strcmpi(fields{end},'Y')

                        waveformsXY=getWaveformsXY(fileID,fields,maxXYdataPoints);
                        for column=1:length(waveformsXY)-1
                            simulationResults.XaxisValues{end+1}=waveformsXY{column};
                        end
                        simulationResults.YaxisValues=waveformsXY{end};
                        simulationResults.isSameValuesY=true;
                    elseif strcmpi(fields{1},'X(1)')

                        waveformsXY=getWaveformsXY(fileID,fields,maxXYdataPoints);
                        for column=1:2:length(waveformsXY)-1
                            simulationResults.XaxisValues{end+1}=waveformsXY{column};
                            simulationResults.YaxisValues{end+1}=waveformsXY{column+1};
                        end
                    end
                end
                line=fgetl(fileID);
            end
            if~isempty(simulationResults)

                setShortColumnNamesAndColumnValues(simulationResults);
            end
            fclose(fileID);
        end

        function writeDataGeneric(obj)
            if isempty(obj.fullPathCsvFileName)
                return;
            end
            fileID=fopen(obj.fullPathCsvFileName,'w');
            for i=1:length(obj.simulationsDB)
                if length(obj.simulationsDB)==1
                    db=obj.simulationsDB;
                else
                    db=obj.simulationsDB(i);
                end
                fprintf(fileID,'Database#,%d\n',i);
                putAttribute(fileID,'Data Source',NaN,db.sourceType,true);
                putAttribute(fileID,'File Name',NaN,db.matFileName,true);
                putAttribute(fileID,'File Path',NaN,db.fullPathMatFileName,true);
                fprintf(fileID,'Simulation Count,%d\n',length(db.SimulationResultsObjects));
                fprintf(fileID,'\n');
                for j=1:length(db.SimulationResultsObjects)
                    simName=db.SimulationResultsNames{j};
                    simData=db.SimulationResultsObjects{j};

                    putAttribute(fileID,'Simulation',j,simName,length(db.SimulationResultsObjects)==1);
                    fprintf(fileID,'\n');

                    designParamsCount=simData.getParamValue('designParamsCount');
                    shortVsLongValues=simData.getParamValue('corModelSpec_ShortVsLongValues');
                    putParameters(fileID,simData.ParamNames,simData.ParamValues,designParamsCount,shortVsLongValues);

                    fprintf(fileID,'Waveform Count,%d\n',length(simData.WaveNames));
                    putWfAttribute(fileID,'Waveform name',simData.WaveNames,length(simData.WaveNames)==1);
                    putWfAttribute(fileID,'X-axis label',simData.XaxisLabels,simData.isSameLabelsX);
                    putWfAttribute(fileID,'Y-axis label',simData.YaxisLabels,simData.isSameLabelsY);
                    putWfAttribute(fileID,'X-axis units',simData.XaxisUnits,simData.isSameUnitsX);
                    putWfAttribute(fileID,'Y-axis units',simData.YaxisUnits,simData.isSameUnitsY);
                    putWfAttribute(fileID,'X-axis scale',simData.XaxisScales,simData.isSameScalesX);
                    putWfAttribute(fileID,'Y-axis scale',simData.YaxisScales,simData.isSameScalesY);

                    putWfxy(fileID,simData.XaxisValues,simData.YaxisValues,simData.isSameValuesX,simData.isSameValuesY);
                end









            end
            fclose(fileID);
        end
    end
end


function putAttribute(fileID,name,index,value,isSingleValue)
    if isSingleValue
        fprintf(fileID,'%s:,%s\n',quoteTextWithCommas(name),quoteTextWithCommas(value));
    else
        fprintf(fileID,'%s (%d):,%s\n',quoteTextWithCommas(name),index,quoteTextWithCommas(value));
    end
end
function putParameters(fileID,paramNames,paramValues,designParamsCount,shortVsLongValues)
    text=['Parameter Count,',num2str(length(paramNames)-10)];
    fprintf(fileID,'%s\n',text);
    count=0;
    for i=1:length(paramNames)
        name=paramNames{i};
        if strcmpi(name,'tableName')||...
            strcmpi(name,'nodes')||...
            strcmpi(name,'waveformTypes')||...
            strcmpi(name,'paramNames')||...
            strcmpi(name,'paramValues')||...
            strcmpi(name,'designParamsCount')||...
            strcmpi(name,'paramNames_ShortMetrics')||...
            strcmpi(name,'params_ShortVsLongNames')||...
            strcmpi(name,'corModelSpec_ShortVsLongValues')||...
            strcmpi(name,'wfDBIndex')
            continue;
        end
        count=count+1;
        values=paramValues{i};
        if strcmpi(name,'corModelSpec')&&~isempty(shortVsLongValues)

            for j=1:length(values)
                for k=1:length(shortVsLongValues)
                    if strcmp(values{j},shortVsLongValues{k}{1})
                        values{j}=shortVsLongValues{k}{2};
                        break;
                    end
                end
            end
        end
        if count==1
            param=['Parameter(',num2str(count),'): State,'];
        elseif count<=designParamsCount+1
            param=['Parameter(',num2str(count),'): Design,'];
        else
            param=['Parameter(',num2str(count),'): Metric,'];
        end
        if isempty(values)

            text=[param,quoteTextWithCommas(name),',NA'];
            fprintf(fileID,'%s\n',text);
        elseif~iscell(values)

            text=[param,quoteTextWithCommas(name),',',quoteTextWithCommas(values)];
            fprintf(fileID,'%s\n',text);
        elseif~iscell(values{1})

            text=[param,quoteTextWithCommas(name)];
            for j=1:length(values)
                text=[text,',',quoteTextWithCommas(values{j})];%#ok<AGROW>
            end
            fprintf(fileID,'%s\n',text);
        else

            for j=1:length(values)
                name2=[name,'(',num2str(j),')'];
                values2=values{j};
                text=[param,quoteTextWithCommas(name2)];
                for k=1:length(values2)
                    text=[text,',',quoteTextWithCommas(values2{k})];%#ok<AGROW>
                end
                fprintf(fileID,'%s\n',text);
            end
        end
    end
    fprintf(fileID,'\n');
end
function putWfAttribute(fileID,name,values,isSingleValue)
    if isSingleValue
        fprintf(fileID,'%s:,%s\n',quoteTextWithCommas(name),quoteTextWithCommas(values));
    else
        for i=1:length(values)
            fprintf(fileID,'%s (%d):,%s\n',quoteTextWithCommas(name),i,quoteTextWithCommas(values{i}));
        end
    end
    fprintf(fileID,'\n');
end
function putWfxy(fileID,x,y,isSingleX,isSingleY)
    maxLength=max(getMaxLength(x,isSingleX),getMaxLength(y,isSingleY));
    text=['Max XY Data Points,',num2str(maxLength)];
    fprintf(fileID,'%s\n',text);
    fprintf(fileID,'%s\n',getHeader(x,y,isSingleX,isSingleY));
    for row=1:maxLength
        fprintf(fileID,'%s\n',getRowValues(x,y,isSingleX,isSingleY,row));
    end
    fprintf(fileID,'\n');
end


function header=getHeader(x,y,isSingleX,isSingleY)
    if isSingleX&&isSingleY
        header='X,Y';
    elseif isSingleX
        header=['X,',getHeaderText('Y',length(y))];
    elseif isSingleY
        header=[getHeaderText('X',length(x)),',Y'];
    else
        header=getHeaderText2('X','Y',length(x));
    end
end
function headerText=getHeaderText(text,count)

    headerText='';
    for i=1:count
        headerText=[headerText,text,'(',num2str(i),')'];%#ok<AGROW>
        if i<count
            headerText=[headerText,','];%#ok<AGROW>
        end
    end
end
function headerText=getHeaderText2(text1,text2,count)

    headerText='';
    for i=1:count
        headerText=[headerText,text1,'(',num2str(i),'),',text2,'(',num2str(i),')'];%#ok<AGROW>
        if i<count
            headerText=[headerText,','];%#ok<AGROW>
        end
    end
end


function rowValues=getRowValues(x,y,isSingleX,isSingleY,row)
    if isSingleX&&isSingleY

        rowValues=[getStringValue(x,row),',',getStringValue(y,row)];
    elseif isSingleX

        rowValues=[getStringValue(x,row),',',getRowText(y,row)];
    elseif isSingleY

        rowValues=[getRowText(x,row),',',getStringValue(y,row)];
    else

        rowValues=getRowText2(x,y,row);
    end
end
function rowText=getRowText(xy,row)

    rowText='';
    for i=1:length(xy)
        rowText=[rowText,getStringValue(xy,row)];%#ok<AGROW>
        if i<length(xy)
            rowText=[rowText,','];%#ok<AGROW>
        end
    end
end
function rowText=getRowText2(x,y,row)

    rowText='';
    for i=1:length(x)
        rowText=[rowText,getStringValue(x{i},row),',',getStringValue(y{i},row)];%#ok<AGROW>
        if i<length(x)
            rowText=[rowText,','];%#ok<AGROW>
        end
    end
end
function stringValue=getStringValue(value,index)
    if isnumeric(value)&&index<=length(value)
        stringValue=num2str(value(index));
    elseif isstring(value)&&index<=length(value)
        stringValue=value(index);
    else
        stringValue='NaN';
    end
end


function waveformsXY=getWaveformsXY(fileID,headerColumns,maxXYdataPoints)
    waveformsXY{length(headerColumns)}=[];
    lineCount=1;
    while lineCount<maxXYdataPoints
        line=fgetl(fileID);
        fields=parseLine(line);
        if isempty(fields)||~iscell(fields)||length(fields)<2
            return;
        end
        for column=1:length(fields)
            if~isempty(fields{column})&&~strcmpi(fields{column},'NaN')
                waveformsXY{column}=[waveformsXY{column},str2double(fields{column})];
            end
        end
        lineCount=lineCount+1;
    end
    for column=1:length(waveformsXY)
        waveformsXY{column}=waveformsXY{column}';
    end
end
function fields=parseLine(text)
    if isempty(text)
        fields={};
        return;
    end
    if~contains(text,',')
        fields=text;
        return;
    end
    bgnPtr=1;
    endPtr=1;
    fields={};
    textLength=length(text);
    while endPtr<=textLength
        endPtr=bgnPtr+1;
        if strcmp(text(bgnPtr),'"')

            while endPtr<textLength&&~strcmp(text(endPtr),'"')
                endPtr=endPtr+1;
            end
        end

        while endPtr<textLength&&~strcmp(text(endPtr),',')
            endPtr=endPtr+1;
        end

        if endPtr<textLength
            fields{end+1}=extractBetween(text,bgnPtr,endPtr-1);%#ok<AGROW>
            bgnPtr=endPtr+1;
        else
            fields{end+1}=extractBetween(text,bgnPtr,textLength);%#ok<AGROW>
            endPtr=textLength+1;
        end
        fields{end}=fields{end}{1};
    end

    for i=1:length(fields)
        fields{i}=unquoteText(fields{i});%#ok<AGROW>
    end
end


function setParamValues(simulationResults,paramValues)


    rowByRowValues={};
    for row=1:size(paramValues,1)
        rowByRowValues{end+1}=paramValues(row,:);%#ok<AGROW>
    end
    simulationResults.setParam('paramValues',rowByRowValues);
end
function setShortColumnNamesAndColumnValues(simulationResults)
    designParamsCount=simulationResults.getParamValue('designParamsCount');
    paramNames=simulationResults.getParamValue('paramNames');
    paramValues=simulationResults.getParamValue('paramValues');


    [corModelSpec_ShortVsLongValues,paramValues]=...
    getShortColumnValues_corModelSpec(paramNames,paramValues);
    simulationResults.setParam('corModelSpec_ShortVsLongValues',corModelSpec_ShortVsLongValues);
    simulationResults.setParam('paramValues',paramValues);


    [params_ShortVsLongNames,paramNames_ShortMetrics]=...
    getShortColumnNames(designParamsCount,paramNames);
    simulationResults.setParam('params_ShortVsLongNames',params_ShortVsLongNames);
    simulationResults.setParam('paramNames_ShortMetrics',paramNames_ShortMetrics);


    [params_ShortVsLongNames,paramNames_ShortMetrics]=...
    getUniqueColumnNames(designParamsCount,paramNames,paramNames_ShortMetrics,params_ShortVsLongNames);
    simulationResults.setParam('params_ShortVsLongNames',params_ShortVsLongNames);
    simulationResults.setParam('paramNames_ShortMetrics',paramNames_ShortMetrics);
end


function maxLength=getMaxLength(values,isSingle)
    if isSingle
        maxLength=length(values);
    else
        maxLength=0;
        for i=1:length(values)
            maxLength=max(maxLength,length(values{i}));
        end
    end
end
function quotedText=quoteTextWithCommas(text)
    if isnumeric(text)
        quotedText=num2str(text);
    elseif contains(text,',')
        quotedText=['"',text,'"'];
    else
        quotedText=text;
    end
end
function unquotedText=unquoteText(text)
    unquotedText=text;
    if startsWith(text,'"')
        unquotedText=unquotedText(2:end);
    end
    if endsWith(text,'"')
        unquotedText=unquotedText(1:end-1);
    end
end


function values=stringCellArray2NumericCellArray(values)
    values=...
    msblks.internal.mixedsignalanalysis.SimulationResults.stringCellArray2NumericCellArray(values);
end
function[simName,simType,nodeName,simCorner]=unpackWaveformName(waveformName)
    [simName,simType,nodeName,simCorner]=...
    msblks.internal.mixedsignalanalysis.SimulationResults.unpackWaveformName(waveformName);
end
function[shortVsLongValues,paramValuesPerCorner]=getShortColumnValues_corModelSpec(paramNames,paramValuesPerCorner)
    [shortVsLongValues,paramValuesPerCorner]=...
    msblks.internal.mixedsignalanalysis.SimulationResults.getShortColumnValues_corModelSpec(paramNames,paramValuesPerCorner);
end
function[shortVsLongNames,paramNames_ShortMetrics]=getShortColumnNames(designParamsCount,paramNames)
    [shortVsLongNames,paramNames_ShortMetrics]=...
    msblks.internal.mixedsignalanalysis.SimulationResults.getShortColumnNames(designParamsCount,paramNames);
end
function[shortVsLongNames,paramNames_ShortMetrics]=getUniqueColumnNames(designParamsCount,paramNames,paramNames_ShortMetrics,shortVsLongNames)
    [shortVsLongNames,paramNames_ShortMetrics]=...
    msblks.internal.mixedsignalanalysis.SimulationResults.getUniqueColumnNames(designParamsCount,paramNames,paramNames_ShortMetrics,shortVsLongNames);
end
