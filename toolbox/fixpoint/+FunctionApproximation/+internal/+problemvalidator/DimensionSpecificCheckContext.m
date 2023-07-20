classdef(Sealed)DimensionSpecificCheckContext<handle






    properties(SetAccess=private)
Dimension
DataType
LowerBound
UpperBound
    end
    methods
        function this=DimensionSpecificCheckContext(problemDefinition,iDim)
            this.Dimension=iDim;
            this.DataType=problemDefinition.InputTypes(iDim);
            this.LowerBound=problemDefinition.InputLowerBounds(iDim);
            this.UpperBound=problemDefinition.InputUpperBounds(iDim);
        end
    end
end