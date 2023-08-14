classdef Float<serdes.internal.ibisami.ami.type.NumericType




    properties(SetAccess=protected)
        Name="Float";
    end
    properties(Constant)
        CType="double"
        TemplateType="ami_double_type";
    end

    methods
        function obj=Float()

        end
    end
    methods

        function verificationResult=verifyValueForType(type,value)
...
...
...
...
...
...
...
            verificationResult=false;
            if~type.verifyValue(value)
                return
            end
            if~type.isAmiDouble(str2double(value))
                return
            end
            verificationResult=true;
        end
        function convertedValue=convertStringValueToType(~,value)
            convertedValue=str2double(value);
        end
        function amiValue=convertToAmiValue(type,pValue)
...
...
...
...
...
...
...
            amiValue=pValue;
            if~isa(amiValue,'double')
                amiValue=str2double(amiValue);
            end
            if type.isAmiDouble(amiValue)
                amiValue=string(amiValue);


            else
                warning(message('serdes:ibis:NotRecognized',string(pValue),'Float'))
            end
        end
    end
end

