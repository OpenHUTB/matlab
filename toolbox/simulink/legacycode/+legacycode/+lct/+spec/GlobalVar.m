classdef GlobalVar<legacycode.lct.spec.GlobalSigOrParam





    properties(SetAccess=private)
        TargetVar char
    end

    methods(Access=public)
        function obj=GlobalVar(varSpec,targetVar,isExtern,isPointer,specElement)
            obj@legacycode.lct.spec.GlobalSigOrParam(varSpec,isExtern,isPointer,specElement);
            obj.TargetVar=targetVar;
        end
    end

end