classdef Scalar<dnnfpga.typedefs.AbstractTypeDef

    properties
Name
Value
    end

    methods
        function obj=Scalar(dataType)
            obj.Name=dataType;

            dataType=strrep(dataType,'boolean','logical');
            mc=meta.class.fromName(dataType);
            try
                ignore=mc.Name;
                obj.Value=cast(0,dataType);
            catch

                dataType=strrep(dataType,'fixdt','numerictype');
                try
                    evalValue=evalin('base',dataType);
                    if isa(evalValue,'embedded.numerictype')
                        obj.Value=fi(0,'DataTypeMode',evalValue.DataTypeMode,...
                        'Signedness',evalValue.Signedness,...
                        'WordLength',evalValue.WordLength,...
                        'FractionLength',evalValue.FractionLength);
                    else
                        try
                            error("Invalid data type '%s'.",dataType);
                        catch ME
                            throwAsCaller(ME);
                        end
                    end
                end
            end
            hwt=dnnfpga.typedefs.TypeDefs.getInstance();
            hwt.add(obj);
        end
        function value=defaultValue(obj)
            value=obj.Value;
        end
    end
end
