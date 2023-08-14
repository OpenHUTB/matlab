classdef(Abstract)CreateConfigurationInterface<handle



    properties(GetAccess=public,SetAccess=public)
CreateDataStrategy
CalculatePathStrategy
FileDependencyStrategy
VariableDependencyStrategy
StoreElementsStrategy
    end

    methods

        function set.CreateDataStrategy(obj,createDataStrategy)
            validateattributes(createDataStrategy,...
            {'restorepoint.internal.create.CreateDataStrategy'},{'nonempty'});
            obj.CreateDataStrategy=createDataStrategy;
        end

        function set.CalculatePathStrategy(obj,calculatePathStrategy)
            validateattributes(calculatePathStrategy,...
            {'restorepoint.internal.create.CalculatePathStrategy'},{'nonempty'});
            obj.CalculatePathStrategy=calculatePathStrategy;
        end

        function set.FileDependencyStrategy(obj,fileDependencyStrategy)
            validateattributes(fileDependencyStrategy,...
            {'restorepoint.internal.create.FileDependencyStrategy'},{'nonempty'});
            obj.FileDependencyStrategy=fileDependencyStrategy;
        end

        function set.VariableDependencyStrategy(obj,variableDependencyStrategy)
            validateattributes(variableDependencyStrategy,...
            {'restorepoint.internal.create.VariableDependencyStrategy'},{'nonempty'});
            obj.VariableDependencyStrategy=variableDependencyStrategy;
        end

        function set.StoreElementsStrategy(obj,storeElementsStrategy)
            validateattributes(storeElementsStrategy,...
            {'restorepoint.internal.create.StoreElementsStrategy'},{'nonempty'});
            obj.StoreElementsStrategy=storeElementsStrategy;
        end
    end
end


