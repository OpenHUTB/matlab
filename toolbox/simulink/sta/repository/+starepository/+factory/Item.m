classdef Item<starepository.factory.PluggableSignalFactory









    methods(Abstract)
        createSignalItemWithoutProperties(obj)
        createSignalItemWithoutChildren(obj)
        buildProperties(obj)
    end

    methods(Access='protected')
        function obj=Item

        end
    end
    methods
        function SignalItem=createSignalItem(obj)
            SignalItem=obj.createSignalItemWithoutProperties();
            if~isempty(SignalItem)
                SignalItem.Properties=obj.buildProperties();
            end
        end

        function SignalItem=createTopLevelSignalItem(obj)
            SignalItem=obj.createSignalItemWithoutChildren();
            if~isempty(SignalItem)
                SignalItem.Properties=obj.buildProperties();
            end
        end
    end
end

