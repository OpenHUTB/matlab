classdef PredefinedInterface<eda.internal.boardmanager.Interface

    methods
        function obj=PredefinedInterface
            obj=obj@eda.internal.boardmanager.Interface;
            obj.defineInterface;
        end

    end
    methods(Abstract)
        defineInterface(obj);
    end

end

