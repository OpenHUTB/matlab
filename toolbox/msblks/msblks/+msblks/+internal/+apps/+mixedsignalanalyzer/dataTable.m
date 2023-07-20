classdef dataTable<handle




    properties
        db=[];
tableFileName
fullPathTableFileName
    end

    methods
        function obj=dataTable(fullPathTableFileName,tableFileName)
            try
                obj.tableFileName=tableFileName;
                obj.fullPathTableFileName=fullPathTableFileName;
                if isa(obj.fullPathTableFileName,'table')

                    type='table';
                    sheets{1}=tableFileName;
                    tables{1}=obj.fullPathTableFileName;
                    obj.fullPathTableFileName=[];
                elseif endsWith(tableFileName,'.csv')

                    type='.csv';
                    [~,sheets{1},~]=fileparts(fullPathTableFileName);
                    tables{1}=readtable(fullPathTableFileName,'VariableNamingRule','preserve');
                elseif endsWith(tableFileName,'.xlsx')

                    type='.xlsx';
                    sheets=sheetnames(fullPathTableFileName);
                    tables{length(sheets)}=[];
                    for i=1:length(sheets)
                        tables{i}=readtable(fullPathTableFileName,'Sheet',sheets{i},'VariableNamingRule','preserve');
                    end
                else

                    type='';
                    sheets=[];
                    tables=[];
                end
                if~isempty(sheets)&&length(sheets)==length(tables)
                    obj.db=obj.getGenericDB(type,sheets,tables);
                end
            catch err
                uiwait(warndlg(err.message));
            end
        end

        function simulationsDB=getGenericDB(obj,type,sheets,tables)
            if isempty(tables)
                simulationsDB=[];
                return;
            end
            simulationsDB=msblks.internal.mixedsignalanalysis.SimulationsDB;
            simulationsDB.sourceType=type;
            simulationsDB.matFileName=obj.tableFileName;
            simulationsDB.fullPathMatFileName=obj.fullPathTableFileName;
            for i=1:length(sheets)


                columnNames=tables{i}.Properties.VariableNames;
                columnValues=[];
                columnValues{length(columnNames)}=[];%#ok<AGROW> Pre-allocate cell array.
                for j=1:length(columnNames)
                    columnValues{j}=tables{i}.(columnNames{j});
                end
                if iscell(tables{i}.Properties.VariableDescriptions)&&...
                    length(tables{i}.Properties.VariableDescriptions)==length(tables{i}.Properties.VariableNames)

                    columnNames=tables{i}.Properties.VariableDescriptions;
                    useShortColumnNames=true;
                else
                    useShortColumnNames=false;
                end


                totalRows=size(tables{i},1);
                corners=[];
                paramValuesPerCorner=[];
                if totalRows>0

                    corners{totalRows}=[];%#ok<AGROW> Pre-allocate cell array.
                    for j=1:totalRows
                        corners{j}=['C_',num2str(j)];
                    end

                    paramValuesPerCorner{totalRows}=[];%#ok<AGROW> Pre-allocate cell array.
                    totalColumns=length(columnNames);
                    for j=1:totalRows
                        for k=1:totalColumns
                            if iscell(columnValues{k})
                                paramValuesPerCorner{j}{k}=columnValues{k}{j};
                            else
                                paramValuesPerCorner{j}{k}=columnValues{k}(j);
                            end
                        end
                    end
                end

                if useShortColumnNames

                    [shortVsLongColumnNames,shortColumnNames]=...
                    getShortColumnNames(0,columnNames);

                    [shortVsLongColumnNames,shortColumnNames]=...
                    getUniqueColumnNames(0,columnNames,shortColumnNames,shortVsLongColumnNames);
                end


                tableResults=msblks.internal.mixedsignalanalysis.SimulationResults;
                tableResults.setParam('tableName',sheets{i});

                tableResults.setParam('caseCount',totalRows);
                tableResults.setParam('pointSweepCount',1);
                tableResults.setParam('nodes',[]);
                tableResults.setParam('corners',corners);
                tableResults.setParam('paramNames',columnNames);
                tableResults.setParam('paramValues',paramValuesPerCorner);
                for j=1:length(columnNames)


                    tableResults.setParam(columnNames{j},columnValues{j});
                end
                tableResults.setParam('waveformTypes',[]);
                tableResults.setParam('designParamsCount',0);
                if useShortColumnNames
                    tableResults.setParam('paramNames_ShortMetrics',shortColumnNames);
                    tableResults.setParam('params_ShortVsLongNames',shortVsLongColumnNames);
                else
                    tableResults.setParam('paramNames_ShortMetrics',columnNames);
                    tableResults.setParam('params_ShortVsLongNames',[]);
                end
                tableResults.setParam('corModelSpec_ShortVsLongValues',[]);
                simulationsDB.setSimulationResults(sheets{i},tableResults);
            end
        end
    end
end


function[shortVsLongNames,paramNames_ShortMetrics]=getShortColumnNames(designParamsCount,paramNames)
    [shortVsLongNames,paramNames_ShortMetrics]=...
    msblks.internal.mixedsignalanalysis.SimulationResults.getShortColumnNames(designParamsCount,paramNames);
end
function[shortVsLongNames,paramNames_ShortMetrics]=getUniqueColumnNames(designParamsCount,paramNames,paramNames_ShortMetrics,shortVsLongNames)
    [shortVsLongNames,paramNames_ShortMetrics]=...
    msblks.internal.mixedsignalanalysis.SimulationResults.getUniqueColumnNames(designParamsCount,paramNames,paramNames_ShortMetrics,shortVsLongNames);
end

