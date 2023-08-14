classdef PropertyAccessStrategy

    properties(Abstract,SetAccess=immutable)
Identifier
    end

    methods(Abstract)
        control=getControl(this,lookupTableControl)
    end
end
