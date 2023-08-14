classdef TreeNodeView<cad.View&cad.KeyBoardBehaviour




    properties
Figure
TreeObj
ShapeTreeNodes
OperationTreeNodes
TreeLayout
TreePanel
CurrentLayerNode
    end

    methods
        function self=TreeNodeView(varargin)

            if~isempty(varargin)
                self.Figure=varargin{1};
            else
                self.Figure=uifigure;
            end

            initializeTreeView(self)
        end

        function set.Figure(self,val)
            self.Figure=val;
        end
        function figureResized(self)



        end

        function initializeTreeView(self)
            self.TreeLayout=uigridlayout(getFigure(self),'RowHeight',{'fit'},'ColumnWidth',{'fit'});
            self.TreeLayout.RowHeight={'1x'};
            self.TreeLayout.ColumnWidth={'1x'};
            self.TreeLayout.Padding=[0,0,0,0];
            self.TreeObj=uitree(self.TreeLayout);
            fig=getFigure(self);
            fig.Scrollable='off';

            self.TreeObj.SelectionChangedFcn='';
            self.TreeObj.Multiselect='on';
            self.TreeObj.BackgroundColor=self.Figure.Color;


            initializeKeyBoardBehaviour(self);
            expand(self.TreeObj,'all');
            self.CurrentLayerNode=uitreenode(self.TreeObj,'Text','Layer','Tag','Layer','NodeData',1);
            self.CurrentLayerNode.ContextMenu=createContextMenu(self,self.CurrentLayerNode);
            fig=getFigure(self);
            addlistener(fig,'SizeChanged',@(src,evt)set(self.TreeObj,'Position',[0,0,fig.Position(3),fig.Position(4)]));

        end

        function initializeKeyBoardBehaviour(self)
            self.KB_ParentFig=getFigure(self);
            self.KB_Listeners.KeyPress=addlistener(self.KB_ParentFig,'WindowKeyPress',...
            @(src,evt)self.notifyKeyFunc(src,evt));
            self.KB_Listeners.KeyRelease=addlistener(self.KB_ParentFig,'WindowKeyRelease',...
            @(src,evt)self.notifyKeyFunc(src,evt));
        end

        function cm=createContextMenu(self,node)
            cm=uicontextmenu(self.Figure);
            m1=uimenu(cm,'Text','Delete','MenuSelectedFcn',@(src,evt)delete(self,node));
            if strcmpi(node.Tag,'Shape')
                m2=uimenu(cm,'Text','Cut','MenuSelectedFcn',@(src,evt)cut(self,node));
                m3=uimenu(cm,'Text','Copy','MenuSelectedFcn',@(src,evt)copy(self,node));
                m3=uimenu(cm,'Text','Paste','MenuSelectedFcn',@(src,evt)paste(self,node));
            end
        end

        function data=genDataForActions(self,varargin)
            if isempty(varargin)
                node=[];
            else
                node=varargin{1};
            end
            if isempty(node)||any(self.TreeObj.SelectedNodes==node)
                type={self.TreeObj.SelectedNodes.Tag};
                id=[self.TreeObj.SelectedNodes.NodeData];
                data={type,id};

            else
                type={node.Tag};
                id=[node.NodeData];
                data={type,id};
            end
        end
        function cut(self)
            self.notify('Cut',cad.events.SelectionEventData([]));
        end

        function copy(self)
            self.notify('Copy',cad.events.SelectionEventData([]));
        end

        function paste(self)
            self.notify('Paste',cad.events.ValueChangedEventData([]));
        end

        function deleteObj(self,varargin)
            if isempty(varargin)
                node=self.TreeObj.SelectedNodes;
            else
                node=varargin{1};
            end
            if isempty(node)
                return;
            end
            if~any(self.TreeObj.SelectedNodes==node)
                self.notify('Selected',cad.events.SelectionEventData({{node.Tag},[node.NodeData]},'Tree'));
            end
            self.notify('DeleteShape',cad.events.SelectionEventData([]));
        end
        function addShapeView(self,Data)
            shapeInfo=Data;
            shapeTreeNode=findShapeNode(self,shapeInfo.Id);
            if isempty(shapeTreeNode)
                shapeTreeNode=uitreenode(self.CurrentLayerNode,'Text',shapeInfo.Name,'NodeData',shapeInfo.Id,'Tag','Shape');
                addShapeNodeToStack(self,shapeTreeNode)
                shapeTreeNode.ContextMenu=createContextMenu(self,shapeTreeNode);
            end
            if~isempty(shapeInfo.ParentId)&&strcmpi(shapeInfo.ParentType,'Layer')
                shapeTreeNode.Parent=self.CurrentLayerNode;
                if~isempty(shapeInfo.ChildrenId)
                    for i=1:numel(shapeInfo.ChildrenId)
                        opnNode=findOperationNode(self,shapeInfo.ChildrenId(i));
                        if isempty(opnNode)
                            if~any(strcmpi(shapeInfo.ChildrenType{i},{'Resize','Rotate','Move','Value'}))
                                opnNode=uitreenode(shapeTreeNode,'Text',shapeInfo.ChildrenType{i},'NodeData',shapeInfo.ChildrenId(i),'Tag','Operation');
                                addOperationNodeToStack(self,opnNode);
                                opnNode.ContextMenu=createContextMenu(self,opnNode);
                            end
                        else
                            opnNode.Parent=shapeTreeNode;
                        end

                    end
                end
            elseif isempty(shapeInfo.ParentId)

            else
                opnNode=findOperationNode(self,shapeInfo.ParentId);
                if isempty(opnNode)
                    if isempty(shapeInfo.ParentParentId)
                        parentShapeNode=self.CurrentLayerNode;
                    else
                        parentShapeNode=findShapeNode(self,shapeInfo.ParentParentId);
                    end
                    opnNode=uitreenode(parentShapeNode,'Text',shapeInfo.ParentType,'NodeData',shapeInfo.ParentId,'Tag','Operation');
                    addOperationNodeToStack(self,opnNode);
                    opnNode.ContextMenu=createContextMenu(self,opnNode);
                end
                shapeTreeNode.Parent=opnNode;
            end
            expand(shapeTreeNode.Parent);
        end

        function deleteShapeView(self,Data)
            ShapeInfo=Data;
            ShapeTreeNode=findShapeNode(self,ShapeInfo.Id);
            if~isempty(ShapeTreeNode)
                opnChildren=ShapeTreeNode.Children;
                for i=1:numel(ShapeTreeNode.Children)
                    shapeChildren=opnChildren(i).Children;
                    for j=1:numel(shapeChildren)
                        shapeChildren(j).Parent=self.CurrentLayerNode;
                    end
                    removeOperationNodeFromStack(self,opnChildren(i));
                    opnChildren(i).delete;

                end
                removeShapeNodeFromStack(self,ShapeTreeNode);
                ShapeTreeNode.delete;

            end
        end

        function addOperationView(self,Data)
            OperationInfo=Data;
            OperationTreeNode=findOperationNode(self,OperationInfo.Id);
            if isempty(OperationTreeNode)
                OperationTreeNode=uitreenode(self.CurrentLayerNode,'Text',OperationInfo.Type,'NodeData',OperationInfo.Id,'Tag','Operation');
                addOperationNodeToStack(self,OperationTreeNode)
            end

            shapeNode=findShapeNode(self,OperationInfo.ParentId);
            if isempty(shapeNode)
                parentOperationNode=findOperationNode(self,OperationInfo.ParentParentId);
                shapeNode=uitreenode(parentOperationNode,'Text',OperationInfo.ParentType,'NodeData',OperationInfo.ParentId,'Tag','Operation');
                addShapeNodeToStack(self,shapeNode);
            end
            OperationTreeNode.Parent=shapeNode;
            expand(OperationTreeNode.Parent);
        end

        function deleteOperationView(self,Data)
            OperationInfo=Data;
            OperationTreeNode=findOperationNode(self,OperationInfo.Id);
            if~isempty(OperationTreeNode)
                removeOperationNodeFromStack(self,OperationTreeNode);
                childnodes=OperationTreeNode.Children;
                for i=1:numel(OperationTreeNode.Children)
                    childnodes(i).Parent=self.CurrentLayerNode;
                end
                OperationTreeNode.delete;
            end
        end
        function addShapeNodeToStack(self,node)
            self.ShapeTreeNodes=[self.ShapeTreeNodes;node];
        end

        function node=findShapeNode(self,id)
            if isempty(self.ShapeTreeNodes)
                node=[];
                return;
            end
            idx=[self.ShapeTreeNodes.NodeData]==id;
            node=self.ShapeTreeNodes(idx);
        end

        function removeShapeNodeFromStack(self,node)
            idx=[self.ShapeTreeNodes.NodeData]==node.NodeData;
            self.ShapeTreeNodes(idx)=[];

        end

        function addOperationNodeToStack(self,node)
            self.OperationTreeNodes=[self.OperationTreeNodes;node];
        end

        function node=findOperationNode(self,id)
            if isempty(self.OperationTreeNodes)
                node=[];
                return;
            end
            idx=[self.OperationTreeNodes.NodeData]==id;
            node=self.OperationTreeNodes(idx);
        end

        function removeOperationNodeFromStack(self,node)
            idx=[self.OperationTreeNodes.NodeData]==node.NodeData;
            self.OperationTreeNodes(idx)=[];

        end

        function modelChanged(self,evt)
            if strcmpi(evt.EventType,'ShapeAdded')||strcmpi(evt.EventType,'ShapeChanged')
                addShapeView(self,evt.Data);
            elseif strcmpi(evt.EventType,'ShapeDeleted')
                deleteShapeView(self,evt.Data);
            elseif strcmpi(evt.EventType,'OperationAdded')
                if~any(strcmpi(evt.ObjectType,{'Resize','Rotate','Move','Value'}))
                    addOperationView(self,evt.Data);
                end
            elseif strcmpi(evt.EventType,'OperationDeleted')
                if~any(strcmpi(evt.ObjectType,{'Resize','Rotate','Move','Value'}))
                    deleteOperationView(self,evt.Data);
                end
            end
        end

        function setModel(self,Model)
            self.Controller=cad.TreeNodeController(self,Model);
        end

        function figOut=getFigure(self)
            figOut=self.Figure;
        end


    end

    events
DeleteShape
    end
end
