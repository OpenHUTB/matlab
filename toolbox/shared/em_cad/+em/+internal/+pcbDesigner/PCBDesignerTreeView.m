classdef PCBDesignerTreeView<cad.TreeNodeView




    properties
LayerTreeNodes
PCBAntennaNode
BoardShapeNode
LayersNode
FeedNode
ViaNode
LoadNode
FeedTreeNodes
ViaTreeNodes
LoadTreeNodes
        ActionsStatus=[0,0,0,0];
    end

    methods
        function self=PCBDesignerTreeView(Parent)
            self@cad.TreeNodeView(Parent);
            initializePCBTree(self);
        end















        function copyObj(self,src)
            self.TreeObj.SelectedNodes=[src];
            nodes=self.TreeObj.SelectedNodes;
            if numel(nodes)==0
                self.TreeObj.SelectedNodes=[];
                data=[];
            else
                self.TreeObj.SelectedNodes=nodes;
                data={{nodes.Tag},[nodes.NodeData]};
            end
            self.notify('Selected',cad.events.SelectionEventData(data,'Tree'));
            self.notify('CopyObj');
        end
        function cm=createContextMenu(self,node)
            if~isempty(node.Parent)&&strcmpi(node.Parent.Tag,'PCBAntenna')&&~strcmpi(node.Tag,'Layer')
                return;
            end
            cm=uicontextmenu(self.Figure);
            if~(strcmpi(node.Tag,'Layer')&&node.NodeData==1)
                m1=uimenu(cm,'Text','Delete','MenuSelectedFcn',@(src,evt)deleteObj(self,node));
            end
            if any(strcmpi(node.Tag,{'Shape','feed','via','load'}))
                m3=uimenu(cm,'Text','Copy','MenuSelectedFcn',@(src,evt)copyObj(self,node));

            end


            if strcmpi(node.Tag,'Layer')
                if isempty(node.UserData)||strcmpi(node.UserData.MaterialType,'Metal')
                    m3=uimenu(cm,'Text','Paste','MenuSelectedFcn',@(src,evt)paste(self,node));
                end
            end
        end

        function initializePCBTree(self)
            self.PCBAntennaNode=uitreenode(self.TreeObj,'Text','PCB Antenna - MyPCB','Tag','PCBAntenna');
            self.CurrentLayerNode.Parent=self.PCBAntennaNode;
            self.BoardShapeNode=self.CurrentLayerNode;
            self.CurrentLayerNode.Text='BoardShape';
            ic=generateIcon(self,[0,0,0],0.3);
            self.CurrentLayerNode.Icon=ic;




            self.CurrentLayerNode.NodeData=1;
            self.CurrentLayerNode.Tag='Layer';
            self.LayersNode=uitreenode(self.PCBAntennaNode,'Text','Layers','Tag','LayerTree','NodeData',0);
            self.FeedNode=uitreenode(self.PCBAntennaNode,'Text','Feed','tag','FeedTree');
            ic=generateIcon(self,[1,0,0],1);
            self.FeedNode.Icon=ic;





            self.ViaNode=uitreenode(self.PCBAntennaNode,'Text','Via','tag','ViaTree');
            ic=generateIcon(self,[0,1,0],1);
            self.ViaNode.Icon=ic;
            self.LoadNode=uitreenode(self.PCBAntennaNode,'Text','Load','tag','LoadTree');
            ic=generateIcon(self,[0,0,1],1);
            self.LoadNode.Icon=ic;
            expand(self.TreeObj,'all');
            self.TreeObj.SelectedNodes=self.BoardShapeNode;
            self.LayerTreeNodes=self.BoardShapeNode;
            self.TreeObj.SelectionChangedFcn=@(src,evt)SelectionChanged(self,src,evt);
        end

        function setModel(self,Model)
            self.Controller=em.internal.pcbDesigner.PCBDesignerTreeController(self,Model);
            addListeners(self.Controller);
        end

        function modelChanged(self,evt)



            if isprop(evt,'ModelInfo')||isfield(evt,'ModelInfo')
                modelInfo=evt.ModelInfo;

            else
                modelInfo=[];
            end

            if~isempty(modelInfo)
                self.ActionsStatus=modelInfo.ActionsStatus;
            else
                self.ActionsStatus=[0,0,0,0];
            end

            if strcmpi(evt.EventType,'ShapeAdded')||strcmpi(evt.EventType,'ShapeChanged')
                idx=[self.LayerTreeNodes.NodeData]==evt.Data.GroupInfo.Id;
                tmp=self.CurrentLayerNode;
                self.CurrentLayerNode=self.LayerTreeNodes(idx);
                addShapeView(self,evt.Data);
                self.CurrentLayerNode=tmp;
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
            elseif strcmpi(evt.EventType,'LayerAdded')
                idx=[self.LayerTreeNodes.NodeData]==evt.Data.Id;
                if~any(idx)
                    addLayerView(self,evt.Data);
                end
            elseif strcmpi(evt.EventType,'LayerDeleted')
                deleteLayerView(self,evt.Data);
            elseif strcmpi(evt.EventType,'CurrentLayerChanged')
                currentlayerChanged(self,evt.Data);
            elseif strcmpi(evt.EventType,'UpdateSelection')
                updateSelection(self,evt.Data);
            elseif strcmpi(evt.EventType,'PropertyChanged')
                propertyChanged(self,evt);
            elseif strcmpi(evt.EventType,'FeedAdded')
                addFeedView(self,evt.Data);
            elseif strcmpi(evt.EventType,'FeedDeleted')
                deleteFeedView(self,evt.Data);
            elseif strcmpi(evt.EventType,'ViaAdded')
                addViaView(self,evt.Data);
            elseif strcmpi(evt.EventType,'ViaDeleted')
                deleteViaView(self,evt.Data);
            elseif strcmpi(evt.EventType,'LoadAdded')
                addLoadView(self,evt.Data);
            elseif strcmpi(evt.EventType,'LoadDeleted')
                deleteLoadView(self,evt.Data);
            elseif strcmpi(evt.EventType,'LayerUpdated')

                info=evt.Data;
                if info.Id==1
                    return;
                end
                idx=[self.LayersNode.Children.NodeData];
                idx=idx==info.Id;
                index=find(idx,1,'first');
                n=numel(self.LayersNode.Children);
                previndex=n-index+1;
                tmpIndex=1:n;
                currentIndex=info.Index-1;
                if previndex~=currentIndex
                    previndex=n-previndex+1;
                    currentIndex=n-currentIndex+1;
                    tmpIndex(previndex)=currentIndex;
                    tmpIndex(currentIndex)=previndex;
                    self.LayersNode.Children=self.LayersNode.Children(tmpIndex);
                end
            elseif strcmpi(evt.CategoryType,'PCBAntenna')
                return;
            elseif strcmpi(evt.EventType,'SessionStarted')
                self.BoardShapeNode.Icon=generateIcon(self,[0,0,0]);
            end


        end

        function addFeedView(self,info)
            feedNode=uitreenode(self.FeedNode,'Text',info.Name,'Tag','Feed','NodeData',info.Id);
            feedNode.ContextMenu=createContextMenu(self,feedNode);
            self.FeedNode.expand()
            addFeedNodeToStack(self,feedNode)
        end


        function addFeedNodeToStack(self,feednode)
            if isempty(self.FeedTreeNodes)
                self.FeedTreeNodes=[self.FeedTreeNodes,feednode];
            else
                idx=[self.FeedTreeNodes.NodeData]==feednode.NodeData;
                if~any(idx)
                    self.FeedTreeNodes=[self.FeedTreeNodes,feednode];
                end
            end
        end

        function addViaView(self,info)
            vianode=uitreenode(self.ViaNode,'Text',info.Name,'Tag','Via','NodeData',info.Id);
            vianode.ContextMenu=createContextMenu(self,vianode);
            self.ViaNode.expand();
            addViaNodeToStack(self,vianode);
        end

        function addViaNodeToStack(self,vianode)
            if isempty(self.ViaTreeNodes)
                self.ViaTreeNodes=[self.ViaTreeNodes,vianode];
            else
                idx=[self.ViaTreeNodes.NodeData]==vianode.NodeData;
                if~any(idx)
                    self.ViaTreeNodes=[self.ViaTreeNodes,vianode];
                end
            end
        end

        function addLoadView(self,info)
            loadnode=uitreenode(self.LoadNode,'Text',info.Name,'Tag','Load','NodeData',info.Id);
            loadnode.ContextMenu=createContextMenu(self,loadnode);
            self.LoadNode.expand();
            addLoadNodeToStack(self,loadnode);
        end

        function addLoadNodeToStack(self,loadnode)
            if isempty(self.LoadTreeNodes)
                self.LoadTreeNodes=[self.LoadTreeNodes,loadnode];
            else
                idx=[self.LoadTreeNodes.NodeData]==loadnode.NodeData;
                if~any(idx)
                    self.LoadTreeNodes=[self.LoadTreeNodes,loadnode];
                end
            end
        end

        function deleteFeedView(self,info)
            if isempty(self.FeedTreeNodes)
                return;
            end
            idx=[self.FeedTreeNodes.NodeData]==info.Id;
            feedobj=self.FeedTreeNodes(idx);
            removeFeedNodeFromStack(self,info.Id);
            feedobj.delete;
            self.FeedNode.expand()
        end

        function removeFeedNodeFromStack(self,id)
            idx=[self.FeedTreeNodes.NodeData]==id;
            if any(idx)
                self.FeedTreeNodes(idx)=[];
            end
        end

        function deleteViaView(self,info)
            if isempty(self.ViaTreeNodes)
                return;
            end
            idx=[self.ViaTreeNodes.NodeData]==info.Id;
            vianode=self.ViaTreeNodes(idx);
            removeViaNodeFromStack(self,info.Id);
            vianode.delete;
            self.ViaNode.expand()
        end

        function removeViaNodeFromStack(self,id)
            idx=[self.ViaTreeNodes.NodeData]==id;
            if any(idx)
                self.ViaTreeNodes(idx)=[];
            end
        end

        function deleteLoadView(self,info)
            if isempty(self.LoadTreeNodes)
                return;
            end
            idx=[self.LoadTreeNodes.NodeData]==info.Id;
            loadnode=self.LoadTreeNodes(idx);
            removeLoadNodeFromStack(self,info.Id);
            loadnode.delete;
            self.LoadNode.expand()
        end

        function removeLoadNodeFromStack(self,id)
            idx=[self.LoadTreeNodes.NodeData]==id;
            if any(idx)
                self.LoadTreeNodes(idx)=[];
            end
        end


        function propertyChanged(self,evt)
            Type=evt.CategoryType;
            id=evt.Data.Id;
            if strcmpi(Type,'Shape')
                idx=[self.ShapeTreeNodes.NodeData]==id;
                if any(idx)
                    self.ShapeTreeNodes(idx).Text=evt.Data.Name;
                end
            elseif strcmpi(Type,'Layer')
                idx=[self.LayerTreeNodes.NodeData]==id;
                if any(idx)
                    self.LayerTreeNodes(idx).Text=evt.Data.Name;
                    self.LayerTreeNodes(idx).Icon=generateIcon(self,evt.Data.Color,evt.Data.Transparency);

                end
            elseif strcmpi(Type,'Feed')
                idx=[self.FeedTreeNodes.NodeData]==id;
                if any(idx)
                    self.FeedTreeNodes(idx).Text=evt.Data.Name;
                end
            elseif strcmpi(Type,'Via')
                idx=[self.ViaTreeNodes.NodeData]==id;
                if any(idx)
                    self.ViaTreeNodes(idx).Text=evt.Data.Name;
                end
            elseif strcmpi(Type,'Load')
                idx=[self.LoadTreeNodes.NodeData]==id;
                if any(idx)
                    self.LoadTreeNodes(idx).Text=evt.Data.Name;
                end
            elseif strcmpi(Type,'PCBAntenna')
                self.PCBAntennaNode.Text=['PCBAntenna - ',evt.Data.Name];
            end
        end

        function updateSelection(self,data)
            self.TreeObj.SelectedNodes=[];
            nodes=[];
            if~isempty(data)

                for i=1:numel(data{1})
                    if strcmpi(data{1}{i},'Layer')
                        idx=[self.LayerTreeNodes.NodeData]==data{2}(i);
                        nodes=[nodes,self.LayerTreeNodes(idx)];
                    elseif strcmpi(data{1}{i},'Operation')
                        idx=[self.OperationTreeNodes.NodeData]==data{2}(i);
                        nodes=[nodes,self.OperationTreeNodes(idx)];
                    elseif strcmpi(data{1}{i},'Shape')
                        idx=[self.ShapeTreeNodes.NodeData]==data{2}(i);
                        nodes=[nodes,self.ShapeTreeNodes(idx)];
                    elseif strcmpi(data{1}{i},'Feed')
                        idx=[self.FeedTreeNodes.NodeData]==data{2}(i);
                        nodes=[nodes,self.FeedTreeNodes(idx)];
                    elseif strcmpi(data{1}{i},'Via')
                        idx=[self.ViaTreeNodes.NodeData]==data{2}(i);
                        nodes=[nodes,self.ViaTreeNodes(idx)];
                    elseif strcmpi(data{1}{i},'Load')
                        idx=[self.LoadTreeNodes.NodeData]==data{2}(i);
                        nodes=[nodes,self.LoadTreeNodes(idx)];
                    elseif strcmpi(data{1}{i},'PCBAntenna')
                        nodes=[nodes,self.PCBAntennaNode];
                    end
                end
            end



            self.TreeObj.SelectedNodes=nodes;
        end

        function updateView(self,vm)

            data=getSelectedObjInfo(vm);
            updateSelection(self,data);
        end

        function currentlayerChanged(self,info)
            idx=[self.LayerTreeNodes.NodeData]==info.Id;
            if~any(idx)
                addLayerView(self,info)
                layerobj=self.LayerTreeNodes(end);
            else
                layerobj=self.LayerTreeNodes(idx);
            end
            self.CurrentLayerNode=layerobj;
            self.TreeObj.SelectedNodes=layerobj;
        end

        function addLayerView(self,info)
            layernode=uitreenode(self.LayersNode,'Text',info.Name,'Tag','Layer','NodeData',info.Id,'UserData',info);
            ic=generateIcon(self,info.Color,info.Transparency);
            layernode.Icon=ic;




            nlayers=numel(self.LayersNode.Children);
            if nlayers>1&&info.Index-1==nlayers
                self.LayersNode.Children=[self.LayersNode.Children(end);self.LayersNode.Children(1:end-1)];
            else
                if info.Index-1==1

                else
                    self.LayersNode.Children=[self.LayersNode.Children(1:info.Index-1);...
                    self.LayersNode.Children(end);self.LayersNode.Children((end-(info.Index-1-1):end-1))];
                end
            end
            layernode.ContextMenu=createContextMenu(self,layernode);
            self.LayersNode.expand()
            addLayerNodeToStack(self,layernode)
        end

        function deleteLayerView(self,info)
            idx=[self.LayerTreeNodes.NodeData]==info.Id;
            layerobj=self.LayerTreeNodes(idx);
            removeLayerNodeFromStack(self,info.Id);
            layerobj.delete;
            self.LayersNode.expand()
        end

        function addLayerNodeToStack(self,val)
            if~any([self.LayerTreeNodes.NodeData]==val.NodeData)
                self.LayerTreeNodes=[self.LayerTreeNodes,val];
            end
        end

        function paste(self,varargin)
            if~self.ActionsStatus(3)
                return;
            end
            if isempty(varargin)
                node=self.CurrentLayerNode;
            else
                node=varargin{1};
            end
            data.LayerId=node.NodeData;
            data.AxesLim=[-1,1;-1,1];
            self.notify('Paste',cad.events.ValueChangedEventData(data));

        end

        function cut(self)
            if~self.ActionsStatus(1)
                return;
            end
            self.notify('Cut',cad.events.SelectionEventData([]));
        end

        function copy(self)
            if~self.ActionsStatus(2)
                return;
            end
            self.notify('Copy',cad.events.SelectionEventData([]));
        end


        function deleteObj(self,varargin)

            if isempty(varargin)
                if~self.ActionsStatus(4)
                    return;
                end
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


        function removeLayerNodeFromStack(self,id)
            idx=[self.LayerTreeNodes.NodeData]==id;
            if any(idx)
                self.LayerTreeNodes(idx)=[];
            end
        end

        function overlayLayer(self,layerNode,overlayFlag)
            self.notify('OverlayLayer',cad.events.OverlayEventData([layerNode.NodeData,overlayFlag]));
        end
        function SelectionChanged(self,src,evt)
            removeFromSelection=[];
            for i=1:numel(evt.SelectedNodes)
                if strcmpi(evt.SelectedNodes(i).Text,'Color')

                    ic=evt.SelectedNodes(i).Icon;
                    color=[ic(1,1,1),ic(1,1,2),ic(1,1,3)];
                    colorval=uisetcolor(color);

                    if strcmpi(evt.SelectedNodes(i).NodeData,'Feed')

                    else
                        setColorvalToLayer(self,evt.SelectedNodes(i).NodeData,color,colorval);
                    end
                    removeFromSelection=[removeFromSelection;i];
                elseif any(strcmpi(evt.SelectedNodes(i).Tag,{'BoardShapeTree',...
                    'LoadTree'}))
                    removeFromSelection=[removeFromSelection;i];
                end
            end
            selectIdx=ones(1,numel(evt.SelectedNodes));
            selectIdx(removeFromSelection)=0;
            nodes=evt.SelectedNodes(logical(selectIdx));
            if numel(nodes)==0
                src.SelectedNodes=[];
                data=[];
            else
                src.SelectedNodes=nodes;
                data={{nodes.Tag},[nodes.NodeData]};
            end

            self.notify('Selected',cad.events.SelectionEventData(data,'Tree'));

        end

        function setColorvalToLayer(self,id,prevColor,color)

            Data.Id=id;
            Data.Type='Layer';
            Data.Property='Color';
            Data.PreviousValue=prevColor;
            Data.Value=color;
            self.notify('ColorChanged',cad.events.ValueChangedEventData(Data));
        end
        function ic=generateIcon(self,color,transparency)
            ic=zeros(10,10,3);
            r=ones(10,10).*color(1);
            g=ones(10,10).*color(2);
            b=ones(10,10).*color(3);

            ic(:,:,1)=r;
            ic(:,:,2)=g;
            ic(:,:,3)=b;

        end

        function delete(self)
            if self.checkValid(self.Figure)
                clf(self.Figure);
            end
        end
    end
    events
DeleteLayer
DeleteFeed
DeleteVia
DeleteLoad
Selected
OverlayLayer
ColorChanged
DeleteObj
CopyObj
    end
end
