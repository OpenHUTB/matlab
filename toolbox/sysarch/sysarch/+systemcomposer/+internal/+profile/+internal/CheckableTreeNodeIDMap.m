classdef CheckableTreeNodeIDMap<systemcomposer.internal.profile.internal.TreeNodeIDMap

    properties
        checkStateMap;
parentChildMap
    end

    methods
        function this=CheckableTreeNodeIDMap()


            this@systemcomposer.internal.profile.internal.TreeNodeIDMap();
            this.checkStateMap=containers.Map('KeyType','double','ValueType','char');
            this.parentChildMap=containers.Map('KeyType','double','ValueType','any');
        end

        function setChildren(this,id,childIds)
            this.parentChildMap(id)=childIds;
        end

        function setCheckState(this,id,val)


            if this.hasChildren(id)



                children=this.getChildren(id);
                for child=children
                    this.checkStateMap(child)=val;
                end
            else
                this.checkStateMap(id)=val;
            end
        end

        function c=getCheckState(this,id)


            if this.hasChildren(id)

                c=this.getDerivedCheckState(id);

            elseif this.checkStateMap.isKey(id)
                c=this.checkStateMap(id);
            else

                c=systemcomposer.internal.profile.internal.CheckableTreeNode.CHECK_NO;
            end
        end

    end

    methods(Access=private)
        function is=hasChildren(this,id)


            is=this.parentChildMap.isKey(id);
        end

        function children=getChildren(this,id)


            children=this.parentChildMap(id);
        end

        function c=getDerivedCheckState(this,id)





            children=this.getChildren(id);
            numChecked=0;
            for child=children
                state=this.getCheckState(child);
                if strcmp(state,systemcomposer.internal.profile.internal.CheckableTreeNode.CHECK_YES)
                    numChecked=numChecked+1;
                end
            end

            if numChecked==0
                c=systemcomposer.internal.profile.internal.CheckableTreeNode.CHECK_NO;
            elseif numChecked<length(children)
                c=systemcomposer.internal.profile.internal.CheckableTreeNode.CHECK_SOME;
            else
                c=systemcomposer.internal.profile.internal.CheckableTreeNode.CHECK_YES;
            end
        end
    end
end