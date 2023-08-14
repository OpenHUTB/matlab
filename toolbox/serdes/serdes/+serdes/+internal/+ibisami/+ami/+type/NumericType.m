classdef(Abstract)NumericType<serdes.internal.ibisami.ami.type.AmiType




    methods
        function isLessThan=isLessThan(type,value1,value2)
            isLessThan=type.verifyValueForType(value1)&&...
            type.verifyValueForType(value2)&&...
            str2double(value1)<str2double(value2);
        end
        function isEqual=isEqual(type,value1,value2)
            isEqual=type.verifyValueForType(value1)&&...
            type.verifyValueForType(value2)&&...
            str2double(value1)==str2double(value2);
        end
        function isGreaterThan=isGreaterThan(type,value1,value2)
            isGreaterThan=~type.isLessThan(value1,value2)&&...
            ~type.isEqual(value1,value2);
        end
    end
end

