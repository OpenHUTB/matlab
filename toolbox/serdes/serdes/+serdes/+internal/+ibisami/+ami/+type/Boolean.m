classdef Boolean<serdes.internal.ibisami.ami.type.AmiType

...
...
...
...
...
...



    properties(Constant)
        Name="Boolean";
        CType="bool";
        TemplateType="ami_string_type";
    end
    methods
        function obj=Boolean()

        end

    end
    methods

        function verificationResult=verifyValueForType(type,value)
...
...
...
...
...
            verificationResult=false;
            if~type.verifyValue(value)
                return
            end
            if~isequal(value,"True")&&~isequal(value,"False")&&...
                ~isequal(value,"true")&&~isequal(value,"false")



                return
            end
            verificationResult=true;
        end
        function isEqual=isEqual(type,value1,value2)
            isEqual=type.verifyValueForType(value1)&&...
            type.verifyValueForType(value2)&&...
            strcmpi(value1,value2);
        end
        function convertedValue=convertStringValueToType(~,value)
            convertedValue=strcmpi(value,"true");
        end
        function amiValue=convertToAmiValue(~,value)
...
...
...
...
...
            if islogical(value)&&isscalar(value)
                if(value)
                    amiValue="True";
                else
                    amiValue="False";
                end
            elseif strcmpi(value,"true")
                amiValue="True";
            elseif strcmpi(value,"false")
                amiValue="False";
            else
                amiValue=string(value);
                warning(message('serdes:ibis:NotRecognized',amiValue,'Boolean'))
            end
        end
    end
end

