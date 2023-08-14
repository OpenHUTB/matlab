classdef TaskLegendDataSource<multicoredesigner.internal.MulticoreSpreadsheetDataSource






    methods

        function updateContents(obj)

            data=[];
            mappingData=obj.MappingData;
            if~isempty(mappingData)&&...
                getStatus(multicoredesigner.internal.getAppContext(obj.UIObj.ModelH))==...
                multicoredesigner.internal.AnalysisPhase.AnalysisComplete
                numMapping=getNumMapping(mappingData);
                for regionId=1:numMapping
                    regionName=getRegionName(mappingData,regionId);
                    threadRows=[];
                    numTasksInRegion=getNumTasksBySystem(mappingData,regionId);
                    for relativeTaskId=1:numTasksInRegion
                        if isempty(getBlocksByTask(mappingData,regionId,relativeTaskId))

                            enabled=false;
                        else
                            enabled=true;
                        end
                        taskType=getTaskType(mappingData,regionId,relativeTaskId);
                        if isequal(taskType,'Periodic')
                            taskIdStr=['Thread ',num2str(relativeTaskId)];
                        else
                            taskIdStr=taskType;
                        end

                        threadRow=multicoredesigner.internal.TaskLegendRowItem(obj,regionId,relativeTaskId,taskType,taskIdStr,enabled);
                        threadRows=[threadRows,threadRow];%#ok<AGROW>
                    end

                    if hasBlocksWithMultipleTasks(mappingData,regionId)
                        multipleTaskRow=multicoredesigner.internal.TaskLegendRowItem(obj,numMapping+1,1,'Multiple',...
                        getString(message('dataflow:Spreadsheet:MultipleTasks')),enabled);
                        threadRows=[threadRows,multipleTaskRow];%#ok<AGROW> 
                    end

                    regionRow=multicoredesigner.internal.ParallelSystemRowItem(obj,regionId,...
                    getString(message('dataflow:Spreadsheet:Enabled')),...
                    regionName,threadRows);
                    data=[data,regionRow];
                end
            end
            obj.Data=data;
        end

        function highlightAll(obj)
            highlightAll(obj.TaskHighlighter);
        end

        function removeAllHighlighting(obj)
            removeAllHighlighting(obj.TaskHighlighter);
        end

        function columns=getColumns(~)
            columns={getString(message('dataflow:Spreadsheet:TaskLegendEnabledColumnName')),...
            getString(message('dataflow:Spreadsheet:TaskLegendKeyColumnName')),...
            getString(message('dataflow:Spreadsheet:TaskLegendColorColumnName'))};
        end

        function[column,direction]=getSortColumn(~)
            column='';
            direction=true;
        end

    end
end


