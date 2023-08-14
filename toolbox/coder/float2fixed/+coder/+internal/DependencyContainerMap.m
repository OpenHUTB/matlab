classdef DependencyContainerMap<coder.internal.lib.Map
    methods(Access='public')
        function this=DependencyContainerMap
            this=this@coder.internal.lib.Map();
        end

        function value=add(this,key,value)
            s.type='()';
            s.subs=key;
            subsasgn(this,s,value);
        end




        function depConts=values(this,type)
            if nargin<=1
                type=[];
            end
            if isempty(type)
                depConts=values@containers.Map(this);
            elseif strcmp(type,'array')
                depConts=coder.internal.Helper.cell2arr(this.values);
            else
                error('incorrect type');
            end
        end
    end
end