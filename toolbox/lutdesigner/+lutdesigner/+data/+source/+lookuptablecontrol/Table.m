classdef Table<lutdesigner.data.source.lookuptablecontrol.PropertyAccessStrategy

    properties(SetAccess=immutable)
Identifier
    end

    methods
        function this=Table
            this.Identifier='Table';
        end

        function control=getControl(~,lookupTableControl)
            control=lookupTableControl.Table;
        end
    end
end
