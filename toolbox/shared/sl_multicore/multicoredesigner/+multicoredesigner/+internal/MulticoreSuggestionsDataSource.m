classdef MulticoreSuggestionsDataSource<DAStudio.WebDDG





    properties
UIObj
MappingData
Data
    end

    methods
        function obj=MulticoreSuggestionsDataSource(uiObj)
            obj.UIObj=uiObj;
        end

        function mappingData=get.MappingData(obj)
            mappingData=getMappingData(obj.UIObj);
        end

        function updateContents(obj)
            modelName=get(obj.UIObj.ModelH,'Name');
            hasSuggestion='0';
            regionNames='';
            suggestedLatencies='';

            for j=1:obj.MappingData.NumMapping
                regionNames=[regionNames,getRegionName(obj.MappingData,j)];
                latencySuggestion=obj.MappingData.getLatencySuggestion(j);
                if~isempty(latencySuggestion)
                    latency=num2str(latencySuggestion);
                    hasSuggestion='1';
                else
                    latency='';
                end
                suggestedLatencies=[suggestedLatencies,latency];
                if j~=obj.MappingData.NumMapping
                    regionNames=[regionNames,','];
                    suggestedLatencies=[suggestedLatencies,','];
                end
            end

            connector.ensureServiceOn;
            obj.Url=[connector.getUrl('toolbox/shared/sl_multicore/mcdwidgets/index-debug.html'),...
            '&ui=suggestions',...
            '&model=',modelName,...
            '&regionnames=',regionNames,...
            '&hassuggestions=',hasSuggestion,...
            '&suggestedlatencies=',suggestedLatencies]
        end
    end
end


