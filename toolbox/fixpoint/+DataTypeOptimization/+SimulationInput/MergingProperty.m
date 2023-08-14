classdef MergingProperty




    properties(SetAccess=private)
PropertyName
ConflictMode
    end

    methods
        function this=MergingProperty(propertyName,conflictMode)

            this.PropertyName=propertyName;
            this.ConflictMode=conflictMode;
        end
    end
end

