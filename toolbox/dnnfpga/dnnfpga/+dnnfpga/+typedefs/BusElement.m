classdef BusElement<dnnfpga.typedefs.AbstractTypeDef
    properties
Name
Dimensions
DimensionsMode
DataType
Complexity
    end

    methods
        function obj=BusElement(name,dataType,varargin)
            if nargin<2
                error("Both a name and a data type must be specified.");
            end
            obj.Name=name;

            if nargin==3


                obj.Dimensions=varargin{1};
                obj.DimensionsMode='Fixed';
                obj.Complexity='real';
            else
                p=inputParser;

                addParameter(p,'Dimensions',1,@isnumeric)
                addParameter(p,'DimensionsMode','Fixed',@ischar)
                addParameter(p,'Complexity','real',@ischar)

                parse(p,varargin{:});

                obj.Dimensions=p.Results.Dimensions;
                obj.DimensionsMode=p.Results.DimensionsMode;
                obj.Complexity=p.Results.Complexity;
            end

            hwt=dnnfpga.typedefs.TypeDefs.getInstance();
            try
                typeObject=hwt.tc.All(dataType);
                obj.DataType=typeObject();
            catch
                typeObject=dnnfpga.typedefs.Scalar(dataType);
                obj.DataType=typeObject();
            end
        end
        function value=defaultValue(obj)
            value=repmat(obj.DataType.defaultValue(),obj.Dimensions);

        end
    end
end
