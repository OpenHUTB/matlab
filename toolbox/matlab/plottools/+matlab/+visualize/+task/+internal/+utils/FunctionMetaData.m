classdef(Hidden)FunctionMetaData<handle








    properties(Hidden)

RawMetaData

FilterdByCategoryMap


ParsedMetaData
    end

    properties(Hidden)
        UseOverlayFeature(1,1)logical=true
    end

    events(Hidden)


FunctionMetaDataUpdated
    end

    methods(Static,Hidden)

        function h=getInstance()
mlock
            persistent hFunctionMetaData;
            if isempty(hFunctionMetaData)
                hFunctionMetaData=matlab.visualize.task.internal.utils.FunctionMetaData();
            end
            h=hFunctionMetaData;
        end



        function hasRegFWKLoaded=hasMetadataLoaded()
            hFunctionMetaData=matlab.visualize.task.internal.utils.FunctionMetaData.getInstance();
            hasRegFWKLoaded=~isempty(hFunctionMetaData.RawMetaData);
        end

        function updateParsedMetaData(parsedMetaData,filterByCategoryMap)
            hFunctionMetaData=matlab.visualize.task.internal.utils.FunctionMetaData.getInstance();

            hFunctionMetaData.FilterdByCategoryMap=filterByCategoryMap;
            for i=1:numel(parsedMetaData)
                hFunctionMetaData.ParsedMetaData{i}=copy(parsedMetaData{i});
            end
        end




        function updateMetaData(resourceFilePaths)
            hFunctionMetaData=matlab.visualize.task.internal.utils.FunctionMetaData.getInstance();
            if isempty(hFunctionMetaData.RawMetaData)
                functionMetaData=jsondecode(resourceFilePaths).functionMetaData;
                hFunctionMetaData.RawMetaData=matlab.visualize.task.internal.utils.getJSONMetadataFromFiles(functionMetaData);
                notify(hFunctionMetaData,'FunctionMetaDataUpdated');
            end
        end


        function updateMetaDataForTesting(resourceFilePaths)
            hFunctionMetaData=matlab.visualize.task.internal.utils.FunctionMetaData.getInstance();
            if isempty(hFunctionMetaData.RawMetaData)
                hFunctionMetaData.RawMetaData=matlab.visualize.task.internal.utils.getJSONMetadataFromFiles(resourceFilePaths);
                notify(hFunctionMetaData,'FunctionMetaDataUpdated');
            end
        end
    end
end