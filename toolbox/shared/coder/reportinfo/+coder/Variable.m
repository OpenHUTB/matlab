classdef Variable<matlab.mixin.Heterogeneous


















    properties(SetAccess=private)
        Name char=''
        Scope char=''
        Type{mustBeA(Type,{'coder.Type','double'})}=[]
    end

    methods(Access={?codergui.internal.CodegenInfoBuilder})
        function obj=Variable(name,scope,type)
            if nargin==0
                return
            end
            narginchk(3,3);
            obj.Name=name;
            obj.Scope=scope;
            obj.Type=type;
        end
    end
end