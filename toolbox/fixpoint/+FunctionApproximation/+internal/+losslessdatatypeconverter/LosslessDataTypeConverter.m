classdef LosslessDataTypeConverter<handle




    methods(Abstract)
        [addUnit,newDBUnit]=convert(this,dbUnit,options)
    end
end

