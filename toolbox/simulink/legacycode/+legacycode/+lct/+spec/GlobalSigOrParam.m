classdef GlobalSigOrParam<handle&matlab.mixin.Heterogeneous



    properties(SetAccess=immutable)
        VarSpec legacycode.lct.spec.FunctionArg
        IsExtern logical;
        IsPointer logical;
        SpecElement;
    end

    properties(SetAccess=protected)
        IsGetSet logical=false;
    end

    properties(SetAccess=private,Dependent)
        DataKind;
    end

    methods(Access=public)
        function obj=GlobalSigOrParam(varSpec,isExtern,isPointer,specElement)
            obj.VarSpec=varSpec;
            obj.IsExtern=isExtern;
            obj.IsPointer=isPointer;
            obj.SpecElement=specElement;
        end
    end

    methods
        function dataKind=get.DataKind(obj)



            dataKind=obj.VarSpec.DataKind;
        end
    end

end
