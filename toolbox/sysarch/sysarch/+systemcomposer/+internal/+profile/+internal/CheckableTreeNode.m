classdef CheckableTreeNode<systemcomposer.internal.profile.internal.TreeNode




    properties
        checkState;
    end

    properties(Constant)
        CHECK_NO='unchecked';
        CHECK_YES='checked';
        CHECK_SOME='partially checked';
    end

    methods
        function this=CheckableTreeNode(source,parent,factory)


            this@systemcomposer.internal.profile.internal.TreeNode(source,parent,factory);
            this.checkState=this.Factory.getTreeNodeCheckState(this.ID);
        end

        function icon=getDisplayIcon(~)


            icon='';
        end

        function is=isCheckable(~)
            is=true;
        end

        function s=getCheckState(this)
            s=this.checkState;
        end
    end
end