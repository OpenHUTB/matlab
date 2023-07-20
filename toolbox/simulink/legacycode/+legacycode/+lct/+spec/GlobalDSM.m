classdef GlobalDSM<legacycode.lct.spec.GlobalVar





    properties(SetAccess=private)
        IsReadOnly logical
        WorkspaceName char
    end

    methods(Access=public)
        function obj=GlobalDSM(varSpec,targetVar,isExtern,isPointer,specElement,workspaceName,isReadOnly)
            obj@legacycode.lct.spec.GlobalVar(varSpec,targetVar,isExtern,isPointer,specElement);
            obj.IsReadOnly=isReadOnly;
            obj.WorkspaceName=workspaceName;
        end
    end

end