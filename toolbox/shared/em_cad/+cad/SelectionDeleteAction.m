classdef SelectionDeleteAction<cad.Actions

    properties

    end


    methods

        function self=SelectionDeleteAction(Model,evt)

            self.Type='Delete';
            self.Model=Model;
            self.ActionObjectType=self.Model.SelectedObj.CategoryType;
            self.ActionInfo.Id=self.Model.SelectedObj.Id;
            self.ActionInfo.SelectionView=self.Model.SelectionView;
            self.ActionInfo.ShapeId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.CategoryType,'Shape'));
            self.ActionInfo.OperationId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.CategoryType,'Operation'));
            self.ActionInfo.LayerId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.CategoryType,'Layer'));
            self.ActionInfo.OrphanOperationsId=[];
            self.ActionInfo.ConnectionLayerMap=[];
            if~strcmpi(self.ActionInfo.SelectionView,'Canvas')
                self.ActionInfo.OrphanOperationsId=getOrphanOperationsId(self);
                self.ActionInfo.OperationId=setdiff(self.ActionInfo.OperationId,self.ActionInfo.OrphanOperationsId);
            end
            layerIdx=strcmpi(self.Model.SelectedObj.CategoryType,'Layer');
            self.ActionInfo.FeedId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.Type,'Feed'));
            self.ActionInfo.ViaId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.Type,'Via'));
            self.ActionInfo.LoadId=self.Model.SelectedObj.Id(strcmpi(self.Model.SelectedObj.Type,'Load'));
            if any(layerIdx)
                layerObjectsId=self.Model.SelectedObj.Id(layerIdx);
                for i=1:numel(layerObjectsId)
                    layerId=layerObjectsId(i);
                    layerObj=self.Model.findlayerobj(layerId);
                    if~isempty(layerObj.Load)
                        loadIds=self.ActionInfo.LoadId;
                        layerLoadIds=[layerObj.Load.Id];

                        loadIds=setdiff(loadIds,layerLoadIds);

                        loadIds=[loadIds;layerLoadIds];

                        self.ActionInfo.LoadId=loadIds;
                    end

                    if~isempty(layerObj.Feed)
                        feedids=self.ActionInfo.FeedId;
                        deleteLayerFeedIds=[layerObj.Feed.Id];
                        feedids=setdiff(feedids,deleteLayerFeedIds);
                        feedids=[feedids;deleteLayerFeedIds];

                        self.ActionInfo.FeedId=feedids;

                    end

                    if~isempty(layerObj.Via)
                        viaids=self.ActionInfo.ViaId;
                        deleteLayerViaIds=[layerObj.Via.Id];

                        viaids=setdiff(viaids,deleteLayerViaIds);
                        viaids=[viaids;deleteLayerViaIds];

                        self.ActionInfo.ViaId=viaids;
                    end
                end

            end
        end


        function orphanOperations=getOrphanOperationsId(self)
            shapeId=self.ActionInfo.ShapeId;
            orphanOperations=[];
            for i=1:numel(shapeId)

                object=getObject(self.Model,'Shape',shapeId(i));
                if~isempty(object.Children)

                    orphanOperations=[orphanOperations,[object.Children.Id]];
                end
                if strcmpi(object.Parent.CategoryType,'Operation')

                    shapeObjNotDelete=setdiff([object.Parent.Children.Id],shapeId);
                    if isempty(shapeObjNotDelete)
                        orphanOperations=[orphanOperations,object.Parent.Id];
                    end
                end
            end

            orphanOperations=unique(orphanOperations);
        end


        function execute(self)
            objArr=[];
            infoArr=[];
            opnId=self.ActionInfo.OperationId;
            for i=1:numel(opnId)
                opnObj=getObject(self.Model,'Operation',opnId(i));
                info=getInfo(opnObj);
                objArr=[objArr,opnObj];
                infoArr=[infoArr,info];
            end
            for i=1:numel(objArr)
                removeOperationObject(self,objArr(i),infoArr(i));
            end
            self.ActionInfo.OperationObj=objArr;
            self.ActionInfo.OperationInfo=infoArr;

            objArr=[];
            infoArr=[];
            opnId=self.ActionInfo.OrphanOperationsId;
            for i=1:numel(opnId)
                opnObj=getObject(self.Model,'Operation',opnId(i));
                info=getInfo(opnObj);
                objArr=[objArr,opnObj];
                infoArr=[infoArr,info];

            end
            for i=1:numel(objArr)
                removeOperationObject(self,objArr(i),infoArr(i));
            end
            self.ActionInfo.OrphanOperationsObj=objArr;
            self.ActionInfo.OrphanOperationsInfo=infoArr;

            objArr=[];
            infoArr=[];
            shapeId=self.ActionInfo.ShapeId;
            for i=1:numel(shapeId)
                shapeObj=getObject(self.Model,'Shape',shapeId(i));

                info=getInfo(shapeObj);
                objArr=[objArr,shapeObj];
                infoArr=[infoArr,info];
                removeShapeObject(self,shapeObj,info);
                if strcmpi(self.ActionInfo.SelectionView,'Canvas')
                    callDeletedOnAllChildren(self,shapeObj);
                else
                    shapeObj.deleteDependentVariableMaps();
                end
            end
            self.ActionInfo.ShapeObj=objArr;
            self.ActionInfo.ShapeInfo=infoArr;

            objArr=[];
            infoArr=[];
            FeedId=self.ActionInfo.FeedId;
            for i=1:numel(FeedId)
                Feedobj=getObject(self.Model,'Feed',FeedId(i));
                info=getInfo(Feedobj);
                objArr=[objArr,Feedobj];
                infoArr=[infoArr,info];
                deleteFeedObject(self,Feedobj,info);
            end
            self.ActionInfo.FeedObj=objArr;
            self.ActionInfo.FeedInfo=infoArr;

            objArr=[];
            infoArr=[];
            ViaId=self.ActionInfo.ViaId;
            for i=1:numel(ViaId)
                Viaobj=getObject(self.Model,'Via',ViaId(i));
                info=getInfo(Viaobj);
                objArr=[objArr,Viaobj];
                infoArr=[infoArr,info];
                deleteViaObject(self,Viaobj,info);
            end
            self.ActionInfo.ViaObj=objArr;
            self.ActionInfo.ViaInfo=infoArr;

            objArr=[];
            infoArr=[];
            LoadId=self.ActionInfo.LoadId;
            for i=1:numel(LoadId)
                Loadobj=getObject(self.Model,'Load',LoadId(i));
                info=getInfo(Loadobj);
                objArr=[objArr,Loadobj];
                infoArr=[infoArr,info];
                deleteLoadObject(self,Loadobj,info);
            end
            self.ActionInfo.LoadObj=objArr;
            self.ActionInfo.LoadInfo=infoArr;

            objArr=[];
            infoArr=[];
            LayerId=self.ActionInfo.LayerId;
            for i=1:numel(LayerId)
                Layerobj=getObject(self.Model,'Layer',LayerId(i));
                info=getInfo(Layerobj);
                objArr=[objArr,Layerobj];
                infoArr=[infoArr,info];

            end
            for i=1:numel(objArr)
                deleteLayerObject(self,objArr(i),infoArr(i));
            end
            self.ActionInfo.LayerObj=objArr;
            self.ActionInfo.LayerInfo=infoArr;


            if isa(self.Model,'em.internal.pcbDesigner.PCBModel')
                self.Model.setSelectedObj(self.Model.Group);
            end
        end


        function undo(self)
            LayerId=self.ActionInfo.LayerId;
            if~isempty(LayerId)

                indexVal=[self.ActionInfo.LayerInfo.Index];
                [~,indexidxval]=sort(indexVal);
                self.ActionInfo.LayerInfo=self.ActionInfo.LayerInfo(indexidxval);
                self.ActionInfo.LayerObj=self.ActionInfo.LayerObj(indexidxval);
            end

            for i=1:numel(LayerId)
                LayerObj=self.ActionInfo.LayerObj(i);
                info=(self.ActionInfo.LayerInfo(i));
                addLayerObject(self,LayerObj,info);
            end

            FeedId=self.ActionInfo.FeedId;
            for i=1:numel(FeedId)
                FeedObj=self.ActionInfo.FeedObj(i);
                info=(self.ActionInfo.FeedInfo(i));
                addFeedObject(self,FeedObj,info);
            end

            ViaId=self.ActionInfo.ViaId;
            for i=1:numel(ViaId)
                ViaObj=self.ActionInfo.ViaObj(i);
                info=(self.ActionInfo.ViaInfo(i));
                addViaObject(self,ViaObj,info);
            end
            LoadId=self.ActionInfo.LoadId;
            for i=1:numel(LoadId)
                LoadObj=self.ActionInfo.LoadObj(i);
                info=(self.ActionInfo.LoadInfo(i));
                addLoadObject(self,LoadObj,info);
            end
            ShapeId=self.ActionInfo.ShapeId;
            for i=1:numel(ShapeId)
                ShapeObj=self.ActionInfo.ShapeObj(i);
                info=(self.ActionInfo.ShapeInfo(i));
                insertShapeObject(self,ShapeObj,info);
                if strcmpi(self.ActionInfo.SelectionView,'Canvas')
                    callAddedOnAllChildren(self,ShapeObj);
                else
                    restoreVarMaps(self.Model,ShapeObj);
                end
            end
            OrphanOperationsId=self.ActionInfo.OrphanOperationsId;
            for i=1:numel(OrphanOperationsId)
                OrphanOperationsObj=self.ActionInfo.OrphanOperationsObj(i);
                info=(self.ActionInfo.OrphanOperationsInfo(i));
                insertOperationObject(self,OrphanOperationsObj,info);
            end
            OperationId=self.ActionInfo.OperationId;
            for i=1:numel(OperationId)
                OperationObj=self.ActionInfo.OperationObj(i);
                info=(self.ActionInfo.OperationInfo(i));
                insertOperationObject(self,OperationObj,info);
            end
        end


        function removeOperationObject(self,opnObj,infoval)
            parentShapeObj=opnObj.Parent;
            finpar=parentShapeObj.Group;

            opnObj.removeParent();
            parentShapeObj.updateShape();
            childShapes=opnObj.Children;
            childId=[childShapes.Id];
            [~,idx]=setdiff(childId,self.ActionInfo.ShapeId);
            if~isempty(idx)
                shapeObjNotDelete=opnObj.Children(idx);

                for i=1:numel(shapeObjNotDelete)
                    opnObj.removeChild(shapeObjNotDelete(i));
                    addChild(finpar,shapeObjNotDelete(i));
                    shapeParentChanged(self.Model,shapeObjNotDelete(i));
                end
            end
            self.Model.removeOperationFromStack(opnObj.Id);
            operationDeleted(self.Model,infoval);
            if strcmpi(finpar.CategoryType,'Layer')
                layerUpdated(self.Model,finpar);
            end
            shapeObjParent=getFinalShapeParent(self.Model,parentShapeObj);
            shapePropertyChanged(self.Model,shapeObjParent);

        end


        function removeShapeObject(self,shapeobj,infoval)

            parentObj=shapeobj.Parent;
            if~isempty(shapeobj.Parent)
                shapeobj.removeParent();
                if strcmpi(parentObj.CategoryType,'Layer')
                    layerUpdated(self.Model,parentObj);
                end
            end
            if strcmpi(self.ActionInfo.SelectionView,'Canvas')

                self.Model.removeShapeTreeFromStack(shapeobj);
            else
                self.Model.removeShapeFromStack(shapeobj.Id);
            end
            shapeDeleted(self.Model,infoval);

        end


        function insertShapeObject(self,shapeobj,infoval)
            groupLayer=getObject(self.Model,'Layer',infoval.GroupInfo.Id);
            addGroupToChildren(self.Model,shapeobj,groupLayer)
            if strcmpi(infoval.ParentType,'Layer')
                layerobj=getObject(self.Model,'Layer',infoval.ParentId);
                layerobj.addShape(shapeobj);
                layerUpdated(self.Model,layerobj);
            elseif any(strcmpi(infoval.ParentType,{'Operation','Add','Subtract','Xor','Intersect'}))
                opndeleted=setdiff(infoval.ParentId,self.ActionInfo.OperationId);
                orphanOpnDeleted=setdiff(infoval.ParentId,self.ActionInfo.OrphanOperationsId);
                if isempty(opndeleted)
                    opnobj=self.ActionInfo.OperationObj(self.ActionInfo.OperationId==infoval.ParentId);
                elseif isempty(orphanOpnDeleted)
                    opnobj=self.ActionInfo.OrphanOperationsObj(self.ActionInfo.OrphanOperationsId==infoval.ParentId);
                else
                    opnobj=getObject(self.Model,'Operation',infoval.ParentId);
                end
                opnobj.addChild(shapeobj);
            end

            if strcmpi(self.ActionInfo.SelectionView,'Canvas')

                self.Model.addShapeTreeToStack(shapeobj);
            else
                self.Model.addShapeObjToStack(shapeobj);
            end

            shapeAdded(self.Model,shapeobj);

        end


        function insertOperationObject(self,opnObj,infoval)
            if isempty(setdiff(infoval.ParentId,self.ActionInfo.ShapeId))
                shapeobj=self.ActionInfo.ShapeObj(infoval.ParentId==self.ActionInfo.ShapeId);
            else
                shapeobj=getObject(self.Model,'Shape',infoval.ParentId);
            end
            childid=infoval.ChildrenId;
            childnotdeleted=setdiff(childid,self.ActionInfo.ShapeId);
            for i=1:numel(childnotdeleted)
                childshapeobj=getObject(self.Model,'Shape',childnotdeleted(i));
                addChild(opnObj,childshapeobj)
                shapeParentChanged(self.Model,childshapeobj);
            end
            shapeobj.addOperation(opnObj,infoval.Index);
            shapeParentChanged(self.Model,shapeobj);
            self.Model.addOperationsObjToStack(opnObj);
            operationAdded(self.Model,opnObj);

        end


        function deleteLayerObject(self,layerobj,infoval)
            childShapes=layerobj.Children;
            if~isempty(childShapes)
                for i=1:numel(childShapes)
                    callDeletedOnAllChildren(self,childShapes(i));
                end
            end
            deleteLayer(self.Model,layerobj);
            layerobj.deleteDependentVariableMaps();
            layerDeleted(self.Model,infoval);
        end


        function addLayerObject(self,layerobj,infoval)
            insertLayer(self.Model,layerobj,infoval.Index);
            restoreVarMaps(self.Model,layerobj);
            layerAdded(self.Model,layerobj);
            childShapes=layerobj.Children;
            if~isempty(childShapes)
                for i=1:numel(childShapes)
                    callAddedOnAllChildren(self,childShapes(i));
                end
            end
        end


        function deleteFeedObject(self,feedobj,infoval)
            removeFeed(self.Model,feedobj.Id);
            feedobj.deleteDependentVariableMaps();
            feedDeleted(self.Model,infoval);
        end


        function deleteViaObject(self,viaobj,infoval)
            removeVia(self.Model,viaobj.Id);
            viaobj.deleteDependentVariableMaps();
            viaDeleted(self.Model,infoval);
        end


        function deleteLoadObject(self,loadobj,infoval)
            removeLoad(self.Model,loadobj.Id);
            loadobj.deleteDependentVariableMaps();
            loadDeleted(self.Model,infoval);
        end


        function addFeedObject(self,feedobj,infoval)
            addFeed(self.Model,feedobj,infoval);
            restoreVarMaps(self,feedobj);
            feedAdded(self.Model,feedobj);
        end


        function addViaObject(self,viaobj,infoval)
            addVia(self.Model,viaobj,infoval);
            restoreVarMaps(self,viaobj);
            viaAdded(self.Model,viaobj);
        end


        function addLoadObject(self,loadobj,infoval)
            addLoad(self.Model,loadobj,infoval);
            restoreVarMaps(self,loadobj);
            loadAdded(self.Model,loadobj);
        end


        function par=getFinalParent(self,obj)
            tmp=obj;
            while~isempty(tmp.Parent)
                tmp=tmp.Parent;
            end
            if~(strcmpi(tmp.Type,obj.Type)&&tmp.Id==obj.Id)
                par=tmp;
            else
                par=[];
            end
        end


        function delete(self)
        end


        function nodedepth=getNodeDepth(self,obj)
            nodedepth=0;
            tmp=obj;
            while~isempty(tmp.Parent)
                tmp=tmp.Parent;
                nodedepth=nodedepth+1;
            end
        end


        function restoreVarMaps(self,actObj)
            props=fields(actObj.PropertyValueMap);
            for i=1:numel(props)
                fcnhandle=actObj.PropertyValueMap.(props{i});
                if~isempty(fcnhandle)
                    self.Model.VariablesManager.setValueToObject(actObj,props{i},...
                    fcnhandle);
                end
            end

        end


        function callDeletedOnAllChildren(self,actObj)
            childrenShapes=getChildrenShapes(actObj);
            for i=1:numel(childrenShapes)
                callDeletedOnAllChildren(self,childrenShapes(i))
            end
            opnChildren=actObj.Children;
            for i=1:numel(opnChildren)
                infoval=getInfo(opnChildren(i));
                operationDeleted(self.Model,infoval);
            end

            infoval=getInfo(actObj);
            actObj.deleteDependentVariableMaps();
            shapeDeleted(self.Model,infoval);
        end


        function callAddedOnAllChildren(self,actObj)
            childrenShapes=getChildrenShapes(actObj);

            infoval=getInfo(actObj);
            restoreVarMaps(self,actObj);
            shapeAdded(self.Model,actObj);

            opnChildren=actObj.Children;
            for i=1:numel(opnChildren)
                infoval=getInfo(opnChildren(i));
                operationAdded(self.Model,opnChildren(i));
            end

            for i=1:numel(childrenShapes)
                callAddedOnAllChildren(self,childrenShapes(i))
            end
        end
    end
end
