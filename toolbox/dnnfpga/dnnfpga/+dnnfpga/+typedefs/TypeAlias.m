classdef TypeAlias<dnnfpga.typedefs.AbstractTypeDef

    properties
Name
BaseType
Description
    end

    methods
        function obj=TypeAlias(name,baseType)
            if nargin<2
                error("Both the name and the baseType must be specified.");
            else
                obj.Name=name;
                hwt=dnnfpga.typedefs.TypeDefs.getInstance();
                try
                    typeObject=hwt.tc.All(baseType);
                    obj.BaseType=typeObject;
                catch
                    typeObject=dnnfpga.typedefs.Scalar(baseType);
                    obj.BaseType=typeObject;
                end
                hwt.add(obj);
            end
        end
        function value=defaultValue(obj)
            value=obj.BaseType.defaultValue();
        end
    end
end
