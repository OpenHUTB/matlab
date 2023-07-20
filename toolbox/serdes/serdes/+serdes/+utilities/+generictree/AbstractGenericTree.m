classdef(Abstract)AbstractGenericTree<handle











    events
TreeChanged
    end
    properties(Dependent)
Name
    end
    properties(Constant)
        ResetFlag=0;
    end
    properties(Access=private)









NodeId2Node
NodeId2Children
NodeId2Parent





LastNodeId
emptyNode
    end
    properties(SetAccess=immutable)
        rootNodeId;
    end
    methods

        function name=get.Name(tree)
            name=tree.getRootNode.NodeName;
        end
        function set.Name(tree,treeName)
            if isempty(tree.Name)||~strcmp(treeName,tree.Name)
                tree.validateTreeName(treeName);
                root=tree.getRootNode;
                root.NodeName=treeName;
            end
        end
    end
    methods
        function tree=AbstractGenericTree(treeName,rootNode)

            tree.LastNodeId=tree.ResetFlag;






            tree.NodeId2Node=containers.Map('KeyType','uint32','ValueType','any');
            tree.NodeId2Children=containers.Map('KeyType','uint32','ValueType','any');
            tree.NodeId2Parent=containers.Map('KeyType','uint32','ValueType','any');
            tree.emptyNode=tree.getEmptyNode();
            tree.rootNodeId=1;
            if(nargin>0)
                rootNode=tree.validateNode(rootNode);
                rootNode.setRootId(tree);
                tree.LastNodeId=rootNode.NodeId;
                rootNode.Locked=true;
                tree.NodeId2Node(tree.LastNodeId)=rootNode;
                tree.NodeId2Parent(tree.LastNodeId)=tree.emptyNode;
                tree.NodeId2Children(tree.LastNodeId)=tree.emptyNode;
                tree.Name=treeName;
                rootNode.setTree(tree)
            end
        end
        function node=getNode(tree,id)

            if isKey(tree.NodeId2Node,id)
                node=tree.NodeId2Node(id);
            end
        end
        function addChild(tree,parent,newChild,insertIdx)


            if tree.containsNode(parent)&&~tree.containsNode(newChild)


                tree.isValidChild(parent,newChild.NodeName)
                tree.validateNode(newChild);
                newChild.setNodeId(tree.getNextNodeId());
                newChildId=newChild.NodeId;

                tree.NodeId2Node(newChildId)=newChild;
                newChild.setTree(tree)

                tree.NodeId2Parent(newChildId)=parent;

                tree.NodeId2Children(newChildId)=tree.emptyNode;

                parentId=parent.NodeId;
                currentChildren=tree.NodeId2Children(parentId);
                if isempty(currentChildren)
                    currentChildren={newChild};
                else
                    if nargin<4||insertIdx>=numel(currentChildren)
                        currentChildren=[currentChildren,{newChild}];
                    else
                        currentChildren=[currentChildren(1:insertIdx),{newChild},currentChildren(insertIdx+1:end)];
                    end
                end
                tree.NodeId2Children(parentId)=currentChildren;
                tree.treeChanged
            end
        end
        function insertChild(tree,parent,oldChild,newChild)



            if tree.containsNode(parent)&&...
                ~tree.containsNode(newChild)&&...
                tree.containsNode(oldChild)
                if tree.isChildOf(parent,oldChild)
                    tree.isValidChild(parent,newChild.NodeName)
                    tree.validateNode(newChild);
                    newChild.setNodeId(tree.getNextNodeId());
                    newChild.setTree(tree)
                    newChildId=newChild.NodeId;
                    parentId=parent.NodeId;
                    oldChildId=oldChild.NodeId;

                    tree.NodeId2Node(newChildId)=newChild;

                    tree.NodeId2Parent(newChildId)=parent;

                    tree.NodeId2Children(newChildId)={oldChild};

                    tree.NodeId2Parent(oldChildId)=newChild;


                    children=tree.NodeId2Children(parentId);
                    for idx=1:length(children)
                        child=children{idx};
                        if child==oldChild
                            children{idx}=newChild;
                            break
                        end
                    end
                    tree.NodeId2Children(parentId)=children;
                end
                tree.treeChanged
            end
        end
        function replaceNode(tree,oldNode,newNode)



            if isa(newNode,'serdes.utilities.generictree.AbstractGenericTreeNode')&&...
                isa(oldNode,'serdes.utilities.generictree.AbstractGenericTreeNode')&&...
                containsNode(tree,oldNode)&&...
                ~containsNode(tree,newNode)
                tree.validateNode(newNode);

                newNode.setToNodeId(oldNode);
                newNode.setTree(tree)
                oldId=oldNode.NodeId;


                oldParent=tree.getParent(oldNode);
                if~isempty(oldParent)&&~strcmpi(oldNode.NodeName,newNode.NodeName)
                    tree.isValidChild(oldParent,newNode.NodeName)
                end
                oldChildren=tree.getChildren(oldNode);

                tree.NodeId2Node(oldId)=newNode;


                if~tree.isLeaf(oldNode)


                    for idx=1:length(oldChildren)
                        child=oldChildren{idx};
                        tree.NodeId2Parent(child.NodeId)=newNode;
                    end
                end
                if~tree.isRoot(oldNode)

                    parentChildren=tree.getChildren(oldParent);
                    replaced=false;
                    for idx=1:length(parentChildren)
                        child=parentChildren{idx};
                        if child==oldNode
                            parentChildren{idx}=newNode;
                            replaced=true;
                            break;
                        end
                    end
                    if~replaced
                        parentChildren=[parentChildren,{newNode}];
                    end
                    tree.NodeId2Children(oldParent.NodeId)=parentChildren;
                end
                oldNode.resetNodeId()
                tree.treeChanged
            end
        end
        function rootNodeId=getRootNodeId(tree)
            rootNodeId=tree.rootNodeId;
        end
        function isChild=isChildOf(tree,parent,child)
            isChild=false;
            if tree.containsNode(parent)&&tree.containsNode(child)
                children=tree.getChildren(parent);
                for idx=1:length(children)
                    tChild=children{idx};
                    if tChild==child
                        isChild=true;
                        break;
                    end
                end
            end
        end
        function isDecendant=isDecendantOf(tree,parent,child)


            if isLeaf(tree,parent)

                isDecendant=false;
            elseif isChildOf(tree,parent,child)

                isDecendant=true;
            else


                children=tree.NodeId2Children(parent.NodeId);
                isDecendant=false;
                for childIdx=1:length(children)
                    childOfParent=children{childIdx};
                    if isDecendantOf(tree,childOfParent,child)
                        isDecendant=true;
                        break;
                    end
                end
            end
        end
        function isLeaf=isLeaf(tree,node)
            isLeaf=false;
            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(tree,node)
                isLeaf=isempty(tree.getChildren(node));
            end
        end
        function isRoot=isRoot(obj,node)
            isRoot=false;
            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(obj,node)
                isRoot=isempty(obj.getParent(node));
            end
        end
        function children=getChildren(tree,node)
            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(tree,node)
                children=tree.NodeId2Children(node.NodeId);
            else
                children=[];
            end
        end
        function parent=getParent(tree,node)
            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(tree,node)
                parent=tree.NodeId2Parent(node.NodeId);
            else
                parent=[];
            end
        end
        function branch=getBranch(tree,node)
            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(tree,node)
                currentNode=node;
                branch={currentNode};



                while~isRoot(tree,currentNode)
                    currentNode=getParent(tree,currentNode);
                    branch=[{currentNode},branch];%#ok<AGROW>
                end
            end
        end
        function rootNode=getRootNode(tree)

            if(tree.LastNodeId>0)
                rootNode=tree.NodeId2Node(tree.rootNodeId);
            end
        end
        function removedNode=removeNode(tree,node)


            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&...
                tree.containsNode(node)
                if~isRoot(tree,node)
                    children=tree.getChildren(node);
                    parent=getParent(tree,node);
                    if isa(parent,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(tree,parent)
                        parentChildren=tree.getChildren(parent);

                        for idx=1:length(parentChildren)
                            child=parentChildren{idx};
                            if child==node
                                parentChildren(idx)=[];
                                break;
                            end
                        end


                        if numel(parentChildren)<=0
                            parentChildren=children;
                        elseif numel(children)>0
                            parentChildren=[parentChildren,children];
                        end
                        tree.NodeId2Children(parent.NodeId)=parentChildren;
                    end

                    for idx=1:length(children)
                        child=children{idx};
                        tree.NodeId2Parent(child.NodeId)=parent;
                    end
                    remove(tree.NodeId2Node,node.NodeId);
                    remove(tree.NodeId2Children,node.NodeId);
                    remove(tree.NodeId2Parent,node.NodeId);
                    node.resetNodeId();
                    node.setTree(serdes.internal.ibisami.ami.SerDesTree.empty)
                    removedNode=node;
                    tree.treeChanged
                else
                    warning(message('serdes:utilities:CannotRemoveRoot'))
                end
            end
        end
        function display=displayTree(tree)

            display="Tree: "+tree.Name+newline+"Node Structure:"+newline;
            display=recusivelyDisplayNodes(tree,display,tree.getRootNode(),"");
        end
        function deleteSubtree(tree,node)
            validateattributes(node,...
            {'serdes.utilities.generictree.AbstractGenericTreeNode'},...
            {'scalar'},...
            "deleteSubtree",...
            "node")
            if tree.isRoot(node)
                error(message('serdes:utilities:CannotRemoveRoot'))
            end
            tree.recursivelyDeleteNode(node);
        end
        function contains=containsNode(tree,node)

            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&...
                ~isempty(tree.NodeId2Node)
                id=node.NodeId;
                contains=isKey(tree.NodeId2Node,id);
            else
                contains=false;
            end
        end
        function validateRename(tree,node,newName)

            parent=tree.getParent(node);
            if~isempty(parent)
                tree.isValidChild(parent,newName)
            end
        end



    end
    methods(Access=protected)
        function isValidChild(tree,parent,newChildName)


            children=tree.getChildren(parent);
            for idx=1:numel(children)
                child=children{idx};
                if strcmpi(child.NodeName,newChildName)
                    error(message('serdes:utilities:DuplicateChildName',child.NodeName,parent.NodeName))
                end
            end
        end
        function ok=validateTreeName(~,~)



            ok=true;
        end
        function clearVisited(tree)




            nodes=tree.NodeId2Node.values();
            for idx=1:length(nodes)
                node=nodes{idx};
                node.Visited=false;
            end
        end
        function treeChanged(tree)



            tree.notify('TreeChanged')
        end
    end
    methods(Access=private)
        function recursivelyDeleteNode(tree,node)
            children=tree.getChildren(node);
            for childIdx=1:numel(children)
                child=children{childIdx};
                tree.recursivelyDeleteNode(child)
            end
            tree.removeNode(node);
        end
        function nextNodeId=getNextNodeId(tree)


            tree.LastNodeId=tree.LastNodeId+1;
            nextNodeId=tree.LastNodeId;
        end
        function display=recusivelyDisplayNodes(tree,display,node,prefix)
            if isa(node,'serdes.utilities.generictree.AbstractGenericTreeNode')&&containsNode(tree,node)
                postfix="";
                if tree.isRoot(node)
                    postfix=" (root)";
                end
                if tree.isLeaf(node)
                    postfix=strcat(postfix," (leaf)");
                end
                display=display+prefix+node.NodeName+postfix+newline;
                if~tree.isLeaf(node)
                    children=tree.getChildren(node);
                    for idx=1:length(children)
                        child=children{idx};
                        display=recusivelyDisplayNodes(tree,display,child,strcat("    ",prefix));
                    end
                end
            end
        end
    end
    methods(Abstract)


        validateNode(tree,node)




        getEmptyNode(tree)


        getNodeClass(tree)
    end
end


