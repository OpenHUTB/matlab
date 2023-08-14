classdef Enum<dnnfpga.typedefs.AbstractTypeDef

    properties
Name
EnumNames
NumValues
DefaultValue
Description
AddClassNameToEnumNames
StorageType
Value
    end

    methods
        function obj=Enum(name,enumNames,numVals,varargin)

            p=inputParser;

            addParameter(p,'Description','',@ischar)
            addParameter(p,'DefaultValue','',@ischar);
            addParameter(p,'AddClassNameToEnumNames',true,@islogical);
            addParameter(p,'StorageType','uint8')

            if nargin<2
                error("At least the name and the enumNames must be specied.");
            end

            obj.Name=name;
            obj.EnumNames=enumNames;

            parse(p,varargin{:});

            obj.Description=p.Results.Description;
            obj.DefaultValue=p.Results.DefaultValue;
            obj.StorageType=p.Results.StorageType;
            obj.AddClassNameToEnumNames=p.Results.AddClassNameToEnumNames;

            if nargin>=3&&~isempty(numVals)
                if numel(enumNames)~=numel(numVals)
                    error('Count of enum names and enum values must match.');
                end
                obj.NumValues=uint8(numVals);
            else
                numVals=[];
                count=numel(enumNames);
                for i=0:count-1
                    numVals=vertcat(numVals,uint8(i));
                end
                obj.NumValues=numVals;
            end
            obj.Value=dnnfpga.codegen.ENUM(name,obj.DefaultValue,enumNames,obj.NumValues);
            hwt=dnnfpga.typedefs.TypeDefs.getInstance();
            hwt.add(obj);
        end
        function value=defaultValue(obj)
            value=obj.Value;
        end
    end
end
