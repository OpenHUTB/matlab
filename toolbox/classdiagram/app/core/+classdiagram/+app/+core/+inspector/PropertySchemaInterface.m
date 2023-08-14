classdef PropertySchemaInterface<handle
    methods(Abstract)
        subProperties(obj,prop);
        hasSubProperties(obj,prop);
        propertyInfo(obj,prop)
        supportTabs(obj);
        defaultExpandGroups(obj);
        getDisplayLabel(obj);
    end
end

