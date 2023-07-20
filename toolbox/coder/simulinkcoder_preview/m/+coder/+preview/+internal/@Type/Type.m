classdef Type<handle




    properties
TypeName
    end

    methods
        function obj=Type(typeName)

            obj.TypeName=typeName;
        end

        function out=getPreview(obj)




            switch obj.TypeName
            case 'double'
                out='real_T';
            case 'single'
                out='real32_T';
            case 'uint32'
                out='uint32_T';
            case 'uint16'
                out='uint16_T';
            case 'uint8'
                out='uint8_T';
            case 'int32'
                out='int32_T';
            case 'int16'
                out='int16_T';
            case 'int8'
                out='int8_T';
            otherwise
                out=obj.TypeName;
            end
        end
    end
end
