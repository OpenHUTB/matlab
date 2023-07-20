classdef LogTypeInfo<matlab.mixin.Copyable
    properties
Typename
Dimension
Complexity
Numerictype
Fimath
FieldName
FieldTypesInfo
    end

    methods
        function this=LogTypeInfo()
            this.Typename='';
            this.Dimension=[];
            this.Complexity=[];
            this.Numerictype=numerictype;
            this.Fimath=hdlfimath;
            this.FieldName='';
            this.FieldTypesInfo=LogTypeInfo.empty();
        end
    end
end