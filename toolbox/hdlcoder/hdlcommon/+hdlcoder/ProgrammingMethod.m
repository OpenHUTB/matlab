


classdef ProgrammingMethod


    enumeration
JTAG
Custom
Download
    end

    methods(Static)

        function stringValue=convertToString(enumValue)


            stringValue=string(enumValue);
            stringValue=convertStringsToChars(stringValue);



























        end

        function enumValue=convertToEnum(stringValue)

            enumValue=hdlcoder.ProgrammingMethod(stringValue);











        end

    end

end

