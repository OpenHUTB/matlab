classdef TreeNodeIDMap<handle




    properties(Access=private)
        IDMap;
        nextID=0;
        visitedKeys={};
    end

    methods
        function this=TreeNodeIDMap()


            this.IDMap=containers.Map('KeyType','char','ValueType','double');
        end

        function val=get(this,key)



            if this.IDMap.isKey(key)
                val=this.IDMap(key);
            else
                val=this.nextID;
                this.IDMap(key)=val;
                this.nextID=this.nextID+1;
            end


            this.visitedKeys=[this.visitedKeys,{key}];
        end

        function prune(this)



            unvisitedKeys=setdiff(this.IDMap.keys,this.visitedKeys);
            this.IDMap.remove(unvisitedKeys);
            this.visitedKeys={};
        end
    end

end
