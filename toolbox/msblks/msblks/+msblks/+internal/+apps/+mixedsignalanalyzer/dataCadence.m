classdef dataCadence<handle




    properties
        db=[];
matFileName
fullPathMatFileName




nodeNames
waveforms


tableNames
caseCountPerTable
pointSweepCountPerTable
nodesPerTable
cornersPerNode
waveformTypesPerTable
normalWfTypesPerTable
waveNodesPerTable
waveTypesPerTable
isUsingdbTables


cornersPerTable
paramNamesPerTable
paramValuesPerCorner
designParamsCountPerTable
duplicateCornersPerTable

paramNamesPerTable_ShortMetrics

corModelSpecPerTable_ShortVsLongValues
paramsPerTable_ShortVsLongNames
    end

    methods

        function obj=dataCadence(fullPathMatFileName,matFileName)
            try
                obj.matFileName=matFileName;
                obj.fullPathMatFileName=fullPathMatFileName;
                if isstruct(obj.fullPathMatFileName)
                    obj.db=obj.fullPathMatFileName;
                    obj.fullPathMatFileName=[];
                else
                    obj.db=load(fullPathMatFileName);
                end
                if~msblks.internal.apps.mixedsignalanalyzer.Model.isValidCadenceMatFile(obj.db)

                    msg=message('msblks:mixedsignalanalyzer:BadCadenceAdeInfoFile',fullPathMatFileName);
                    error(msg);
                end
            catch err
                ttl=message('msblks:mixedsignalanalyzer:LoadCadenceAdeInfoFailed');
                h=errordlg(err.message,getString(ttl),'modal');
                uiwait(h)
                obj.db=false;
                return;
            end



            [obj.isUsingdbTables,obj.nodeNames,obj.waveforms,obj.waveformTypesPerTable,obj.normalWfTypesPerTable,...
            obj.tableNames,obj.caseCountPerTable,obj.pointSweepCountPerTable,obj.nodesPerTable,obj.cornersPerNode,...
            obj.cornersPerTable,obj.paramNamesPerTable,obj.paramValuesPerCorner,obj.designParamsCountPerTable,...
            obj.waveNodesPerTable,obj.waveTypesPerTable,...
            obj.duplicateCornersPerTable,obj.paramNamesPerTable_ShortMetrics,...
            obj.corModelSpecPerTable_ShortVsLongValues,obj.paramsPerTable_ShortVsLongNames]=obj.getWaveforms(false);


            if~obj.isUsingdbTables


                summation=0;
                if~isempty(obj.nodesPerTable)&&~isempty(obj.cornersPerTable)&&~isempty(obj.normalWfTypesPerTable)
                    for i=1:length(obj.tableNames)
                        summation=summation...
                        +length(obj.cornersPerTable{i})*(length(obj.nodesPerTable{i})-length(obj.waveNodesPerTable{i}))*length(obj.normalWfTypesPerTable{i})...
                        +length(obj.cornersPerTable{i})*length(obj.waveNodesPerTable{i});
                    end
                end
                if summation~=length(obj.waveforms)

                    [obj.isUsingdbTables,obj.nodeNames,obj.waveforms,obj.waveformTypesPerTable,obj.normalWfTypesPerTable,...
                    obj.tableNames,obj.caseCountPerTable,obj.pointSweepCountPerTable,obj.nodesPerTable,obj.cornersPerNode,...
                    obj.cornersPerTable,obj.paramNamesPerTable,obj.paramValuesPerCorner,obj.designParamsCountPerTable,...
                    obj.waveNodesPerTable,obj.waveTypesPerTable,...
                    obj.duplicateCornersPerTable,obj.paramNamesPerTable_ShortMetrics,...
                    obj.corModelSpecPerTable_ShortVsLongValues,obj.paramsPerTable_ShortVsLongNames]=obj.getWaveforms(true);
                end
            end

            if isempty(obj.nodeNames)&&isempty(obj.waveforms)
                uiwait(warndlg(getString(message('msblks:mixedsignalanalyzer:NoNodenamesAndWaveformsMessage'))));
            else
                if obj.isUsingdbTables

                    summation=0;
                    if~isempty(obj.nodesPerTable)&&~isempty(obj.cornersPerTable)&&~isempty(obj.normalWfTypesPerTable)
                        for i=1:length(obj.tableNames)
                            summation=summation...
                            +length(obj.cornersPerTable{i})*length(obj.nodesPerTable{i})*length(obj.normalWfTypesPerTable{i})...
                            +length(obj.cornersPerTable{i})*length(obj.waveNodesPerTable{i});
                        end
                    end
                end
                if summation~=length(obj.waveforms)
                    uiwait(warndlg(getString(message('msblks:mixedsignalanalyzer:MismatchedNodenamesAndWaveformsMessage',...
                    summation,length(obj.waveforms)))));
                end
            end
            if~isempty(obj.duplicateCornersPerTable)
                duplicateCornersCount=0;
                for i=1:length(obj.duplicateCornersPerTable)
                    if~isempty(obj.duplicateCornersPerTable{i})
                        duplicateCornersCount=duplicateCornersCount+length(obj.duplicateCornersPerTable{i});
                        msg=getString(message('msblks:mixedsignalanalyzer:DuplicateCornersSummary',...
                        obj.tableNames{i},num2str(length(obj.duplicateCornersPerTable{i}))));
                        disp(' ');
                        disp(msg);
                        for j=1:length(obj.duplicateCornersPerTable{i})
                            obj.duplicateCornersPerTable{i}{j}=strrep(obj.duplicateCornersPerTable{i}{j},'<',', ');
                            obj.duplicateCornersPerTable{i}{j}=strrep(obj.duplicateCornersPerTable{i}{j},'>',' ');
                            msg=[num2str(j),'.'];
                            for k=1:length(obj.duplicateCornersPerTable{i}{j})
                                msg=[msg,'  {','''',obj.duplicateCornersPerTable{i}{j}{k},'''','}'];%#ok<AGROW>
                            end
                            disp(msg);
                        end
                    end
                end
                if duplicateCornersCount>0
                    uiwait(warndlg(getString(message('msblks:mixedsignalanalyzer:DuplicateCornersMessage'))));
                end
            end



        end


        function[isUsingdbTables,nodeNames,waveforms,waveformTypesPerTable,normalWfTypesPerTable,...
            tableNames,caseCountPerTable,pointSweepCountPerTable,nodesPerTable,cornersPerNode,...
            cornersPerTable,paramNamesPerTable,paramValuesPerCorner,designParamsCountPerTable,...
            waveNodesPerTable,waveTypesPerTable,...
            duplicateCornersPerTable,paramNamesPerTable_ShortMetrics,...
            corModelSpecPerTable_ShortVsLongValues,paramsPerTable_ShortVsLongNames]=getWaveforms(obj,isUsingdbTables)
            nodeNames=[];
            waveforms=[];
            waveformTypesPerTable=[];
            normalWfTypesPerTable=[];
            waveformNodesPerTable=[];
            waveNodesPerTable=[];
            waveTypesPerTable=[];
            tableNames=[];
            caseCountPerTable=[];
            caseCountPerTable2=[];
            pointSweepCountPerTable=[];
            pointSweepCountPerTable2=[];
            nodesPerTable=[];
            cornersPerNode=[];
            metricNamesPerTable=[];
            cornersPerMetricValue=[];
            metricValuesPerCorner=[];
            cornersPerTable=[];
            paramNamesPerTable=[];
            paramValuesPerCorner=[];
            designParamsCountPerTable=[];
            duplicateCornersPerTable=[];
            dbFields=fieldnames(obj.db);

            if~isempty(obj.db)&&any(contains(dbFields,'simDBS'))&&~isempty(obj.db.simDBS)

                fields=fieldnames(obj.db.simDBS);
                if any(contains(fields,'no'))

                    count=0;
                    for table=1:length(obj.db.simDBS.no)
                        if~isempty(obj.db.simDBS.no{1,table})
                            fields=fieldnames(obj.db.simDBS.no{1,table});
                            if any(contains(fields,'adeHistory'))

                                count=count+1;
                            end
                        end
                    end

                    tableNames{count}=[];
                    count=0;
                    for table=1:length(obj.db.simDBS.no)
                        if~isempty(obj.db.simDBS.no{1,table})
                            fields=fieldnames(obj.db.simDBS.no{1,table});
                            if any(contains(fields,'adeHistory'))

                                count=count+1;
                                tableNames{count}=obj.db.simDBS.no{1,table}.adeHistory;
                                if any(contains(fields,'adeTest'))

                                    tableNames{count}=[tableNames{count},', ',obj.db.simDBS.no{1,table}.adeTest];
                                end
                            end
                        end
                    end
                elseif any(contains(fields,'adeHistory'))

                    tableNames{end+1}=obj.db.simDBS.adeHistory;
                    if any(contains(fields,'adeTest'))

                        tableNames{end}=[tableNames{end},', ',obj.db.simDBS.adeTest];
                    end
                end
            end
            if~isempty(obj.db)&&any(contains(dbFields,'wfOutput'))&&~isempty(obj.db.wfOutput)

                if iscell(obj.db.wfOutput)
                    wfOutputFields=[];
                    tableCount=1;
                else
                    wfOutputFields=fieldnames(obj.db.wfOutput);
                    tableCount=length(obj.db.wfOutput);
                end
                if tableCount>0
                    waveformNodesPerTable{tableCount}=[];
                    waveNodesPerTable{tableCount}=[];
                    for table=1:tableCount
                        waveformNodesPerTable{table}=[];
                        if tableCount==1||any(contains(wfOutputFields,'output'))
                            if~isempty(wfOutputFields)&&any(contains(wfOutputFields,'output'))
                                tableData=obj.db.wfOutput(table).output;
                                if~isempty(tableData)
                                    fields=fieldnames(tableData);
                                    if any(contains(fields,'no'))
                                        tableData=tableData.no;
                                    end
                                end
                            else
                                tableData=obj.db.wfOutput;
                            end
                        end

                        count=0;
                        for nodeNameIndex=1:length(tableData)
                            nodeName=tableData{nodeNameIndex};
                            if iscell(nodeName)
                                nodeName=nodeName{1};
                            end
                            if~isempty(nodeName)
                                count=count+1;
                            end
                        end

                        if count==0
                            waveformNodesPerTable{table}=[];
                        else
                            waveformNodesPerTable{table}{count}=[];
                            count=0;
                            for nodeNameIndex=1:length(tableData)
                                nodeName=tableData{nodeNameIndex};
                                if iscell(nodeName)
                                    nodeName=nodeName{1};
                                end
                                if~isempty(nodeName)
                                    count=count+1;
                                    waveformNodesPerTable{table}{count}=nodeName;
                                end
                            end
                        end
                    end
                end
            end







            if~isUsingdbTables&&~isempty(obj.db)&&any(contains(dbFields,'signalTables'))&&~isempty(obj.db.signalTables)

                signalTablesFields=fieldnames(obj.db.signalTables);
                if any(contains(signalTablesFields,'no'))
                    tableCount=length(obj.db.signalTables.no);
                else
                    tableCount=1;
                end
                useDataPointForCorner{tableCount}=false;
                for table=1:tableCount
                    if~isempty(tableNames)
                        tableName=tableNames{table};
                    else
                        tableName=['Table',num2str(table)];
                        tableNames{end+1}=tableName;%#ok<AGROW> Append table name (characters) to cell array.
                    end
                    casesInTable=[];
                    pointSweepsInTable=[];
                    nodesInTable=[];
                    cornersInNodes=[];

                    useDataPointForCorner{table}=true;
                    if tableCount==1||any(contains(signalTablesFields,'no'))&&~isempty(obj.db.signalTables.no{1,table})
                        if any(contains(signalTablesFields,'no'))
                            tableData=obj.db.signalTables.no{1,table};
                            fields=fieldnames(tableData);
                        else
                            tableData=obj.db.signalTables;
                            fields=signalTablesFields;
                        end
                        if any(contains(fields,'Output'))&&...
                            any(contains(fields,'Result'))&&...
                            any(contains(fields,'Corner'))
                            output=tableData.Output;
                            result=tableData.Result;
                            corner=tableData.Corner;
                            if any(contains(fields,'DataPoint'))

                                dataPoint=tableData.DataPoint;
                                for i=1:length(dataPoint)
                                    if~any(casesInTable==dataPoint(i))
                                        casesInTable(end+1)=dataPoint(i);%#ok<AGROW> 
                                    end
                                end
                            end
                            if any(contains(fields,'Point'))

                                point=tableData.Point;
                                for i=1:length(point)
                                    if~any(pointSweepsInTable==point(i))
                                        pointSweepsInTable(end+1)=point(i);%#ok<AGROW> 
                                    end
                                end
                            end















                            useDataPointForCorner{table}=true;
                            if any(contains(fields,'DataPoint'))
                                dataPoint=tableData.DataPoint;
                                if~isempty(dataPoint)
                                    for j=1:max(length(corner),length(dataPoint))
                                        corner{j}=[corner{j},'<DataPoint>',num2str(dataPoint(j))];
                                    end
                                end
                            end
                            if length(output)==length(result)&&length(output)==length(corner)

                                for row=1:length(result)
                                    if iscell(result)&&strcmpi(result{row},'wave')||...
                                        ~iscell(result)&&strcmpi(result(row),'wave')
                                        if isempty(waveNodesPerTable{table})
                                            waveNodesPerTable{table}{1}=output{row};%#ok<AGROW> 1st (unique) "intermediate waveform" node name.
                                        elseif~any(contains(waveNodesPerTable{table},output{row}))
                                            waveNodesPerTable{table}{end+1}=output{row};%#ok<AGROW> Nth unique "intermediate waveform" node name
                                        end
                                    end
                                end

                                for row=1:length(output)
                                    node=output{row};
                                    crnr=corner(row);
                                    flags=ismember(nodesInTable,node);
                                    if~isempty(waveformNodesPerTable)&&...
                                        length(waveformNodesPerTable)>=table&&...
                                        ~isempty(waveformNodesPerTable{table})
                                        if~contains(waveformNodesPerTable{table},node)
                                            continue;
                                        end
                                    end
                                    if~any(flags)

                                        nodesInTable{end+1}=node;%#ok<AGROW>
                                        cornersInNodes{end+1}=crnr;%#ok<AGROW>
                                    else
                                        for i=1:length(flags)
                                            if flags(i)

                                                if~any(ismember(cornersInNodes{i},crnr))

                                                    cornersInNodes{i}=[cornersInNodes{i},crnr];%#ok<AGROW>
                                                end
                                                break;
                                            end
                                        end
                                    end

                                    nodeNames{end+1}=[tableName,', ',node,', ',crnr];%#ok<AGROW>
                                end
                            end
                        end
                    end
                    caseCountPerTable{end+1}=length(casesInTable);%#ok<AGROW>
                    pointSweepCountPerTable{end+1}=length(pointSweepsInTable);%#ok<AGROW> 
                    nodesPerTable{end+1}=nodesInTable;%#ok<AGROW>
                    cornersPerNode{end+1}=cornersInNodes;%#ok<AGROW>
                end
            end





            exprTables=[];
            if~isempty(obj.db)&&any(contains(dbFields,'exprTables'))&&~isempty(obj.db.exprTables)

                exprTablesFields=fieldnames(obj.db.exprTables);
                if any(contains(exprTablesFields,'no'))
                    tableCount=length(obj.db.exprTables.no);
                else
                    tableCount=1;
                end
                exprTables{tableCount}=[];
                useDataPointForCorner{tableCount}=false;
                for table=1:tableCount
                    casesInTable=[];
                    pointSweepsInTable=[];
                    measInTable=[];
                    cornersInMeas=[];
                    cornerMeasVal=[];

                    useDataPointForCorner{table}=true;
                    if tableCount==1||any(contains(exprTablesFields,'no'))&&~isempty(obj.db.exprTables.no{1,table})
                        if any(contains(exprTablesFields,'no'))
                            tableData=obj.db.exprTables.no{1,table};
                            fields=fieldnames(tableData);
                        else
                            tableData=obj.db.exprTables;
                            fields=exprTablesFields;
                        end
                        exprTables{table}=tableData;
                        if any(contains(fields,'Output'))&&...
                            any(contains(fields,'Result'))&&...
                            any(contains(fields,'Corner'))
                            output=tableData.Output;
                            result=tableData.Result;
                            corner=tableData.Corner;
                            if any(contains(fields,'DataPoint'))

                                dataPoint=tableData.DataPoint;
                                for i=1:length(dataPoint)
                                    if~any(casesInTable==dataPoint(i))
                                        casesInTable(end+1)=dataPoint(i);%#ok<AGROW> 
                                    end
                                end
                            end
                            if any(contains(fields,'Point'))

                                point=tableData.Point;
                                for i=1:length(point)
                                    if~any(pointSweepsInTable==point(i))
                                        pointSweepsInTable(end+1)=point(i);%#ok<AGROW> 
                                    end
                                end
                            end




















                            useDataPointForCorner{table}=true;
                            if any(contains(fields,'DataPoint'))
                                dataPoint=tableData.DataPoint;
                                if~isempty(dataPoint)
                                    for j=1:max(length(corner),length(dataPoint))
                                        corner{j}=[corner{j},'<DataPoint>',num2str(dataPoint(j))];
                                    end
                                end
                            end
                            if length(output)==length(result)&&...
                                length(output)==length(corner)
                                for row=1:length(output)
                                    if iscell(output)
                                        node=output{row};
                                    else
                                        node=output(row);
                                    end
                                    if iscell(corner)
                                        crnr=corner{row};
                                    else
                                        crnr=corner(row);
                                    end
                                    if iscell(result)
                                        meas=result{row};
                                    else
                                        meas=result(row);
                                    end
                                    if islogical(meas)
                                        if meas
                                            meas=1;
                                        else
                                            meas=0;
                                        end
                                    end
                                    if~isnumeric(meas)
                                        if strcmpi(meas,'wave')
                                            continue;
                                        end
                                        meas=NaN;
                                    end
                                    flags=ismember(measInTable,node);
                                    if~any(flags)

                                        measInTable{end+1}=node;%#ok<AGROW>
                                        cornersInMeas{end+1}={crnr};%#ok<AGROW>
                                        cornerMeasVal{end+1}=meas;%#ok<AGROW>
                                    else
                                        for i=1:length(flags)
                                            if flags(i)

                                                if~any(ismember(cornersInMeas{i},crnr))

                                                    cornersInMeas{i}=[cornersInMeas{i},{crnr}];%#ok<AGROW>
                                                    cornerMeasVal{i}=[cornerMeasVal{i},meas];%#ok<AGROW>
                                                end
                                                break;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    caseCountPerTable2{end+1}=length(casesInTable);%#ok<AGROW>
                    pointSweepCountPerTable2{end+1}=length(pointSweepsInTable);%#ok<AGROW> 
                    metricNamesPerTable{end+1}=measInTable;%#ok<AGROW>
                    cornersPerMetricValue{end+1}=cornersInMeas;%#ok<AGROW>
                    metricValuesPerCorner{end+1}=cornerMeasVal;%#ok<AGROW>
                end
            elseif~isUsingdbTables&&~isempty(caseCountPerTable)

                for table=1:tableCount
                    exprTables{end+1}=[];%#ok<AGROW>
                    metricNamesPerTable{end+1}=[];%#ok<AGROW>
                    cornersPerMetricValue{end+1}=[];%#ok<AGROW>
                    metricValuesPerCorner{end+1}=[];%#ok<AGROW>
                end
            end
            if~isUsingdbTables&&isempty(caseCountPerTable)&&~isempty(exprTables)

                for table=1:tableCount
                    caseCountPerTable{end+1}=[];%#ok<AGROW>
                    pointSweepCountPerTable{end+1}=[];%#ok<AGROW> 
                    nodesPerTable{end+1}=[];%#ok<AGROW>
                    cornersPerNode{end+1}=cornersPerMetricValue{table};%#ok<AGROW>
                end
            elseif~isUsingdbTables&&~isempty(caseCountPerTable)&&~isempty(exprTables)

                for table=1:tableCount
                    if caseCountPerTable{table}==0&&isempty(cornersPerNode{table})
                        cornersPerNode{table}=cornersPerMetricValue{table};%#ok<AGROW>
                    end
                end
            end







            if~isempty(obj.db)&&any(contains(dbFields,'dbTables'))&&~isempty(obj.db.dbTables)&&...
                isempty(nodesPerTable)&&...
                isempty(cornersPerNode)


                isUsingdbTables=true;


                containsSignalTables=any(contains(dbFields,'signalTables'));


                dbTablesFields=fieldnames(obj.db.dbTables);
                if any(contains(dbTablesFields,'no'))
                    tableCount=length(obj.db.dbTables.no);
                else
                    tableCount=1;
                end
                useDataPointForCorner{tableCount}=false;
                for table=1:tableCount
                    if~isempty(tableNames)
                        tableName=tableNames{table};
                    else
                        tableName=['Table',num2str(table)];
                        tableNames{end+1}=tableName;%#ok<AGROW> Append table name (characters) to cell array.
                    end
                    casesInTable=[];
                    pointSweepsInTable=[];
                    nodesInTable=[];
                    cornersInNodes=[];
                    if~isempty(exprTables)&&~isempty(exprTables{table})&&...
                        ~isempty(metricNamesPerTable)&&~isempty(metricNamesPerTable{table})&&...
                        ~isempty(cornersPerMetricValue)&&~isempty(cornersPerMetricValue{table})&&...
                        ~isempty(metricValuesPerCorner)&&~isempty(metricValuesPerCorner{table})

                        exprTableData=exprTables{table};



                    else

                        exprTableData=[];
                        measInTable=[];
                        cornersInMeas=[];
                        cornerMeasVal=[];
                    end

                    useDataPointForCorner{table}=true;
                    if tableCount==1||any(contains(dbTablesFields,'no'))&&~isempty(obj.db.dbTables.no{1,table})
                        if any(contains(dbTablesFields,'no'))
                            tableData=obj.db.dbTables.no{1,table};
                            fields=fieldnames(tableData);
                        else
                            tableData=obj.db.dbTables;
                            fields=dbTablesFields;
                        end
                        if~isempty(exprTableData)

                            for exprTableRow=1:size(exprTableData,1)
                                for dbTableRow=1:size(tableData,1)
                                    if isequal(exprTableData(exprTableRow,1:end),tableData(dbTableRow,1:end))
                                        tableData(dbTableRow,:)=[];
                                        break;
                                    end
                                end
                            end
                        end
                        if any(contains(fields,'Output'))&&...
                            any(contains(fields,'Result'))&&...
                            any(contains(fields,'Corner'))
                            output=tableData.Output;
                            result=tableData.Result;
                            corner=tableData.Corner;
                            if any(contains(fields,'DataPoint'))

                                dataPoint=tableData.DataPoint;
                                for i=1:length(dataPoint)
                                    if~any(casesInTable==dataPoint(i))
                                        casesInTable(end+1)=dataPoint(i);%#ok<AGROW> 
                                    end
                                end
                            end
                            if any(contains(fields,'Point'))

                                point=tableData.Point;
                                for i=1:length(point)
                                    if~any(pointSweepsInTable==point(i))
                                        pointSweepsInTable(end+1)=point(i);%#ok<AGROW> 
                                    end
                                end
                            end















                            useDataPointForCorner{table}=true;
                            if any(contains(fields,'DataPoint'))
                                dataPoint=tableData.DataPoint;
                                if~isempty(dataPoint)
                                    for j=1:max(length(corner),length(dataPoint))
                                        corner{j}=[corner{j},'<DataPoint>',num2str(dataPoint(j))];
                                    end
                                end
                            end
                            if length(output)==length(result)&&length(output)==length(corner)


                                if containsSignalTables
                                    for row=1:length(result)
                                        if iscell(result)&&strcmpi(result{row},'wave')||...
                                            ~iscell(result)&&strcmpi(result(row),'wave')
                                            if isempty(waveNodesPerTable{table})
                                                waveNodesPerTable{table}{1}=output{row};%#ok<AGROW> 1st (unique) "intermediate waveform" node name.
                                            elseif~any(contains(waveNodesPerTable{table},output{row}))
                                                waveNodesPerTable{table}{end+1}=output{row};%#ok<AGROW> Nth unique "intermediate waveform" node name
                                            end
                                        end
                                    end
                                end

                                for row=1:length(output)

                                    if startsWith(output(row),'/')||~isempty(exprTableData)
                                        node=output{row};
                                        crnr=corner(row);
                                        flags=ismember(nodesInTable,node);
                                        if~isempty(waveformNodesPerTable)&&...
                                            length(waveformNodesPerTable)>=table&&...
                                            ~isempty(waveformNodesPerTable{table})
                                            if~contains(waveformNodesPerTable{table},node)
                                                continue;
                                            end
                                        end
                                        if~any(flags)

                                            nodesInTable{end+1}=node;%#ok<AGROW>
                                            cornersInNodes{end+1}=crnr;%#ok<AGROW>
                                        else
                                            for i=1:length(flags)
                                                if flags(i)

                                                    if~any(ismember(cornersInNodes{i},crnr))

                                                        cornersInNodes{i}=[cornersInNodes{i},crnr];%#ok<AGROW>
                                                    end
                                                    break;
                                                end
                                            end
                                        end

                                        nodeNames{end+1}=[tableName,', ',node,', ',crnr];%#ok<AGROW>

                                    else
                                        if iscell(output)
                                            node=output{row};
                                        else
                                            node=output(row);
                                        end
                                        if iscell(corner)
                                            crnr=corner{row};
                                        else
                                            crnr=corner(row);
                                        end
                                        if iscell(result)
                                            meas=result{row};
                                        else
                                            meas=result(row);
                                        end
                                        if islogical(meas)
                                            if meas
                                                meas=1;
                                            else
                                                meas=0;
                                            end
                                        end
                                        if~isnumeric(meas)
                                            if strcmpi(meas,'wave')
                                                continue;
                                            end
                                            meas=NaN;
                                        end
                                        flags=ismember(measInTable,node);
                                        if~any(flags)

                                            measInTable{end+1}=node;%#ok<AGROW>
                                            cornersInMeas{end+1}={crnr};%#ok<AGROW>
                                            cornerMeasVal{end+1}=meas;%#ok<AGROW>
                                        else
                                            for i=1:length(flags)
                                                if flags(i)

                                                    if~any(ismember(cornersInMeas{i},crnr))

                                                        cornersInMeas{i}=[cornersInMeas{i},{crnr}];%#ok<AGROW>
                                                        cornerMeasVal{i}=[cornerMeasVal{i},meas];%#ok<AGROW>
                                                    end
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    caseCountPerTable{end+1}=length(casesInTable);%#ok<AGROW>
                    pointSweepCountPerTable{end+1}=length(pointSweepsInTable);%#ok<AGROW> 
                    nodesPerTable{end+1}=nodesInTable;%#ok<AGROW>
                    cornersPerNode{end+1}=cornersInNodes;%#ok<AGROW>
                    if isempty(exprTables)

                        metricNamesPerTable{end+1}=measInTable;%#ok<AGROW>
                        cornersPerMetricValue{end+1}=cornersInMeas;%#ok<AGROW>
                        metricValuesPerCorner{end+1}=cornerMeasVal;%#ok<AGROW>
                    end
                end
            end

            hasCornerStruct=~isempty(obj.db)&&any(contains(dbFields,'totalCorners'))&&~isempty(obj.db.totalCorners);
            hasDataPtStruct=~isempty(obj.db)&&any(contains(dbFields,'paramConditionTable'))&&~isempty(obj.db.paramConditionTable);
            if hasCornerStruct||hasDataPtStruct




                cornerFields=[];
                dataPtFields=[];
                tableCount=1;
                if hasCornerStruct
                    cornerFields=fieldnames(obj.db.totalCorners);
                    if any(contains(cornerFields,'no'))
                        tableCount=length(obj.db.totalCorners.no);
                    end
                end
                if hasDataPtStruct
                    dataPtFields=fieldnames(obj.db.paramConditionTable);
                    if any(contains(dataPtFields,'no'))
                        tableCount=length(obj.db.paramConditionTable.no);
                    end
                end
                for table=1:tableCount
                    paramsInTable=[];
                    cornersInTable=[];
                    paramsInCorners=[];

                    if hasDataPtStruct
                        firstColumnName='DataPoint';
                        fields=dataPtFields;
                        if any(contains(fields,'no'))
                            tableData=obj.db.paramConditionTable.no{table};
                        else
                            tableData=obj.db.paramConditionTable;
                        end
                    else
                        firstColumnName='Corner';
                        fields=cornerFields;
                        if any(contains(fields,'no'))
                            tableData=obj.db.totalCorners.no{table};
                        else
                            tableData=obj.db.totalCorners;
                        end
                    end
                    if~isempty(fields)&&~isempty(tableData)
                        tableColumnNames=tableData.Properties.VariableNames;
                        waveformDBfields=[];


                        if~isempty(tableColumnNames)&&strcmpi(tableColumnNames{1},firstColumnName)&&...
                            ~isempty(obj.db)&&any(contains(dbFields,'waveformDB'))&&~isempty(obj.db.waveformDB)

                            waveformDBfields=fieldnames(obj.db.waveformDB);
                            if any(contains(waveformDBfields,'waveData'))
                                waveformTableCount=length(obj.db.waveformDB);
                            else
                                waveformTableCount=1;
                            end
                            if waveformTableCount~=tableCount
                                waveformDBfields=[];
                            elseif any(contains(waveformDBfields,'waveData'))
                                waveformTableData=obj.db.waveformDB(table);
                                if~isempty(waveformTableData)&&~isempty(waveformTableData.waveData)
                                    waveformDBfields=fieldnames(waveformTableData.waveData);
                                    if any(contains(waveformDBfields,'no'))
                                        waveformDBfields=fieldnames(waveformTableData.waveData.no);
                                    end
                                end
                            end
                        end

                        if~isempty(waveformDBfields)

                            isWaveformWithSimParams=false;
                            for simParamIndex=1:length(tableColumnNames)
                                if any(strcmp(waveformDBfields,tableColumnNames{simParamIndex}))
                                    isWaveformWithSimParams=true;
                                    break;
                                end
                            end
                            if isWaveformWithSimParams

                                uniqueValuesCount=zeros(1,width(tableData));
                                for column=1:width(tableData)
                                    uniqueValues={};
                                    for row=1:height(tableData)
                                        if isnumeric(tableData{row,column})

                                            if row==1||isempty(find([uniqueValues{:}]==tableData{row,column},1))
                                                uniqueValues{end+1}=tableData{row,column};%#ok<AGROW> Add unique value.
                                            end
                                        elseif iscell(tableData{row,column})&&ischar(tableData{row,column}{1})

                                            if~any(contains(uniqueValues,tableData{row,column}{1}))
                                                uniqueValues{end+1}=tableData{row,column}{1};%#ok<AGROW> Add unique value.
                                            end
                                        end
                                    end
                                    uniqueValuesCount(column)=length(uniqueValues);
                                end

                                for simParamIndex=2:length(tableColumnNames)
                                    if~any(strcmp(waveformDBfields,tableColumnNames{simParamIndex}))&&uniqueValuesCount(simParamIndex)<2
                                        tableData.(tableColumnNames{simParamIndex})=[];
                                    end
                                end
                                tableColumnNames=tableData.Properties.VariableNames;
                            end
                        end

                        for row=1:height(tableData)
                            for column=1:width(tableData)
                                if iscell(tableData{row,column})&&ischar(tableData{row,column}{1})
                                    tableData{row,column}{1}=replace(tableData{row,column}{1},'"','');
                                end
                            end
                        end
                        if~isempty(cornersPerNode{table})&&~isempty(tableColumnNames)&&strcmpi(tableColumnNames{1},firstColumnName)
                            corner=cornersPerNode{table}{1};
                            paramsInTable=tableColumnNames(2:end);
                            for row=1:max(height(tableData),length(corner))
                                if useDataPointForCorner{table}

                                    if row>length(corner)
                                        break;
                                    end
                                    cornerTemp=corner{row};
                                else
                                    if row>height(tableData)
                                        break;
                                    end
                                    cornerTemp=tableData{row,1};
                                end
                                dbTableContainsCorner=false;
                                for nodeIndex=1:length(cornersPerNode{table})
                                    if any(strcmpi(cornersPerNode{table}{nodeIndex},cornerTemp))

                                        dbTableContainsCorner=true;
                                        break;
                                    end
                                end
                                if dbTableContainsCorner
                                    if~any(strcmpi(cornersInTable,cornerTemp))
                                        cornersInTable{end+1}=cornerTemp;%#ok<AGROW>
                                        for column=2:width(tableData)
                                            if column==2
                                                paramsInCorners{end+1}=tableData{length(cornersInTable),2};%#ok<AGROW>
                                            else
                                                paramsInCorners{end}=[paramsInCorners{end},tableData{length(cornersInTable),column}];
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else
                        cornersInTable{1}={'Nominal<DataPoint>1'};
                    end
                    paramNamesPerTable{end+1}=paramsInTable;%#ok<AGROW>
                    cornersPerTable{end+1}=cornersInTable;%#ok<AGROW>
                    paramValuesPerCorner{end+1}=paramsInCorners;%#ok<AGROW>
                    designParamsCountPerTable{end+1}=length(paramsInTable);%#ok<AGROW>
                end

                if~isempty(metricNamesPerTable)&&~isempty(cornersPerMetricValue)&&~isempty(metricValuesPerCorner)
                    for table=1:length(metricNamesPerTable)
                        for metricName=1:length(metricNamesPerTable{table})

                            paramNamesPerTable{table}=[paramNamesPerTable{table},metricNamesPerTable{table}{metricName}];%#ok<AGROW>
                        end
                    end
                    for table=1:length(cornersPerTable)
                        for corner=1:length(cornersPerTable{table})

                            foundMatchingCorner=false;
                            for cornersPerMetric=1:length(cornersPerMetricValue{table})
                                for metricCorner=1:length(cornersPerMetricValue{table}{cornersPerMetric})
                                    if strcmpi(cornersPerMetricValue{table}{cornersPerMetric}{metricCorner},...
                                        cornersPerTable{table}{corner})
                                        for measurement=1:length(metricNamesPerTable{table})

                                            if~isempty(paramValuesPerCorner{table})
                                                paramValuesPerCorner{table}{corner}=...
                                                [paramValuesPerCorner{table}{corner},...
                                                metricValuesPerCorner{table}{measurement}(metricCorner)];%#ok<AGROW>
                                            else
                                                paramValuesPerCorner{table}{corner}=...
                                                {metricValuesPerCorner{table}{measurement}(metricCorner)};%#ok<AGROW>
                                            end
                                        end
                                        foundMatchingCorner=true;
                                        break;
                                    end
                                end
                                if foundMatchingCorner
                                    break;
                                end
                            end
                        end
                    end
                end
            else
                for table=1:tableCount
                    paramNamesPerTable{end+1}=[];%#ok<AGROW>
                    cornersPerTable{end+1}={'Nominal'};%#ok<AGROW>
                    paramValuesPerCorner{end+1}=[];%#ok<AGROW>
                    designParamsCountPerTable{end+1}=0;%#ok<AGROW>
                end
            end

            if~isempty(obj.db)&&any(contains(dbFields,'wfCorners'))&&~isempty(obj.db.wfCorners)

                tableCount=length(cornersPerTable);
                for table=1:tableCount
                    if useDataPointForCorner{table}

                        continue;
                    end

                    if tableCount==1
                        try
                            orderedCorners=obj.db.wfCorners(table).corners.no;
                        catch
                            orderedCorners=obj.db.wfCorners;
                        end
                    elseif isempty(obj.db.wfCorners(table).corners)
                        orderedCorners=[];
                    else
                        orderedCorners=obj.db.wfCorners(table).corners.no;
                    end

                    for corner=length(orderedCorners):-1:1
                        if isempty(orderedCorners{corner})
                            orderedCorners(corner)=[];
                        end
                    end

                    for corner=length(orderedCorners):-1:2
                        if strcmp(orderedCorners{corner},orderedCorners{corner-1})
                            orderedCorners(corner)=[];
                        end
                    end

                    isSame=true;
                    if length(orderedCorners)~=length(cornersPerTable{table})
                        isSame=false;
                    else
                        for i=1:length(orderedCorners)
                            if iscell(cornersPerTable{table}{i})
                                if~strcmp(orderedCorners{i},cornersPerTable{table}{i}{1})
                                    isSame=false;
                                    break;
                                end
                            else
                                if~strcmp(orderedCorners{i},cornersPerTable{table}{i})
                                    isSame=false;
                                    break;
                                end
                            end
                        end
                    end
                    if isSame
                        continue;
                    end

                    for i=1:length(orderedCorners)
                        for j=1:length(cornersPerTable{table})
                            if strcmp(orderedCorners{i},cornersPerTable{table}{j}{1})
                                if i~=j
                                    temp=cornersPerTable{table}{i};
                                    cornersPerTable{table}{i}=cornersPerTable{table}{j};%#ok<AGROW>
                                    cornersPerTable{table}{j}=temp;%#ok<AGROW>
                                    temp=paramValuesPerCorner{table}{i};
                                    paramValuesPerCorner{table}{i}=paramValuesPerCorner{table}{j};%#ok<AGROW>
                                    paramValuesPerCorner{table}{j}=temp;%#ok<AGROW>
                                end
                                break;
                            end
                        end
                    end
                end
            end

            if~isempty(obj.db)&&any(contains(dbFields,'waveformDB'))&&~isempty(obj.db.waveformDB)

                waveformDBfields=fieldnames(obj.db.waveformDB);
                if any(contains(waveformDBfields,'waveData'))
                    tableCount=length(obj.db.waveformDB);
                else
                    tableCount=1;
                end
                if tableCount>0
                    waveformTypesPerTable{tableCount}=[];
                    normalWfTypesPerTable{tableCount}=[];
                    duplicateCornersPerTable{tableCount}=[];
                    waveTypesPerTable{tableCount}=[];
                end
                count=0;
                for table=1:tableCount
                    waveformTypes=[];
                    normalWfTypes=[];
                    if isempty(waveNodesPerTable{table})
                        waveTypes=[];
                    else
                        waveTypes=[];
                        waveTypes{length(waveNodesPerTable{table})}=[];%#ok<AGROW> % g2741244: Pre-allocate "intermediate waveform" types in this table.
                    end
                    if tableCount==1||any(contains(waveformDBfields,'waveData'))&&~isempty(obj.db.waveformDB(table).waveData)

                        if any(contains(waveformDBfields,'waveData'))
                            tableData=obj.db.waveformDB(table);
                            fields=fieldnames(tableData.waveData);
                        else
                            tableData=obj.db.waveformDB;
                            fields=fieldnames(tableData);
                        end
                        if any(contains(fields,'no'))
                            tableData=tableData.waveData.no;
                            fields=fieldnames(tableData);
                        end


                        simParamsCount=0;
                        corModelSpecIndex=0;
                        for simParamIndex=1:designParamsCountPerTable{table}
                            if any(strcmp(fields,paramNamesPerTable{table}{simParamIndex}))

                                simParamsCount=simParamsCount+1;
                            elseif strcmpi(paramNamesPerTable{table}{simParamIndex},'corModelSpec')

                                simParamsCount=simParamsCount+1;
                                corModelSpecIndex=simParamIndex;
                            end
                        end
                        noParamsInWaveformDB=simParamsCount==0||simParamsCount==1&&corModelSpecIndex~=0;

                        if~noParamsInWaveformDB&&simParamsCount<=designParamsCountPerTable{table}
                            designParamsTotal=designParamsCountPerTable{table};


                            cornersWithSameParamValuesCount=0;
                            cornersWithSameParamValuesNames=[];
                            if~isempty(cornersPerTable{table})
                                cornersWithSameParamValuesCount(length(cornersPerTable{table}))=0;%#ok<AGROW>
                                cornersWithSameParamValuesNames{length(cornersPerTable{table})}=[];%#ok<AGROW>
                            end
                            for cornerIndex1=1:length(cornersPerTable{table})-1

                                indices=find(cornersWithSameParamValuesCount);
                                if~isempty(indices)
                                    isExistingDuplicate=false;
                                    for idx=1:length(indices)
                                        index=indices(idx);
                                        if any(strcmp(cornersWithSameParamValuesNames{index},cornersPerTable{table}{cornerIndex1}))
                                            isExistingDuplicate=true;
                                            break;
                                        end
                                    end
                                    if isExistingDuplicate
                                        continue;
                                    end
                                end

                                cornerParamValues1=paramValuesPerCorner{table}{cornerIndex1};
                                for cornerIndex2=cornerIndex1+1:length(cornersPerTable{table})
                                    cornerParamValues2=paramValuesPerCorner{table}{cornerIndex2};
                                    isSameParamValues=true;
                                    for cornerParamIndex=1:designParamsTotal
                                        if~strcmpi(cornerParamValues1{cornerParamIndex},cornerParamValues2{cornerParamIndex})
                                            isSameParamValues=false;
                                            break;
                                        end
                                    end
                                    if isSameParamValues

                                        cornersWithSameParamValuesCount(cornerIndex1)=cornersWithSameParamValuesCount(cornerIndex1)+1;%#ok<AGROW>
                                        if isempty(cornersWithSameParamValuesNames{cornerIndex1})
                                            cornersWithSameParamValuesNames{cornerIndex1}{1}=cornersPerTable{table}{cornerIndex1};%#ok<AGROW> 1st corner.
                                        end
                                        cornersWithSameParamValuesNames{cornerIndex1}{end+1}=cornersPerTable{table}{cornerIndex2};%#ok<AGROW> Subsequent "duplicate" corner.
                                    end
                                end
                            end

                            indices=find(cornersWithSameParamValuesCount);
                            if isempty(indices)

                                duplicateCornersPerTable{table}=[];%#ok<AGROW>
                            else








                                duplicateCornerSets{length(indices)}=[];%#ok<AGROW> Pre-allocate cell array to store "duplicate" corners for current table.
                                for idx=1:length(indices)
                                    index=indices(idx);
                                    duplicateCornerSets{idx}=cornersWithSameParamValuesNames{index};
                                end
                                duplicateCornersPerTable{table}=duplicateCornerSets;%#ok<AGROW> Store "duplicate" corners for current table.
                            end

                            tableRow=1;
                            tableDataNew=tableData(length(tableData));
                            tableDataNew(length(tableData))=tableData(length(tableData));
                            tableDataNew(length(tableData)).corner='';
                            for cornerIndex=1:length(cornersPerTable{table})

                                cornerName=cornersPerTable{table}{cornerIndex};
                                cornerParamValues=paramValuesPerCorner{table}{cornerIndex};
                                for cornerParamIndex=1:designParamsTotal
                                    if cornerParamIndex==corModelSpecIndex

                                        temp='';
                                        corModelSpec=cornerParamValues{cornerParamIndex};
                                        ptrsEnd=strfind(corModelSpec,' Section=');
                                        for ptr=1:length(ptrsEnd)
                                            ptrsBgn=strfind(extractBefore(corModelSpec,ptrsEnd(ptr)),'/');
                                            if isempty(temp)
                                                temp=extractBetween(corModelSpec,ptrsBgn(end)+1,ptrsEnd(ptr)-1);
                                            else
                                                temp=strcat(temp,',',extractBetween(corModelSpec,ptrsBgn(end)+1,ptrsEnd(ptr)-1));
                                            end
                                            if corModelSpec(ptrsEnd(ptr)+9)~=';'

                                                suffixBgn=ptrsEnd(ptr)+9;
                                                suffixEnd=suffixBgn;
                                                for suffixPtr=suffixBgn+1:length(corModelSpec)
                                                    if corModelSpec(suffixPtr)==';'
                                                        suffixEnd=suffixPtr-1;
                                                        break;
                                                    end
                                                end
                                                if suffixBgn<suffixEnd
                                                    temp=strcat(temp,':',extractBetween(corModelSpec,suffixBgn,suffixEnd));
                                                end
                                            end
                                        end
                                        cornerParamValues{cornerParamIndex}=temp;
                                    else

                                        cornerParamValues{cornerParamIndex}=msblks.utilities.str2doubleSI(cornerParamValues{cornerParamIndex});
                                    end
                                end

                                duplicateCornersCount=0;
                                duplicateCornersIndex=0;
                                indices=find(cornersWithSameParamValuesCount);
                                if~isempty(indices)
                                    for idx=1:length(indices)
                                        index=indices(idx);
                                        isSame=strcmp(cornersWithSameParamValuesNames{index},cornerName);
                                        if any(isSame)

                                            duplicateCornersCount=length(cornersWithSameParamValuesNames{index});
                                            for idx2=1:duplicateCornersCount
                                                if isSame(idx2)
                                                    duplicateCornersIndex=idx2;
                                                    break;
                                                end
                                            end
                                            break;
                                        end
                                    end
                                end

                                lastTableRow=tableRow;
                                for tableRowIndex=1:length(tableData)
                                    tableRowData=tableData(tableRowIndex);
                                    matched=true;
                                    for simParamIndex=1:designParamsTotal
                                        if simParamIndex==corModelSpecIndex
                                            if~strcmpi(tableRowData.modelFiles,cornerParamValues{simParamIndex})&&...
                                                (isempty(strfind(cornerParamValues{simParamIndex},','))||~strcmpi(tableRowData.modelFiles,'nom'))
                                                matched=false;
                                                break;
                                            end
                                        else
                                            simParamName=paramNamesPerTable{table}{simParamIndex};
                                            if isfield(tableRowData,simParamName)&&(...
                                                isnumeric(tableRowData.(simParamName))~=isnumeric(cornerParamValues{simParamIndex})||...
                                                isnumeric(tableRowData.(simParamName))&&...
                                                isnan(tableRowData.(simParamName))~=isnan(cornerParamValues{simParamIndex})||...
                                                isnumeric(tableRowData.(simParamName))&&...
                                                ~(abs(tableRowData.(simParamName)-cornerParamValues{simParamIndex})<=abs(tableRowData.(simParamName)*0.001))||...
                                                ischar(tableRowData.(simParamName))~=ischar(cornerParamValues{simParamIndex})||...
                                                ischar(tableRowData.(simParamName))&&...
                                                ~strcmpi(tableRowData.(simParamName),cornerParamValues{simParamIndex}))
                                                matched=false;
                                                break;
                                            end
                                        end
                                    end
                                    if matched

                                        tableRowData.corner=cornerName;
                                        tableDataNew(tableRow)=tableRowData;
                                        tableRow=tableRow+1;
                                    end
                                end
                                if lastTableRow<tableRow&&duplicateCornersCount>1&&duplicateCornersIndex>0&&duplicateCornersIndex<=duplicateCornersCount

                                    waveformsPerCorner=(tableRow-lastTableRow)/duplicateCornersCount;

                                    idxTarget=lastTableRow+duplicateCornersIndex-1;
                                    for idx=lastTableRow:lastTableRow+waveformsPerCorner-1
                                        tableDataNew(idx)=tableDataNew(idxTarget);
                                        idxTarget=idxTarget+duplicateCornersCount;
                                    end

                                    tableRow=lastTableRow+waveformsPerCorner;
                                end
                                if lastTableRow==tableRow




                                end
                            end
                            if~isempty(find(cornersWithSameParamValuesCount,1))&&length(tableDataNew)>length(tableData)

                                for idx=length(tableDataNew):-1:length(tableData)+1
                                    tableDataNew(idx)=[];
                                end
                            end
                            tableData=tableDataNew;
                        end


                        if~isempty(tableData)

                            if isempty(waveforms)
                                waveforms={tableData(1)};
                            end
                            waveforms{count+length(tableData)}=tableData(1);%#ok<AGROW> Extend array.
                        end
                        for row=1:length(tableData)

                            count=count+1;
                            waveforms{count}=tableData(row);%#ok<AGROW>

                            if isempty(waveformTypes)

                                waveformTypes={waveforms{count}.type};
                            elseif~isempty(waveforms{count}.type)&&~any(contains(waveformTypes,waveforms{count}.type))

                                waveformTypes{end+1}=waveforms{count}.type;%#ok<AGROW>
                            end

                            isNormalWaveform=true;
                            if~isempty(waveNodesPerTable)&&~isempty(waveNodesPerTable{table})&&...
                                isfield(waveforms{count},'Output')&&any(contains(waveNodesPerTable{table},waveforms{count}.Output))
                                for waveNodeIndex=1:length(waveNodesPerTable{table})
                                    if strcmpi(waveNodesPerTable{table}{waveNodeIndex},waveforms{count}.Output)
                                        if isempty(waveTypes{waveNodeIndex})

                                            waveTypes{waveNodeIndex}=waveforms{count}.type;%#ok<AGROW>
                                        end
                                        isNormalWaveform=false;
                                    end
                                end
                            end

                            if isNormalWaveform
                                if isempty(normalWfTypes)

                                    normalWfTypes={waveforms{count}.type};
                                elseif~isempty(waveforms{count}.type)&&~any(contains(normalWfTypes,waveforms{count}.type))

                                    normalWfTypes{end+1}=waveforms{count}.type;%#ok<AGROW>
                                end
                            end
                        end
                    end
                    waveformTypesPerTable{table}=waveformTypes;%#ok<AGROW> Unique waveform types for all waveforms in table.
                    normalWfTypesPerTable{table}=normalWfTypes;%#ok<AGROW> Unique waveform types for all "normal waveforms" in table.
                    waveTypesPerTable{table}=waveTypes;%#ok<AGROW> g2741244: Waveform types per "intermediate waveform" in table.


                    allNodesTotal=length(nodesPerTable{table});
                    waveNodesTotal=length(waveNodesPerTable{table});
                    if isUsingdbTables

                        normNodesTotal=allNodesTotal;
                    else

                        normNodesTotal=allNodesTotal-waveNodesTotal;
                    end

                    normalwfTypesTotal=length(normalWfTypes);
                    wfIndex=0;
                    for cornerIndex=1:length(cornersPerTable{table})

                        for nodeIndex=1:normNodesTotal
                            for typeIndex=1:normalwfTypesTotal
                                wfIndex=wfIndex+1;
                                if~strcmpi(waveforms{wfIndex}.type,waveformTypes{typeIndex})

                                    for wfIndex2=wfIndex+1:wfIndex+normalwfTypesTotal-typeIndex

                                        if strcmpi(waveforms{wfIndex2}.type,waveformTypes{typeIndex})

                                            temp=waveforms{wfIndex};
                                            waveforms{wfIndex}=waveforms{wfIndex2};%#ok<AGROW>
                                            waveforms{wfIndex2}=temp;%#ok<AGROW>
                                        end
                                    end
                                end
                            end
                        end

                        wfIndex=wfIndex+waveNodesTotal;
                    end
                end
            end


            for table=1:length(caseCountPerTable)
                if isempty(caseCountPerTable{table})||caseCountPerTable{table}==0

                    if isempty(caseCountPerTable2)||isempty(caseCountPerTable2{table})
                        caseCountPerTable{table}=0;%#ok<AGROW> Also not found in exprTables.
                    else
                        caseCountPerTable{table}=caseCountPerTable2{table};%#ok<AGROW> From exprTables.
                    end
                end
                if isempty(pointSweepCountPerTable{table})||pointSweepCountPerTable{table}==0

                    if isempty(pointSweepCountPerTable2)||isempty(pointSweepCountPerTable2{table})
                        pointSweepCountPerTable{table}=0;%#ok<AGROW>  Also not found in exprTables.
                    else
                        pointSweepCountPerTable{table}=pointSweepCountPerTable2{table};%#ok<AGROW> From exprTables.
                    end
                end
            end


            corModelSpecPerTable_ShortVsLongValues={};
            for table=1:length(paramNamesPerTable)
                [corModelSpecPerTable_ShortVsLongValues{end+1},paramValuesPerCorner{table}]=...
                getShortColumnValues_corModelSpec(paramNamesPerTable{table},paramValuesPerCorner{table});%#ok<AGROW>
            end


            paramNamesPerTable_ShortMetrics=paramNamesPerTable;
            paramsPerTable_ShortVsLongNames={};
            for table=1:length(paramNamesPerTable)
                [paramsPerTable_ShortVsLongNames{end+1},paramNamesPerTable_ShortMetrics{table}]=...
                getShortColumnNames(designParamsCountPerTable{table},paramNamesPerTable{table});%#ok<AGROW>
            end


            for table=1:length(paramNamesPerTable)
                [paramsPerTable_ShortVsLongNames{table},paramNamesPerTable_ShortMetrics{table}]=...
                getUniqueColumnNames(designParamsCountPerTable{table},...
                paramNamesPerTable{table},...
                paramNamesPerTable_ShortMetrics{table},...
                paramsPerTable_ShortVsLongNames{table});%#ok<AGROW>
            end

        end


        function simulationsDB=getGenericDB(obj)
            if isempty(obj.db)
                simulationsDB=[];
                return;
            end
            simulationsDB=msblks.internal.mixedsignalanalysis.SimulationsDB;
            simulationsDB.sourceType='Cadence';
            simulationsDB.matFileName=obj.matFileName;
            simulationsDB.fullPathMatFileName=obj.fullPathMatFileName;
            waveCountTotal=0;
            for simRun=1:length(obj.tableNames)

                if obj.isUsingdbTables

                    nodesPerTableCount=length(obj.nodesPerTable{simRun});
                else

                    nodesPerTableCount=length(obj.nodesPerTable{simRun})-length(obj.waveNodesPerTable{simRun});
                end

                simName=obj.tableNames{simRun};



                waveCountPerSimRun=0;
                if~isempty(obj.nodesPerTable)&&~isempty(obj.cornersPerTable)&&~isempty(obj.normalWfTypesPerTable)

                    for j=1:length(obj.cornersPerTable{simRun})

                        for k=1:nodesPerTableCount
                            for m=1:length(obj.normalWfTypesPerTable{simRun})
                                waveCountPerSimRun=waveCountPerSimRun+1;
                            end
                        end

                        for k=1:length(obj.waveTypesPerTable{simRun})
                            waveCountPerSimRun=waveCountPerSimRun+1;
                        end
                    end
                end

                waves=[];
                names=[];
                if waveCountPerSimRun>0
                    waves{waveCountPerSimRun}=[];%#ok<AGROW> Pre-allocate cell array to store waveform data.
                    names{waveCountPerSimRun}=[];%#ok<AGROW> Pre-allocate cell array to store waveform names.
                    waveCountPerSimRun=0;
                    for j=1:length(obj.cornersPerTable{simRun})
                        corner=obj.cornersPerTable{simRun}{j};

                        for k=1:nodesPerTableCount
                            if waveCountTotal>=length(obj.waveforms)
                                break;
                            end
                            node=obj.nodesPerTable{simRun}{k};
                            for m=1:length(obj.normalWfTypesPerTable{simRun})
                                type=obj.normalWfTypesPerTable{simRun}{m};
                                waveCountTotal=waveCountTotal+1;
                                waveCountPerSimRun=waveCountPerSimRun+1;
                                if iscell(corner)
                                    names{waveCountPerSimRun}=packWaveformName(simName,type,node,corner{1});
                                else
                                    names{waveCountPerSimRun}=packWaveformName(simName,type,node,corner);
                                end
                                if iscell(obj.waveforms)
                                    waves{waveCountPerSimRun}=obj.waveforms{waveCountTotal};
                                else
                                    waves{waveCountPerSimRun}=obj.waveforms(waveCountTotal);
                                end
                            end
                        end

                        for k=1:length(obj.waveNodesPerTable{simRun})
                            if waveCountTotal>=length(obj.waveforms)
                                break;
                            end
                            type=obj.waveTypesPerTable{simRun}{k};
                            node=obj.waveNodesPerTable{simRun}{k};
                            waveCountTotal=waveCountTotal+1;
                            waveCountPerSimRun=waveCountPerSimRun+1;
                            if iscell(corner)
                                names{waveCountPerSimRun}=packWaveformName(simName,type,node,corner{1});
                            else
                                names{waveCountPerSimRun}=packWaveformName(simName,type,node,corner);
                            end
                            if iscell(obj.waveforms)
                                waves{waveCountPerSimRun}=obj.waveforms{waveCountTotal};
                            else
                                waves{waveCountPerSimRun}=obj.waveforms(waveCountTotal);
                            end
                        end
                    end
                end



                waveCountPerSimRun=0;
                if~isempty(obj.nodesPerTable)&&~isempty(obj.cornersPerTable)&&~isempty(obj.normalWfTypesPerTable)

                    for j=1:length(obj.normalWfTypesPerTable{simRun})
                        for k=1:nodesPerTableCount
                            for m=1:length(obj.cornersPerTable{simRun})
                                waveCountPerSimRun=waveCountPerSimRun+1;
                            end
                        end
                    end

                    for j=1:length(obj.waveNodesPerTable{simRun})
                        for k=1:length(obj.cornersPerTable{simRun})
                            waveCountPerSimRun=waveCountPerSimRun+1;
                        end
                    end
                end

                sortedNames=[];
                sortedWaves=[];
                if waveCountPerSimRun>0
                    sortedNames{waveCountPerSimRun}=[];%#ok<AGROW> Pre-allocate cell array.
                    sortedWaves{waveCountPerSimRun}=[];%#ok<AGROW> Pre-allocate cell array.
                    waveCountPerSimRun=0;

                    for j=1:length(obj.normalWfTypesPerTable{simRun})
                        type=obj.normalWfTypesPerTable{simRun}{j};
                        for k=1:nodesPerTableCount
                            node=obj.nodesPerTable{simRun}{k};
                            for m=1:length(obj.cornersPerTable{simRun})
                                corner=obj.cornersPerTable{simRun}{m};
                                waveCountPerSimRun=waveCountPerSimRun+1;
                                if iscell(corner)
                                    sortedNames{waveCountPerSimRun}=packWaveformName(simName,type,node,corner{1});
                                else
                                    sortedNames{waveCountPerSimRun}=packWaveformName(simName,type,node,corner);
                                end
                                for n=1:length(names)
                                    if strcmp(names{n},sortedNames{waveCountPerSimRun})
                                        sortedWaves{waveCountPerSimRun}=waves{n};
                                        break;
                                    end
                                end
                            end
                        end
                    end

                    for j=1:length(obj.waveNodesPerTable{simRun})
                        type=obj.waveTypesPerTable{simRun}{j};
                        node=obj.waveNodesPerTable{simRun}{j};
                        for k=1:length(obj.cornersPerTable{simRun})
                            corner=obj.cornersPerTable{simRun}{k};
                            waveCountPerSimRun=waveCountPerSimRun+1;
                            if iscell(corner)
                                sortedNames{waveCountPerSimRun}=packWaveformName(simName,type,node,corner{1});
                            else
                                sortedNames{waveCountPerSimRun}=packWaveformName(simName,type,node,corner);
                            end
                            for m=1:length(names)
                                if strcmp(names{m},sortedNames{waveCountPerSimRun})
                                    sortedWaves{waveCountPerSimRun}=waves{m};
                                    break;
                                end
                            end
                        end
                    end
                end


                simulationResults=msblks.internal.mixedsignalanalysis.SimulationResults;


                simulationResults.preAllocateWaveforms(length(sortedWaves));
                for j=1:length(sortedWaves)
                    if isempty(sortedWaves{j})
                        continue;
                    end
                    simulationResults.setXaxis(sortedNames{j},...
                    sortedWaves{j}.xlabel,...
                    sortedWaves{j}.xunit,...
                    sortedWaves{j}.xscale,...
                    sortedWaves{j}.x,...
                    j);
                    simulationResults.setYaxis(sortedNames{j},...
                    sortedWaves{j}.ylabel,...
                    sortedWaves{j}.yunit,...
                    sortedWaves{j}.yscale,...
                    sortedWaves{j}.y,...
                    j);
                end

                simulationResults.compressWaveformProperties();


                if~isempty(obj.cornersPerTable{simRun})

                    corners=[];
                    corners{length(obj.cornersPerTable{simRun})}=[];%#ok<AGROW> Pre-allocate cell array.
                    for j=1:length(obj.cornersPerTable{simRun})
                        try
                            corners(j)=obj.cornersPerTable{simRun}{j};
                        catch
                            corners{j}=obj.cornersPerTable{simRun}{j};
                        end
                    end
                elseif~isempty(obj.cornersPerNode{simRun})
                    corners=obj.cornersPerNode{simRun}{1};
                else
                    corners=obj.cornersPerNode{simRun};
                end
                simulationResults.setParam('tableName',obj.tableNames{simRun});
                simulationResults.setParam('caseCount',obj.caseCountPerTable{simRun});
                simulationResults.setParam('pointSweepCount',obj.pointSweepCountPerTable{simRun});
                simulationResults.setParam('nodes',obj.nodesPerTable{simRun});
                simulationResults.setParam('corners',corners);
                simulationResults.setParam('paramNames',obj.paramNamesPerTable{simRun});
                simulationResults.setParam('paramValues',obj.paramValuesPerCorner{simRun});
                simulationResults.setParam('waveNodes',obj.waveNodesPerTable{simRun});
                if~isempty(obj.waveTypesPerTable)
                    simulationResults.setParam('waveTypes',obj.waveTypesPerTable{simRun});
                else
                    simulationResults.setParam('waveTypes',[]);
                end
                if~isempty(obj.waveformTypesPerTable)
                    simulationResults.setParam('waveformTypes',obj.waveformTypesPerTable{simRun});
                else
                    simulationResults.setParam('waveformTypes',[]);
                end
                if~isempty(obj.normalWfTypesPerTable)
                    simulationResults.setParam('normalWaveformTypes',obj.normalWfTypesPerTable{simRun});
                else
                    simulationResults.setParam('normalWaveformTypes',[]);
                end
                if~iscell(obj.paramNamesPerTable{simRun})
                    temp{1}=obj.paramNamesPerTable{simRun};
                    obj.paramNamesPerTable{simRun}=temp;
                end
                for j=1:length(obj.paramNamesPerTable{simRun})
                    paramName=obj.paramNamesPerTable{simRun}{j};
                    paramValues=[];
                    if~isempty(corners)
                        paramValues{length(corners)}={};%#ok<AGROW> Pre-allocate cell array.
                        if~isempty(obj.paramValuesPerCorner{simRun})
                            for k=1:length(corners)
                                if iscell(obj.paramValuesPerCorner{simRun}{k})
                                    paramValues{k}=obj.paramValuesPerCorner{simRun}{k}{j};
                                else
                                    paramValues{k}=obj.paramValuesPerCorner{simRun}{k}(j);
                                end
                            end
                        end
                    end
                    simulationResults.setParam(paramName,paramValues);
                end
                simulationResults.setParam('designParamsCount',obj.designParamsCountPerTable{simRun});
                simulationResults.setParam('paramNames_ShortMetrics',obj.paramNamesPerTable_ShortMetrics{simRun});
                simulationResults.setParam('params_ShortVsLongNames',obj.paramsPerTable_ShortVsLongNames{simRun});
                simulationResults.setParam('corModelSpec_ShortVsLongValues',obj.corModelSpecPerTable_ShortVsLongValues{simRun});


                simulationsDB.setSimulationResults(simName,simulationResults);
            end
        end
    end
end


function waveformName=packWaveformName(simName,simType,nodeName,simCorner)
    waveformName=...
    msblks.internal.mixedsignalanalysis.SimulationResults.packWaveformName(simName,simType,nodeName,simCorner);
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
