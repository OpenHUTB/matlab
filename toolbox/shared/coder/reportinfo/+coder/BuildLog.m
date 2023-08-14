classdef(Sealed)BuildLog<handle
















    properties(SetAccess=immutable)
        Text char=''
        Type char=''
    end

    methods(Access=?codergui.internal.CodegenInfoBuilder)
        function obj=BuildLog(text,type)
            if nargin==0
                return
            end
            narginchk(2,2);
            obj.Text=text;
            obj.Type=type;
        end
    end
end

