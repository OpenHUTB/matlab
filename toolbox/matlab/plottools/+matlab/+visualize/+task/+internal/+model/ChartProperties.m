classdef(Hidden)ChartProperties<matlab.mixin.Copyable





    properties
Name
        Icon string=string.empty
        Description string=string.empty
Categories
        Keywords string=string.empty
        CodeGenFunction matlab.internal.datatype.matlab.graphics.datatype.Callback=''
        validateDataFunction matlab.internal.datatype.matlab.graphics.datatype.Callback=''
Outputs
        Channels matlab.visualize.task.internal.model.VisualChannelModel
        Parameters matlab.visualize.task.internal.model.OptionalParameters
        IsEnable(1,1)logical=true
Index
        Relevance=0
ChannelConfigurationMap
        SupportsOverlay(1,1)logical=true
    end

    methods(Access=protected)
        function cp=copyElement(obj)
            cp=copyElement@matlab.mixin.Copyable(obj);
            cp.Channels=copy(obj.Channels);
            cp.Parameters=copy(obj.Parameters);
            if~isempty(obj.ChannelConfigurationMap)

                cp.createChannelConfigurationMap();
            end
        end
    end

    methods

        function obj=ChartProperties()
        end

        function createChannelConfigurationMap(obj)
            if~isempty(obj.Channels(1).ConfigurationName)
                obj.ChannelConfigurationMap=containers.Map();
                for i=1:numel(obj.Channels)
                    channelData=obj.Channels(i);
                    configName=channelData.ConfigurationName;
                    if isKey(obj.ChannelConfigurationMap,configName)
                        configChannelData=obj.ChannelConfigurationMap(configName);
                        configChannelData.Channels=[configChannelData.Channels,channelData];
                        obj.ChannelConfigurationMap(configName)=configChannelData;
                    else
                        obj.ChannelConfigurationMap=[obj.ChannelConfigurationMap;containers.Map(configName,struct("Channels",channelData,"IsSelected",false))];
                    end
                end
            end
        end


        function deserializeChartParameters(obj,chartStruct)
            if~isempty(obj.ChannelConfigurationMap)
                if isfield(chartStruct,'ChannelConfigurationMap')
                    chartStructChannels=cellfun(@(x)(chartStruct.ChannelConfigurationMap.(x)),fieldnames(chartStruct.ChannelConfigurationMap));
                    channelConfigs=keys(obj.ChannelConfigurationMap);
                    for i=1:numel(channelConfigs)
                        configChannelData=obj.ChannelConfigurationMap(channelConfigs{i});
                        channels=configChannelData.Channels;
                        chartStructChannelI=chartStructChannels(i).Channels;
                        configChannelData.IsSelected=chartStructChannels(i).IsSelected;
                        for j=1:numel(chartStructChannelI)
                            channels(j).DataMapped=chartStructChannelI(j).DataMapped;
                        end
                        obj.ChannelConfigurationMap(channelConfigs{i})=configChannelData;
                    end
                end
            else
                if isempty(chartStruct.Channels)
                    obj.Channels=matlab.visualize.task.internal.model.VisualChannelModel.empty();
                else
                    for i=1:numel(obj.Channels)
                        obj.Channels(i).DataMapped=chartStruct.Channels(i).DataMapped;
                    end
                end
            end

            for i=1:numel(obj.Parameters)
                existingParam=obj.Parameters(i);
                for j=1:numel(chartStruct.Parameters)
                    savedParam=chartStruct.Parameters(j);
                    if strcmp(existingParam.Name,savedParam.Name)
                        existingParam.IsSelected=savedParam.IsSelected;
                        existingParam.SelectedValue=savedParam.SelectedValue;
                        break;
                    end
                end
            end
        end
    end
end