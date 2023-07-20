classdef TaskEditorDataSource<multicoredesigner.internal.MulticoreSpreadsheetDataSource






    properties(GetAccess=private,SetAccess=private)
MaxGroupCost
    end

    methods
        function updateContents(obj)
            obj.MaxGroupCost=[];
            data=[];
            mappingData=obj.MappingData;
            if~isempty(mappingData)&&...
                getStatus(multicoredesigner.internal.getAppContext(obj.UIObj.ModelH))==...
                multicoredesigner.internal.AnalysisPhase.AnalysisComplete
                numMapping=getNumMapping(mappingData);
                for regionId=1:numMapping

                    regionName=getRegionName(mappingData,regionId);

                    if obj.UIObj.TaskView

                        numTasksInRegion=getNumTasksBySystem(mappingData,regionId);
                        for j=1:numTasksInRegion
                            taskType=getTaskType(mappingData,regionId,j);
                            if isequal(taskType,'Periodic')
                                taskIdStr=['Thread ',num2str(j)];
                            else
                                taskIdStr=taskType;
                            end
                            blockInfos=getBlocksByTask(mappingData,regionId,j);

                            if isempty(blockInfos)
                                continue
                            end

                            [~,idx]=unique({blockInfos.Path});
                            blockInfos=blockInfos(idx);
                            blockRows=[];
                            for k=1:length(blockInfos)
                                aBlock=blockInfos(k);
                                if getSimulinkBlockHandle(aBlock.Path)==-1

                                    continue
                                end
                                blockRow=multicoredesigner.internal.TaskEditorRowItem(...
                                obj,regionId,...
                                getfullname(aBlock.Path),num2str(aBlock.PipelineStage),'');
                                blockRows=[blockRows,blockRow];%#ok<AGROW>
                            end
                            taskName=[taskIdStr,' (',regionName,')'];
                            taskRow=multicoredesigner.internal.ParallelSystemRowItem(obj,regionId,...
                            getString(message('dataflow:Spreadsheet:TaskEditorKeyColumnName')),...
                            taskName,blockRows);
                            data=[data,taskRow];%#ok<AGROW>
                        end
                    else

                        blockRows=[];
                        blockInfos=getBlocksByRegion(mappingData,regionId);
                        for j=1:length(blockInfos)
                            aBlock=blockInfos(j);
                            if getSimulinkBlockHandle(aBlock.Path)==-1||~aBlock.Show

                                continue
                            end

                            isMulti=isBlockMultiTask(mappingData,regionId,aBlock.Path);
                            if isMulti
                                taskIdStr='Multiple';
                            else
                                taskId=getRelativeIdForTask(mappingData,aBlock.TaskId);
                                taskType=getTaskType(mappingData,regionId,taskId);
                                if isequal(taskType,'Periodic')
                                    taskIdStr=num2str(taskId);
                                else
                                    taskIdStr=taskType;
                                end
                            end
                            blockRow=multicoredesigner.internal.TaskEditorRowItem(...
                            obj,regionId,...
                            getfullname(aBlock.Path),num2str(aBlock.PipelineStage),taskIdStr);
                            blockRows=[blockRows,blockRow];%#ok<AGROW>
                        end

                        regionName=getRegionName(mappingData,regionId);
                        regionRow=multicoredesigner.internal.ParallelSystemRowItem(obj,regionId,...
                        getString(message('dataflow:Spreadsheet:TaskEditorKeyColumnName')),...
                        regionName,blockRows);
                        data=[data,regionRow];%#ok<AGROW>
                    end
                end
            end
            obj.Data=data;
        end

        function columns=getColumns(obj)
            if obj.UIObj.TaskView
                columns={getString(message('dataflow:Spreadsheet:TaskEditorKeyColumnName')),...
                getString(message('dataflow:Spreadsheet:TaskEditorPipelineStageColumnName'))};
            else
                columns={getString(message('dataflow:Spreadsheet:TaskEditorKeyColumnName')),...
                getString(message('dataflow:Spreadsheet:TaskEditorPipelineStageColumnName')),...
                getString(message('dataflow:Spreadsheet:TaskEditorTaskColumnName'))};
            end
        end

        function[sortColumn,direction]=getSortColumn(~)
            direction=true;
            sortColumn='';
        end
    end
end


