classdef Breakpoint<lutdesigner.data.source.lookuptablecontrol.PropertyAccessStrategy

    properties(SetAccess=immutable)
Identifier
    end

    properties(SetAccess=immutable,GetAccess=private)
DimensionIndex
    end

    methods
        function this=Breakpoint(dimensionIndex)
            this.Identifier=sprintf('Breakpoints(%.0f)',dimensionIndex);
            this.DimensionIndex=dimensionIndex;
        end

        function control=getControl(this,lookupTableControl)
            control=lookupTableControl.Breakpoints(this.DimensionIndex);
        end
    end
end
