
classdef CallTreeBase<handle

    methods(Access=public)

        function this=CallTreeBase(parent)
            if nargin==0
                parent=[];
            end
            this.parent=parent;
            this.children=cell(0,1);
        end

        function parent=getParent(this)
            parent=this.parent;
        end

        function children=getChildren(this)
            children=this.children;
        end

        function child=getChild(this,index)
            child=this.children{index};
        end

        function numberOfChildren=getNumberOfChildren(this)
            numberOfChildren=numel(this.children);
        end

        function addChild(this,child)
            index=this.getNumberOfChildren()+1;
            this.children{index,1}=child;
        end

    end

    properties(Access=private)
        parent;
        children;
    end

end

