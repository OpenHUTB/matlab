classdef UddUtil<matlab.mixin.SetGet&matlab.mixin.Copyable



    methods
        function this=UddUtil
        end
    end

    methods(Hidden)

        strRep=Bool2MaskEnum(this,boolVal)
        posArray=EnumByPosArray(this,typeName)
        strStruct=EnumByStrStruct(this,typeName)
        strRep=EnumInt2Str(this,typeName,intRep)
        intRep=EnumStr2Int(this,typeName,strRep)
        boolVal=MaskEnum2Bool(this,maskEnum)
    end
end

