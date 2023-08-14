classdef DragNDropHelper<handle




    methods(Static,Access=public)
        function isValidDrag=isValidDrag(listComponent,selection,destination,location,action)



            import sl.interface.dictionaryApp.list.DragNDropHelper;
            isValidDrag=...
            ~DragNDropHelper.isMoveAcrossParents(selection,destination,action)&&...
            ~DragNDropHelper.isDisjointedMultiSelect(listComponent,selection)&&...
            DragNDropHelper.isValidLocation(destination,location,action);
        end

        function drop(selection,destination,location,action)

            import sl.interface.dictionaryApp.list.DragNDropHelper;
            parentNode=DragNDropHelper.getParentOf(destination);

            for selectionIdx=1:length(selection)
                curSelection=selection{selectionIdx};

                if strcmp(action,'copy')
                    destinationNodeIdx=DragNDropHelper.getDestinationNodeIdx(...
                    destination,action,location);
                    curSelection.copyTo(parentNode,destinationNodeIdx);
                else
                    assert(strcmp(action,'move'),'Expected move action')
                    indexDifference=DragNDropHelper.getIndexDifference(...
                    curSelection,destination,location);



                    numPlaces=indexDifference+selectionIdx-1;
                    curSelection.moveInParent(numPlaces);
                end
            end
        end

        function nodeIdx=getIndexOf(node)
            import sl.interface.dictionaryApp.list.DragNDropHelper;
            destinationParentNode=DragNDropHelper.getParentOf(node);



            destinationParentObj=destinationParentNode.getDataObject();
            allChildren=destinationParentObj.Elements;
            nodeDataObj=node.getDataObject();
            nodeIdx=find(arrayfun(@(child)isequal(child,nodeDataObj),allChildren));
        end

        function destinationNode=getDestinationNodeForMoveElementButton(topSelectedNode,moveDirection)


            import sl.interface.dictionaryApp.list.DragNDropHelper;

            selectedNodeIdx=DragNDropHelper.getIndexOf(topSelectedNode);
            parentNode=topSelectedNode.getParentNode();
            childNodes=parentNode.getHierarchicalChildren();

            destinationNodeIdx=selectedNodeIdx;
            if strcmp(moveDirection,'Up')
                if selectedNodeIdx>1
                    destinationNodeIdx=destinationNodeIdx-1;
                end
            else
                if selectedNodeIdx<length(childNodes)
                    destinationNodeIdx=destinationNodeIdx+1;
                end
            end
            destinationNode=childNodes(destinationNodeIdx);
        end

        function canMoveUp=canSelectedNodeBeMovedUp(selectedNode)
            import sl.interface.dictionaryApp.list.DragNDropHelper;

            selectedNodeIdx=DragNDropHelper.getIndexOf(selectedNode);
            if selectedNodeIdx==1
                canMoveUp=false;
            else
                canMoveUp=true;
            end
        end

        function canMoveDown=canSelectedNodeBeMovedDown(selectedNode)
            import sl.interface.dictionaryApp.list.DragNDropHelper;

            selectedNodeIdx=DragNDropHelper.getIndexOf(selectedNode);
            parentNode=selectedNode.getParentNode();
            childNodes=parentNode.getHierarchicalChildren();
            if selectedNodeIdx==length(childNodes)
                canMoveDown=false;
            else
                canMoveDown=true;
            end
        end
    end

    methods(Static,Access=private)

        function destinationParent=getParentOf(destination)
            if isa(destination,'sl.interface.dictionaryApp.node.ElementNode')
                destinationParent=destination.getParentNode();
            else
                assert(sl.interface.dictionaryApp.list.DragNDropHelper.isHierarchicalNode(destination),...
                'Unexpected node for drag-drop operation')


                destinationParent=destination;
            end
        end

        function retVal=isMoveAcrossParents(selection,destination,action)


            import sl.interface.dictionaryApp.list.DragNDropHelper;

            retVal=false;
            if strcmp(action,'move')
                destinationParent=DragNDropHelper.getParentOf(destination);
                for selectedNode=selection
                    if selectedNode{1}.getParentNode()~=destinationParent
                        retVal=true;
                        return;
                    end
                end
            end
        end

        function retVal=isDisjointedMultiSelect(listComponent,selection)


            import sl.interface.dictionaryApp.list.DragNDropHelper;
            retVal=false;
            numSelectedNodes=length(selection);
            if numSelectedNodes>1
                destinationParent=DragNDropHelper.getParentOf(selection{1});
                childNodes=destinationParent.getHierarchicalChildren();
                idxArray=cellfun(@(selectedNode)find(childNodes==selectedNode),selection);
                isTopDown=issorted(idxArray,'strictascend');
                if~isTopDown
                    idxArray=sort(idxArray,'ascend');
                end
                isContiguous=isequal(diff(idxArray),ones(numSelectedNodes-1,1));
                if~isContiguous
                    retVal=true;
                else
                    sl.interface.dictionaryApp.list.DragNDropHelper.setMultiSelectionUserData(...
                    listComponent,idxArray);
                end
            end
        end

        function retVal=isValidLocation(destination,location,action)




            retVal=true;
            if strcmp(location,'on')
                retVal=strcmp(action,'copy')&&...
                sl.interface.dictionaryApp.list.DragNDropHelper.isHierarchicalNode(destination);
            end
        end

        function isHier=isHierarchicalNode(node)
            isHier=sl.interface.dictionaryApp.list.List.canAddChildren(node);
        end

        function setMultiSelectionUserData(listComponent,idxArray)
            assert(isfield(listComponent.getComponentUserData,'Multiselection'));
            listComponent.setComponentUserData(struct('Multiselection',idxArray));
        end

        function destinationNodeIdx=getDestinationNodeIdx(destination,action,location)

            import sl.interface.dictionaryApp.list.DragNDropHelper;
            destinationNodeIdx=DragNDropHelper.getIndexOf(destination);
            if strcmp(action,'copy')
                if isempty(destinationNodeIdx)


                    destinationNodeIdx=DragNDropHelper.getNumChildrenOf(destination)+1;
                elseif strcmp(location,'after')
                    destinationNodeIdx=destinationNodeIdx+1;
                end
            end
        end

        function numChildren=getNumChildrenOf(node)
            import sl.interface.dictionaryApp.list.DragNDropHelper;
            destinationParentNode=DragNDropHelper.getParentOf(node);



            destinationParentObj=destinationParentNode.getDataObject();
            numChildren=length(destinationParentObj.Elements);
        end

        function indexDifference=getIndexDifference(selection,destination,location)
            import sl.interface.dictionaryApp.list.DragNDropHelper;
            destinationNodeIdx=DragNDropHelper.getIndexOf(destination);
            selectionNodeIdx=DragNDropHelper.getIndexOf(selection);
            indexDifference=destinationNodeIdx-selectionNodeIdx;



            isMoveDown=indexDifference>0;
            if strcmp(location,'before')&&isMoveDown
                indexDifference=indexDifference-1;
            elseif strcmp(location,'after')&&~isMoveDown
                indexDifference=indexDifference+1;
            elseif indexDifference==0
                assert(false,'Invalid move')
            else

            end
        end
    end
end


