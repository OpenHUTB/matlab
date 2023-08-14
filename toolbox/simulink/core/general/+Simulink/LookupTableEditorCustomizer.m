classdef LookupTableEditorCustomizer<handle

    properties(SetAccess=public,GetAccess=public)
getTableConvertToCustomInfoFcnHandle
    end

    methods(Access=public)

        function obj=LookupTableEditorCustomizer()
            mlock;
            getTableConvertToCustomInfoFcnHandle=[];

        end

    end

end





