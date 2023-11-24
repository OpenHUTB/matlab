classdef HierarchyIterator<internal.systemcomposer.AbstractIterator

    properties(Access=protected)
        CurrentElement;
        Root;
        NodeList;
        CurrentNodeIdx;
    end

    properties
        Recurse=true;
    end

    methods(Abstract,Access=protected)


        comps=getChildComponents(this,elem);
    end

    methods(Access=protected)
        function elem=dequeElement(this)
            if this.Direction==systemcomposer.IteratorDirection.BottomUp
                elem=this.NodeList(length(this.NodeList)-this.CurrentNodeIdx+1);
            else
                elem=this.NodeList(this.CurrentNodeIdx);
            end
            this.CurrentNodeIdx=this.CurrentNodeIdx+1;
        end

        function elem=tail(~)
            elem=mf.zero.ModelElement.empty();
        end
    end

    methods

        function begin(this,startNode)
            this.Root=this.validateStartNode(startNode);
            this.CurrentElement=this.Root;
            this.CurrentNodeIdx=1;

            if~this.Recurse

                this.Direction=systemcomposer.IteratorDirection.TopDown;
            end

            if(this.Direction==systemcomposer.IteratorDirection.PreOrder||...
                this.Direction==systemcomposer.IteratorDirection.PostOrder)


                nodeList.CurrentIdx=1;
                nodeList.Nodes=[];
                nodeList=this.getDFSFlatList(this.Root,nodeList);


                nodeList.Nodes=cell(1,nodeList.CurrentIdx-1);
                nodeList.CurrentIdx=1;
                nodeList=this.getDFSFlatList(this.Root,nodeList);
                this.NodeList=[nodeList.Nodes{:}];

                this.next;
            else

                nodeList.CurrentIdx=1;
                nodeList.Nodes=[];
                nodeList=this.getBFSFlatList(nodeList);


                nodeList.Nodes=cell(1,nodeList.CurrentIdx-1);
                nodeList.CurrentIdx=1;
                nodeList=this.getBFSFlatList(nodeList);
                this.NodeList=[nodeList.Nodes{:}];

                this.next;
            end
        end

        function elem=getElement(this)

            elem=this.CurrentElement;
        end

        function next(this)
            if this.CurrentNodeIdx<=length(this.NodeList)
                this.CurrentElement=this.dequeElement;
            else
                this.CurrentElement=this.tail;
            end
        end

        function this=HierarchyIterator(direction)
            this@internal.systemcomposer.AbstractIterator(direction);
            this.NodeList=mf.zero.ModelElement.empty();
            this.Root=mf.zero.ModelElement.empty();
            this.CurrentElement=mf.zero.ModelElement.empty();
        end
    end

    methods(Access=protected)
        function nodeList=getDFSFlatList(this,node,nodeList)


            children=this.getChildComponents(node);

            if(this.Direction==systemcomposer.IteratorDirection.PreOrder)
                if~isempty(nodeList.Nodes)
                    nodeList.Nodes{nodeList.CurrentIdx}=node;
                end
                nodeList.CurrentIdx=nodeList.CurrentIdx+1;

                for i=1:numel(children)
                    nodeList=this.getDFSFlatList(children(i),nodeList);
                end
            else
                for i=1:numel(children)
                    nodeList=this.getDFSFlatList(children(i),nodeList);
                end

                if~isempty(nodeList.Nodes)
                    nodeList.Nodes{nodeList.CurrentIdx}=node;
                end
                nodeList.CurrentIdx=nodeList.CurrentIdx+1;
            end
        end

        function nodeList=getBFSFlatList(this,nodeList)

            if~isempty(nodeList.Nodes)
                nodeList.Nodes{nodeList.CurrentIdx}=this.Root;
            end
            nodeList.CurrentIdx=nodeList.CurrentIdx+1;

            children=this.getChildComponents(this.Root);
            while~isempty(children)
                nextLevChildren=[];
                for i=1:numel(children)
                    if~isempty(nodeList.Nodes)
                        nodeList.Nodes{nodeList.CurrentIdx}=children(i);
                    end
                    nodeList.CurrentIdx=nodeList.CurrentIdx+1;

                    nextLevChildren=[nextLevChildren,...
                    this.getChildComponents(children(i))];%#ok<AGROW>
                end
                if~this.Recurse
                    break;
                end
                children=nextLevChildren;
            end
        end
    end
end
