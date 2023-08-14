classdef SuggestionsDataSource<multicoredesigner.internal.MulticoreSpreadsheetDataSource






    methods
        function updateContents(obj)
            data=[];
            mappingData=obj.MappingData;
            if~isempty(mappingData)&&~isempty(mappingData.MappingCacheData)
                for regionId=1:getNumMapping(mappingData)
                    mappingCacheData=mappingData.MappingCacheData{regionId};
                    latency=mappingCacheData.SpecifiedLatency;
                    if mappingCacheData.OptimalLatency~=0&&latency~=mappingCacheData.OptimalLatency
                        suggestion=num2str(mappingCacheData.OptimalLatency);
                        systemRow=multicoredesigner.internal.SuggestionsRowItem(obj,regionId,num2str(latency),suggestion);
                        data=[data,systemRow];%#ok<AGROW>
                    end
                end
            end
            obj.Data=data;
        end

        function columns=getColumns(~)
            columns={getString(message('dataflow:Spreadsheet:SuggestionsEditorKeyColumnName')),...
            getString(message('dataflow:Spreadsheet:SuggestionsEditorCurrentLatencyColumnName')),...
            getString(message('dataflow:Spreadsheet:SuggestionsEditorCurrentSuggestedColumnName')),...
            getString(message('dataflow:Spreadsheet:SuggestionsEditorAcceptColumnName'))};
        end

        function[column,direction]=getSortColumn(~)
            column='';
            direction=true;
        end
    end
end


