classdef FactoryPluginManager<handle

















    properties(Access=private)


        PluginNames={...
'TimeSeriesItem'
        'ArrayOfBusItem';
        'BlockDataItem';
        'DataSetItem';
'SLTimeTableFactory'
        'FunctionCallItem';
'GroundOrPartialSpecificationItem'
'MATLABStructBusItem'
        'EmptyLoggedVariant';
        'ForEachSubSysItem';
'SaveToWorkspaceFormatArrayItem'
'SaveToWorkspaceFormatStructItem'
'SimulinkTimeSeriesItem'
'TSArrayBusItem'
'DefaultItem'
        }
    end


    methods


        function obj=FactoryPluginManager()

        end


        function pluginsFound=findPlugins(obj)
            pluginsFound=obj.PluginNames;
        end


        function supportedPlugin=getSupportedFactory(obj,name,data)
            supportedPlugin=[];


            for k=1:length(obj.PluginNames)

                if starepository.factory.(obj.PluginNames{k}).isSupported(data)
                    supportedPlugin=starepository.factory.(obj.PluginNames{k})(name,data);
                    return;
                end

            end
        end

    end

end

