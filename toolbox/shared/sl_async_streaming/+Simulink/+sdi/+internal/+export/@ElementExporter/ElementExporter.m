classdef ElementExporter<handle




    methods(Abstract)
        ret=getDomainType(this);
        ret=exportElement(this,ret,dataStruct);
    end

end
