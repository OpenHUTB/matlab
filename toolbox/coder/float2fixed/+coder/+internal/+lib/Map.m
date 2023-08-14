classdef Map<containers.Map








    methods(Access='public')
        function this=Map(varargin)
            this=this@containers.Map(varargin{:});
        end

        function value=add(this,key,value)
            s.type='()';
            s.subs=key;
            subsasgn(this,s,value);
        end


        function this=clear(this)
            this.remove(this.keys);
        end



        function this=update(this,otherMap)
            cellfun(@(key,value)this.add(key,value),...
            otherMap.keys,...
            otherMap.values,...
            'UniformOutput',false);
        end



        function newMap=merge(this,otherMap)

            error('unimplemented method');
        end


        function newMap=copy(this)
            newMap=coder.internal.lib.Map;
            cellfun(@(key)newMap.add(key,this.get(key)),this.keys,'UniformOutput',false);
        end



        function values=get(this,keys)
            if iscell(keys)
                values=cellfun(@(k)lookup(k),keys,'UniformOutput',false);
            else
                values=lookup(keys);
            end
            function val=lookup(key)
                s.type='()';
                s.subs=key;
                val=subsref(this,s);
            end
        end
    end

end

