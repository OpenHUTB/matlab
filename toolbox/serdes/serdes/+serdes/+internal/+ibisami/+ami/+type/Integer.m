classdef Integer<serdes.internal.ibisami.ami.type.NumericType





    properties(Constant)
        Name="Integer";
        CType="int";
        TemplateType="ami_int_type";
    end

    methods
        function obj=Integer()

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
...
            verificationResult=false;
            if~type.verifyValue(value)
                return
            end
            num=str2double(value);
            if~type.isAmiDouble(num)
                return
            end
            if rem(num,1)~=0
                return
            end
            if num<-2147483648||num>2147483647
                return
            end
            verificationResult=true;
        end
        function convertedValue=convertStringValueToType(~,value)
            convertedValue=round(str2double(value),0);
        end
        function amiValue=convertToAmiValue(type,value)
...
...
...
...
...
...
...
...
            amiValue=value;
            if~isa(amiValue,'double')
                amiValue=str2double(amiValue);
            end
            if type.isAmiDouble(amiValue)&&rem(amiValue,1)==0&&...
                amiValue>=-2147483648&&amiValue<=2147483647
                amiValue=string(amiValue);
            else
                warning(message('serdes:ibis:NotRecognized',string(value),'Integer'))
            end
        end
    end
end

