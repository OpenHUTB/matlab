classdef(Hidden)VisualizeTaskModel<handle






    properties(Hidden)
        ChartModel matlab.visualize.task.internal.model.ChartModel

        DataModel matlab.visualize.task.internal.model.DataModel

        OptionalParamModel matlab.visualize.task.internal.model.OptionalParamModel



TempDataMap

        OverlayAdded(1,1)logical
    end

    methods
        function obj=VisualizeTaskModel()
            obj.ChartModel=matlab.visualize.task.internal.model.ChartModel();

            obj.TempDataMap=containers.Map();

            obj.DataModel=matlab.visualize.task.internal.model.DataModel();

            obj.OptionalParamModel=matlab.visualize.task.internal.model.OptionalParamModel();
        end
    end

    methods(Hidden)

        function restoreDefaultModel(obj)
            obj.mapDataToChannels(-1);
            initialSearchTerm=obj.ChartModel.InitialSearchTerm;
            obj.OptionalParamModel=matlab.visualize.task.internal.model.OptionalParamModel();
            obj.ChartModel.SelectionIdx=-1;
            obj.ChartModel.CurrentSearchTerm=initialSearchTerm;
            obj.ChartModel.CurrentCategory=obj.ChartModel.DEFAULT_CATEGORY;
        end


        function setState(obj,state)
            try

                obj.ChartModel.deserializeChartsState(state.SelectedChartData,...
                state.CurrentCategory,state.CurrentSearchTerm,state.EnabledCharts);



                selChartIndex=obj.ChartModel.SelectionIdx;



                obj.updateOptionalParamModel(selChartIndex);


                obj.setDataModel(state.DataModel,selChartIndex);
            catch
            end
        end


        function setDataModel(obj,dataState,selChartIndex)


            remapChannels=false;
            channelMetaData=[];
            if selChartIndex>0
                channelConfigMap=obj.ChartModel.ChartMetaData{selChartIndex}.ChannelConfigurationMap;
                if~isempty(channelConfigMap)
                    selectedConfig='';
                    if isfield(dataState,'SelectedConfiguration')
                        selectedConfig=dataState.SelectedConfiguration;
                    else
                        dataState.ConfigurationNames=keys(channelConfigMap);
                    end
                    if isempty(selectedConfig)
                        selectedConfig=keys(channelConfigMap);
                        selectedConfig=selectedConfig{1};
                        dataState.SelectedConfiguration=selectedConfig;
                    end
                    channelMetaData=channelConfigMap(selectedConfig).Channels;
                else
                    channelMetaData=obj.ChartModel.ChartMetaData{selChartIndex}.Channels;
                end
                savedDataRows=dataState.MappedDataRows;
                if isempty(savedDataRows)
                    savedDataRows=dataState.DataRows;
                end
                if~isempty(savedDataRows)&&numel(savedDataRows)==numel(channelMetaData)
                    for i=1:numel(savedDataRows)
                        if~strcmpi(savedDataRows(i).MappedChannel.Name,channelMetaData(i).Name)
                            remapChannels=true;
                            break;
                        end
                    end
                else
                    remapChannels=true;
                end
            end


            if remapChannels
                obj.DataModel.deserializeDataState(dataState,[]);
                obj.mapDataToChannels(selChartIndex);
            else
                obj.DataModel.deserializeDataState(dataState,channelMetaData);
            end
        end

        function initModel(obj,overlayAdded)
            if nargin>1
                obj.OverlayAdded=overlayAdded;
            end
            obj.ChartModel.updateModel();
        end

        function updateModelForVizUpdate(obj)
            chartIndex=obj.ChartModel.SelectionIdx;

            obj.mapDataToChannels(chartIndex);
            obj.updateOptionalParamModel(chartIndex);
        end

        function updateOptionalParamModel(obj,chartIndex)
            obj.OptionalParamModel=matlab.visualize.task.internal.model.OptionalParamModel();
            vizParams=matlab.visualize.task.internal.model.OptionalParameters.empty();
            selectedParams=matlab.visualize.task.internal.model.OptionalParameters.empty();

            if chartIndex>0
                optionalParams=obj.ChartModel.ChartMetaData{chartIndex}.Parameters;
                for i=1:numel(optionalParams)
                    vizParams(i)=optionalParams(i);
                    if optionalParams(i).IsSelected
                        selectedParams(end+1)=optionalParams(i);%#ok<AGROW>
                    end
                end
            end
            obj.OptionalParamModel.updateParameters(vizParams,selectedParams);
        end

        function isValid=validateDataForChannel(obj,varName,varData,channel)
            isValid=false;

            channelTypes=channel.KeyType;
            if isKey(obj.TempDataMap,varName)
                validChannels=obj.TempDataMap(varName).Valid;
                if any(ismember(validChannels,channelTypes))
                    isValid=true;
                    return;
                elseif all(ismember(channelTypes,obj.TempDataMap(varName).Invalid))
                    isValid=false;
                    return;
                end
            end

            if~isempty(channel.CustomValidationFcn)
                isValid=hgfeval({channel.CustomValidationFcn},...
                varData,channel);
                if isValid
                    if isKey(obj.TempDataMap,varName)
                        channelStruct=obj.TempDataMap(varName);
                        channelStruct.Valid=[channelStruct.Valid,channel.CustomValidationFcn];
                        obj.TempDataMap(varName)=channelStruct;
                    else
                        obj.TempDataMap=[obj.TempDataMap;...
                        containers.Map(varName,struct('Valid',channel.CustomValidationFcn,'Invalid',string.empty))];
                    end
                else
                    if isKey(obj.TempDataMap,varName)
                        channelStruct=obj.TempDataMap(varName);
                        channelStruct.Invalid=[channelStruct.Invalid,channel.CustomValidationFcn];
                        obj.TempDataMap(varName)=channelStruct;
                    else
                        obj.TempDataMap=[obj.TempDataMap;...
                        containers.Map(varName,struct('Valid',string.empty,'Invalid',channel.CustomValidationFcn))];
                    end
                end
            else


                orig_state=warning('off','all');
                for i=1:numel(channelTypes)
                    keyTypes=channelTypes(i);
                    try
                        [attrClass,attrType]=matlab.visualize.task.internal.model.DataModel.cleanUpTypeAttributes(keyTypes);

                        validateattributes(varData,attrClass,attrType);
                        isValid=true;

                        if isKey(obj.TempDataMap,varName)
                            channelStruct=obj.TempDataMap(varName);
                            channelStruct.Valid=[channelStruct.Valid,channelTypes(i)];
                            obj.TempDataMap(varName)=channelStruct;
                        else
                            obj.TempDataMap=[obj.TempDataMap;...
                            containers.Map(varName,struct('Valid',channelTypes(i),'Invalid',string.empty))];
                        end
                        break;
                    catch
                        if isKey(obj.TempDataMap,varName)
                            channelStruct=obj.TempDataMap(varName);
                            channelStruct.Invalid=[channelStruct.Invalid,channelTypes(i)];
                            obj.TempDataMap(varName)=channelStruct;
                        else
                            obj.TempDataMap=[obj.TempDataMap;...
                            containers.Map(varName,struct('Valid',string.empty,'Invalid',channelTypes(i)))];
                        end
                    end
                end

                warning(orig_state);
            end
        end


        function allMatchingCharts=findMatchingVizForData(obj)

            dataRows=obj.DataModel.getAllSelectedDataRows();
            numSelectedRows=numel(dataRows);
            rowData=cell.empty(numSelectedRows,0);
            for i=1:numSelectedRows
                rowData{i}=matlab.visualize.task.internal.model.DataModel.getEvaluatedData(dataRows(i).VariableName);
            end

            allMatchingCharts=string.empty();


            for i=1:numSelectedRows
                if isa(rowData{i},'struct')||isa(rowData{i},'handle')||...
                    isa(rowData{i},'containers.Map')||...
                    isa(rowData{i},'timeseries')
                    return;
                end
            end
            chartsData=obj.ChartModel.ChartMetaData;
            if obj.OverlayAdded
                idx=cellfun(@(x)x.SupportsOverlay,chartsData);
                chartsData=chartsData(idx);
            end
            if isempty(dataRows)
                allMatchingCharts=cellfun(@(x)x.Name,chartsData,'UniformOutput',false);
                return;
            end
            for k=1:numel(chartsData)
                if obj.OverlayAdded&&~chartsData{k}.SupportsOverlay
                    continue;
                end

                dataRows=obj.DataModel.getAllSelectedDataRows();
                chartName=chartsData{k}.Name;

                channelConfigMap=chartsData{k}.ChannelConfigurationMap;


                if~isempty(channelConfigMap)
                    channelConfigs=keys(channelConfigMap);
                    for i=1:numel(channelConfigs)
                        channels=channelConfigMap(channelConfigs{i}).Channels;
                        foundMatching=obj.findMatchingChartChannel(chartName,dataRows,channels,numSelectedRows,rowData);
                        if foundMatching
                            break;
                        end
                    end
                else
                    channels=chartsData{k}.Channels;
                    foundMatching=obj.findMatchingChartChannel(chartName,dataRows,channels,numSelectedRows,rowData);
                end



                if foundMatching
                    allMatchingCharts(end+1)=chartName;%#ok<AGROW>
                end
            end
        end



        function foundMatching=findMatchingChartChannel(obj,chartName,dataRows,channels,numSelectedRows,rowData)
            numDataRows=numel(dataRows);
            foundMatching=false;
            if numDataRows<numel(channels)


                for m=1:(numel(channels)-numDataRows)
                    dataRows(end+1)=matlab.visualize.task.internal.model.DataProperties();%#ok<AGROW>
                    rowData{end+1}=[];
                end
            elseif numDataRows>numel(channels)



                return;
            end
            varPerms=flip(perms(1:numel(dataRows)));
            sz=size(varPerms);

            [~,id]=sort(arrayfun(@(x)x.IsRequired,channels),'descend');

            channels=channels(id);

            for i=1:sz(1)
                numMapped=0;
                for j=1:numel(channels)
                    channel=channels(j);

                    rowDataVar=dataRows(varPerms(i,j)).VariableName;

                    irowData=rowData{varPerms(i,j)};
                    if(dataRows(varPerms(i,j)).IsTabular&&strcmpi(rowDataVar,'select variable'))||...
                        (~strcmpi(rowDataVar,'select variable')&&...
                        ((ismember(chartName,{'stackedplot','parallelplot'})&&isa(irowData,'tabular'))||...
                        obj.validateDataForChannel(rowDataVar,irowData,channel)))
                        numMapped=numMapped+1;
                    end
                end
                if numMapped==numSelectedRows
                    foundMatching=true;
                    break;
                end
            end
        end


        function mapDataToChannels(obj,chartIndex)
            dataRows=obj.DataModel.getAllSelectedDataRowsForMapping();
            obj.DataModel.doCreateMappings=false;
            obj.DataModel.ConfigurationNames=string.empty();
            obj.DataModel.SelectedConfiguration=string.empty();
            if chartIndex>0
                chartMetaData=obj.ChartModel.ChartMetaData{chartIndex};
                chartName=chartMetaData.Name;



                channelConfigMap=chartMetaData.ChannelConfigurationMap;
                if~isempty(channelConfigMap)
                    obj.mapConfigurationChannels(chartName,dataRows,channelConfigMap);
                else
                    channels=chartMetaData.Channels;
                    newDataRows=obj.doChannelMappings(channels,dataRows);

                    obj.updateDataModel(chartName,channels,newDataRows);
                end
            else
                for i=1:numel(dataRows)
                    if~isempty(dataRows(i).MappedChannel)
                        dataRows(i).MappedChannel.DataMapped='select variable';
                        dataRows(i).MappedChannel=matlab.visualize.task.internal.model.VisualChannelModel.empty();
                    end
                    if obj.DataModel.ShowAllVariables&&strcmpi(dataRows(i).WorkspaceVarName,dataRows(i).VariableName)
                        dataRows(i).VariableName='select variable';
                    end
                end
                obj.DataModel.DataRows=dataRows;
                obj.DataModel.MappedDataRows=matlab.visualize.task.internal.model.DataProperties.empty();
                obj.DataModel.ShowAllVariables=false;
            end
        end

        function mapConfigurationChannels(obj,chartName,dataRows,channelConfigMap)
            channelConfigNames=keys(channelConfigMap);

            obj.DataModel.ConfigurationNames=channelConfigNames;
            obj.DataModel.hasConfigurationError=false;


            cnfigData=values(channelConfigMap);
            selectedConfigIdx=cellfun(@(x)x.IsSelected,cnfigData);
            hasConfigSelected=any(selectedConfigIdx);
            if hasConfigSelected

                channelConfigNames=channelConfigNames(selectedConfigIdx);
            else


                [~,id]=sort(cellfun(@(x)numel(x.Channels),cnfigData));
                channelConfigNames=channelConfigNames(id);
            end
            updatedDataModel=false;
            for i=1:numel(channelConfigNames)
                channels=channelConfigMap(channelConfigNames{i}).Channels;
                [newDataRows,foundNewMapping]=obj.doChannelMappings(channels,dataRows);

                if foundNewMapping||hasConfigSelected

                    updatedDataModel=true;
                    obj.updateDataModel(chartName,channels,newDataRows);
                    break;
                end
            end


            if~foundNewMapping
                obj.DataModel.hasConfigurationError=true;
            end
            if~updatedDataModel






                obj.updateDataModel(chartName,channels,newDataRows);
            end
        end

        function updateDataModel(obj,chartName,channels,newDataRows)

            dtRows=matlab.visualize.task.internal.model.DataProperties.empty(0,numel(channels));
            for k=1:numel(channels)
                for j=1:numel(newDataRows)
                    if isequal(newDataRows(j).MappedChannel,channels(k))
                        dtRows(k)=newDataRows(j);
                        break;
                    end
                end
            end

            obj.DataModel.MappedDataRows=dtRows;
            if ismember(chartName,{'stackedplot','parallelplot'})
                obj.DataModel.ShowAllVariables=true;
            else
                obj.DataModel.ShowAllVariables=false;
            end
        end

        function[newDataRows,foundNewMapping]=doChannelMappings(obj,channels,dataRows)
            hasMappings=any(arrayfun(@(x)~isempty(x.MappedRow),channels))&&~isempty(obj.DataModel.MappedDataRows);
            foundNewMapping=true;
            isCacheValid=true;
            if hasMappings
                isCacheValid=any(arrayfun(@(x)isequal(x.MappedRow.CacheCounter,obj.DataModel.CacheCounter),channels));
            end

            initialNumRows=numel(dataRows);

            numDataRows=numel(dataRows);
            if numDataRows<numel(channels)
                for m=1:(numel(channels)-numDataRows)
                    dataRows(end+1)=matlab.visualize.task.internal.model.DataProperties();%#ok<AGROW>
                end
            elseif numel(channels)<numDataRows
                foundNewMapping=false;
            end



            if hasMappings&&isCacheValid
                newDataRows=matlab.visualize.task.internal.model.DataProperties.empty(0,numel(channels));
                for i=1:numel(channels)
                    channel=channels(i);
                    if~isempty(channel.MappedRow)
                        newDataRows(i).WorkspaceVarName=channel.MappedRow.WorkspaceVarName;
                        newDataRows(i).VariableName=channel.MappedRow.VariableName;
                        newDataRows(i).IsTabular=channel.MappedRow.IsTabular;



                    end
                    newDataRows(i).MappedChannel=channel;
                    newDataRows(i).MappedChannel.DataMapped=newDataRows(i).VariableName;
                end
            else
                [newDataRows,foundNewMapping]=createNewMapping(obj,dataRows,channels,initialNumRows);
            end
        end

        function[newDataRows,foundNewMapping]=createNewMapping(obj,dataRows,channels,initialNumRows)
            obj.DataModel.doCreateMappings=true;

            [~,id]=sort(arrayfun(@(x)x.IsRequired,channels),'descend');

            channels=channels(id);
            foundNewMapping=false;

            varPerms=flip(perms(1:numel(dataRows)));
            sz=size(varPerms);
            newDataRows=matlab.visualize.task.internal.model.DataProperties.empty(0,numel(channels));
            for i=1:sz(1)
                newDataRows=matlab.visualize.task.internal.model.DataProperties.empty(0,numel(channels));
                numMapped=0;
                for j=1:numel(channels)
                    channel=channels(j);
                    newDataRows(j)=matlab.visualize.task.internal.model.DataProperties();
                    dataRowInfo=dataRows(varPerms(i,j));
                    rowDataVar=dataRowInfo.VariableName;
                    newDataRows(j).MappedChannel=channel;
                    newDataRows(j).MappedChannel.DataMapped=newDataRows(j).VariableName;




                    if strcmpi(dataRowInfo.WorkspaceVarName,rowDataVar)&&~channel.IsRequired&&isa(...
                        matlab.visualize.task.internal.model.DataModel.getEvaluatedData(dataRowInfo.WorkspaceVarName),...
                        'tabular')
                        continue;
                    else
                        try
                            if(dataRowInfo.IsTabular&&strcmpi(rowDataVar,'select variable'))||...
                                (~strcmpi(rowDataVar,'select variable')&&...
                                obj.DataModel.filterWorkspaceVariables(matlab.visualize.task.internal.model.DataModel.getEvaluatedData(rowDataVar),channel))
                                numMapped=numMapped+1;
                                newDataRows(j).WorkspaceVarName=dataRowInfo.WorkspaceVarName;
                                newDataRows(j).VariableName=dataRowInfo.VariableName;
                                newDataRows(j).IsTabular=dataRowInfo.IsTabular;
                                newDataRows(j).MappedChannel.DataMapped=newDataRows(j).VariableName;
                            end
                        catch
                        end
                    end
                end
                if numMapped==initialNumRows
                    foundNewMapping=true;
                    break;
                end
            end
        end


        function updateChannelsForConfiguration(obj)
            chartIndex=obj.ChartModel.SelectionIdx;
            selectedConfig=obj.DataModel.SelectedConfiguration;
            chartMetaData=obj.ChartModel.ChartMetaData{chartIndex};
            channels=chartMetaData.ChannelConfigurationMap(selectedConfig).Channels;

            configNames=keys(chartMetaData.ChannelConfigurationMap);
            for i=1:numel(configNames)
                chConfig=chartMetaData.ChannelConfigurationMap(configNames{i});
                chConfig.IsSelected=strcmp(configNames{i},selectedConfig);
                chartMetaData.ChannelConfigurationMap(configNames{i})=chConfig;
            end

            dataRows=obj.DataModel.getAllSelectedDataRowsForMapping();
            obj.DataModel.doCreateMappings=false;
            [newDataRows,foundNewMapping]=obj.doChannelMappings(channels,dataRows);


            obj.updateDataModel(chartMetaData.Name,channels,newDataRows);


            if foundNewMapping
                obj.DataModel.hasConfigurationError=false;
            else
                obj.DataModel.hasConfigurationError=true;
            end
        end
    end
end