classdef(Hidden)ChartModel<handle






    properties
        ChartMetaData={}

FilterByCategoryMap

        SelectionIdx=-1

        CurrentSearchTerm=''

        CurrentCategory=''

        InitialSearchTerm='';


        EnabledCharts=[]
    end

    properties(Constant)
        DEFAULT_CATEGORY=getString(message('MATLAB:graphics:visualizedatatask:AllLabel'))
    end

    methods
        function obj=ChartModel()
            obj.CurrentCategory=obj.DEFAULT_CATEGORY;
        end

        function deserializeChartsState(obj,chartData,category,searchTerm,enabledCharts)
            obj.CurrentSearchTerm=searchTerm;


            if ismember(category,keys(obj.FilterByCategoryMap))
                obj.CurrentCategory=category;
            end
            allCharts=cellfun(@(x)x.Name,obj.ChartMetaData,'UniformOutput',false);

            obj.SelectionIdx=-1;
            if~isempty(chartData)
                idx=find(ismember(allCharts,chartData.Name));
                if~isempty(idx)
                    obj.SelectionIdx=idx;
                    obj.ChartMetaData{obj.SelectionIdx}.deserializeChartParameters(chartData);
                end
            end



            obj.EnabledCharts=allCharts(ismember(allCharts,enabledCharts));
        end


        function updateModel(obj)


            funcMetaData=matlab.visualize.task.internal.utils.FunctionMetaData.getInstance();
            if~isempty(funcMetaData.ParsedMetaData)
                obj.FilterByCategoryMap=containers.Map(funcMetaData.FilterdByCategoryMap.keys,...
                funcMetaData.FilterdByCategoryMap.values);
                parsedData=funcMetaData.ParsedMetaData;
                for i=1:numel(parsedData)
                    obj.ChartMetaData{i}=copy(parsedData{i});
                end
                obj.EnabledCharts=cellfun(@(x)x.Name,obj.ChartMetaData,'UniformOutput',false);
                return;
            end
            rawMetaData=funcMetaData.RawMetaData;
            obj.FilterByCategoryMap=containers.Map();
            if isempty(rawMetaData)
                return;
            end
            tempMap=containers.Map();
            for i=1:numel(rawMetaData)
                chartName=rawMetaData(i).Name;
                if contains(chartName,'_')


                    chartName=extractBefore(chartName,'_');
                end
                chartState=obj.parseMetaData(tempMap,chartName,rawMetaData(i).MetaData);
                categoryNames=cellstr(chartState.Categories);
                for j=1:numel(categoryNames)
                    categoryName=getString(message(categoryNames{j}));
                    if isKey(obj.FilterByCategoryMap,categoryName)
                        charts=obj.FilterByCategoryMap(categoryName);
                        charts.Charts=[charts.Charts,chartName];
                        obj.FilterByCategoryMap(categoryName)=charts;
                    else
                        obj.FilterByCategoryMap=[obj.FilterByCategoryMap;containers.Map(categoryName,struct("Name",categoryName,"Charts",string(chartName)))];
                    end
                end

                tempMap=[tempMap;containers.Map(chartName,chartState)];%#ok<AGROW>
            end



            orderedCharts=matlab.visualize.task.internal.utils.getAllVisualizations();
            allKeys=keys(tempMap);
            commonChartInd=ismember(orderedCharts,allKeys);
            orderedCharts=orderedCharts(commonChartInd);
            diffChartList=setdiff(allKeys,orderedCharts);
            for i=1:numel(orderedCharts)
                obj.ChartMetaData{i}=tempMap(orderedCharts(i));
                obj.ChartMetaData{i}.Index=i;
            end

            for j=1:numel(diffChartList)
                obj.ChartMetaData{end+1}=tempMap(diffChartList(j));
                obj.ChartMetaData{end}.Index=i+j;
            end
            clear tempMap;
            funcMetaData.updateParsedMetaData(obj.ChartMetaData,containers.Map(obj.FilterByCategoryMap.keys,...
            obj.FilterByCategoryMap.values));
            obj.EnabledCharts=cellfun(@(x)x.Name,obj.ChartMetaData,'UniformOutput',false);
        end
    end

    methods(Static,Hidden)

        function chartState=parseMetaData(tempMap,chartName,chartMetaData)


            visualizationInfo=chartMetaData.taskInfo.VisualizeTaskInfo;
            if isKey(tempMap,chartName)
                chartState=tempMap(chartName);
            else
                chartState=matlab.visualize.task.internal.model.ChartProperties();
                chartState.Name=chartName;
            end

            if isfield(visualizationInfo,'validateDataFunction')
                chartState.validateDataFunction=hgcastvalue('matlab.graphics.datatype.Callback',visualizationInfo.validateDataFunction);
            end

            if isfield(visualizationInfo,'params')

                params=visualizationInfo.params;
                configurationName=string.empty();
                if isfield(visualizationInfo,'configuration')
                    configurationName=visualizationInfo.configuration;
                end
                chartState=matlab.visualize.task.internal.model.ChartModel.updateParameters(chartState,chartMetaData.inputs,params,configurationName);
            end

            if isfield(visualizationInfo,'icon')
                iconRelPath=visualizationInfo.icon;
                jsonFilePath=chartMetaData.fileName;
                chartState.Icon=matlab.visualize.task.internal.utils.getURLForFilePath(jsonFilePath,iconRelPath);
            end

            if isfield(visualizationInfo,'categories')
                chartState.Categories=cellstr(visualizationInfo.categories);
                chartState.Categories{end+1}='MATLAB:graphics:visualizedatatask:AllLabel';
            else
                chartState.Categories='MATLAB:graphics:visualizedatatask:AllLabel';
            end

            if isfield(visualizationInfo,'description')
                chartState.Description=visualizationInfo.description;
            end

            if isfield(visualizationInfo,'keywords')
                chartState.Keywords=visualizationInfo.keywords;
            end

            if isfield(visualizationInfo,'codeFunction')
                chartState.CodeGenFunction=hgcastvalue('matlab.graphics.datatype.Callback',visualizationInfo.codeFunction);
            end


            if isfield(chartMetaData,'outputs')&&...
                ~any(strcmpi(chartState.Categories,'matlab:graphics:visualizedatatask:SignalProcessingLabel'))
                chartState.Outputs=chartMetaData.outputs;
            end


            if isfield(visualizationInfo,'supportsOverlay')
                chartState.SupportsOverlay=visualizationInfo.supportsOverlay;
            end

            chartState.createChannelConfigurationMap();








        end


        function chartState=updateParameters(chartState,chartInputs,params,configurationName)
            for i=1:numel(params)
                if iscell(params)
                    param=params{i};
                else
                    param=params(i);
                end

                if isfield(param,'name')
                    description=param.name;
                    if isfield(param,'description')
                        description=param.description;
                        if contains(description,":")
                            description=getString(message(description));
                        end
                    end
                    if isfield(param,'kind')
                        defaultVal=0;
                        if isfield(param,'default')
                            defaultVal=param.default;
                        end
                        channelData=matlab.visualize.task.internal.model.OptionalParameters(param.name,description,param.type,defaultVal);
                        chartState.Parameters(end+1)=channelData;
                    else
                        channelData=matlab.visualize.task.internal.model.VisualChannelModel(param.name,description);
                        channelData=findChannelData(channelData,chartInputs);
                        if contains(configurationName,":")
                            configurationName=getString(message(configurationName));
                        end
                        channelData.ConfigurationName=configurationName;
                        channelData.CustomValidationFcn=chartState.validateDataFunction;
                        if isfield(param,'optional')
                            channelData.IsRequired=false;
                        end
                        channelType=channelData.Type;
                        if~iscell(channelType)
                            channelType={channelType};
                        end

                        for j=1:numel(channelType)
                            cType=string(channelType{j});
                            if numel(cType)>1
                                cType=join(cType);
                            end
                            if~isempty(cType)
                                channelData.KeyType(end+1)=cType;
                            end
                        end
                        chartState.Channels(end+1)=channelData;
                    end
                end
            end
        end
    end
end

function channelData=findChannelData(channelData,inputArgs)
    for i=1:numel(inputArgs)
        if iscell(inputArgs)
            inputInfo=inputArgs{i};
        else
            inputInfo=inputArgs(i);
        end
        if isfield(inputInfo,'name')&&strcmpi(channelData.Name,inputInfo.name)
            channelData.Type=inputInfo.type;
            if isfield(inputInfo,'kind')
                channelData.IsRequired=strcmpi(inputInfo.kind,'required');
            end
            return
        elseif isfield(inputInfo,'mutuallyExclusiveGroup')
            if~iscell(inputInfo.mutuallyExclusiveGroup)
                inputInfo.mutuallyExclusiveGroup={inputInfo.mutuallyExclusiveGroup};
            end
            for j=1:numel(inputInfo.mutuallyExclusiveGroup)
                channelData=findChannelData(channelData,inputInfo.mutuallyExclusiveGroup{j});
                if~isempty(channelData.Type)
                    return
                end
            end
        elseif isfield(inputInfo,'repeating')
            channelData.hasTuple=true;
            for j=1:numel(inputInfo.tuple)
                channelData=findChannelData(channelData,inputInfo.tuple(j));
                if~isempty(channelData.Type)
                    return
                end
            end
        end
    end
end