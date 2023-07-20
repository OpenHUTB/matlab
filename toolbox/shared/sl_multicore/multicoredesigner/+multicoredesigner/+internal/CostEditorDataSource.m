classdef CostEditorDataSource<multicoredesigner.internal.MulticoreSpreadsheetDataSource






    properties(GetAccess=private,SetAccess=private)
MaxGroupCost
    end

    methods
        function updateContents(obj)
            obj.MaxGroupCost=[];
            data=[];
            mappingData=obj.MappingData;
            appContext=multicoredesigner.internal.getAppContext(obj.UIObj.ModelH);
            isSim=appContext.SimulationProfilingModeEnabled;
            if~isempty(mappingData)&&...
                getStatus(appContext)~=...
                multicoredesigner.internal.AnalysisPhase.Initial
                numMapping=getNumMapping(mappingData);
                for regionId=1:numMapping
                    maxCost=0;
                    blockRows=[];
                    regionName=getRegionName(mappingData,regionId);
                    blockCacheData=mappingData.BlockCacheData{regionId};
                    for j=1:length(blockCacheData)
                        aBlock=blockCacheData(j);
                        if getSimulinkBlockHandle(aBlock.Path)==-1||~aBlock.Show

                            continue
                        end

                        blockRow=multicoredesigner.internal.CostEditorRowItem(...
                        obj,regionId,...
                        aBlock.Path,aBlock.Cost,...
                        aBlock.UserCost,aBlock.OverrideCostData,isSim);
                        blockRows=[blockRows,blockRow];%#ok<AGROW>
                        if aBlock.OverrideCostData
                            cost=floor(double(aBlock.UserCost)/1e3);
                        else
                            if aBlock.Cost==intmax('uint64')
                                cost=0;
                            else
                                cost=double(aBlock.Cost)/1e3;
                            end
                        end
                        maxCost=max(maxCost,cost);
                    end

                    if isempty(blockRows)
                        if isRegionAnalyzed(mappingData,regionId)
                            blockRows=multicoredesigner.internal.ParallelSystemRowItem(obj,regionId,getString(message('dataflow:Spreadsheet:CostEditorKeyColumnName')),...
                            ['<',getString(message('dataflow:Spreadsheet:EmptySubsystemText')),'>'],[]);
                        else
                            blockRows=multicoredesigner.internal.ParallelSystemRowItem(obj,regionId,getString(message('dataflow:Spreadsheet:CostEditorKeyColumnName')),...
                            ['<',getString(message('dataflow:Spreadsheet:SubsystemNeedsCost')),'>'],[]);
                        end
                    end
                    regionRow=multicoredesigner.internal.ParallelSystemRowItem(obj,regionId,getString(message('dataflow:Spreadsheet:CostEditorKeyColumnName')),...
                    regionName,blockRows);
                    data=[data,regionRow];%#ok<AGROW>
                    obj.MaxGroupCost=[obj.MaxGroupCost,maxCost];
                end
            end
            obj.Data=data;
        end

        function totalCost=getMaxGroupCost(obj,idx)
            totalCost=0;
            if idx<=length(obj.MaxGroupCost)
                totalCost=obj.MaxGroupCost(idx);
            end
        end

        function columns=getColumns(obj)
            if obj.MappingData.getCostMethod()==slmulticore.CostMethod.Estimation||...
                obj.MappingData.getCostMethod()==slmulticore.CostMethod.User
                columns={getString(message('dataflow:Spreadsheet:CostEditorKeyColumnName')),...
                getString(message('dataflow:Spreadsheet:CostEditorAutoColumnName')),...
                getString(message('dataflow:Spreadsheet:CostEditorCostColumnName')),...
                getString(message('dataflow:Spreadsheet:CostEditorCostRatioColumnName'))};
            else
                columns={getString(message('dataflow:Spreadsheet:CostEditorKeyColumnName')),...
                getString(message('dataflow:Spreadsheet:CostEditorAutoColumnName')),...
                getString(message('dataflow:Spreadsheet:CostEditorProfiledCostColumnName')),...
                getString(message('dataflow:Spreadsheet:CostEditorCostRatioColumnName'))};
            end
        end

        function[sortColumn,direction]=getSortColumn(~)
            sortColumn=getString(message('dataflow:Spreadsheet:CostEditorCostColumnName'));
            direction=false;
        end

        function updateAllRows(obj)

            obj.UIObj.getCostEditor.Component.setConfig('{"expandall":true, "disablepropertyinspectorupdate":true}');
            obj.UIObj.getCostEditor.Component.update(true);
        end
    end
end


