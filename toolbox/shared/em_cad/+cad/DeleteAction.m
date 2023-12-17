classdef DeleteAction<cad.Actions

    properties

    end


    methods

        function self=DeleteAction(Model,evt)
            self.Type='Delete';
            self.Model=Model;
            self.ActionObjectType=evt.CategoryType;
            switch self.ActionObjectType
            case 'Shape'
                self.ActionObject=getShapeObj(self.Model,evt.Data.Id);
                self.ActionInfo=getInfo(self.ActionObject);
                self.ActionInfo.FinalParent=getFinalParent(self.Model,self.ActionObject);
                self.ActionInfo.TotalShape=evt.Data.TotalShape;
            case 'Operation'
                self.ActionObject=getOperationObj(self.Model,evt.Data.Id);
                self.ActionInfo=getInfo(self.ActionObject);
                self.ActionInfo.FinalParent=getFinalParent(self.Model,self.ActionObject);

            case 'Layer'
                self.ActionObject=findlayerobj(self.Model,evt.Data.Id);
                self.ActionInfo=getLayerInfo(self.ActionObject);
            case 'BoardShape'
            case 'Feed'
                self.ActionObject=getFeedObj(self.Model,evt.Data.Id);
                self.ActionInfo=getInfo(self.ActionObject);
            case 'Via'
                self.ActionObject=getViaObj(self.Model,evt.Data.Id);
                self.ActionInfo=getInfo(self.ActionObject);
            case 'Load'
                self.ActionObject=getLoadObj(self.Model,evt.Data.Id);
                self.ActionInfo=getInfo(self.ActionObject);
            end
        end


        function undo(self)

            switch self.ActionObjectType
            case 'Shape'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getShapeObj(self.Model,self.ActionInfo.Id);
                end
                if~self.ActionInfo.TotalShape
                    tmp=self.ActionInfo.ChildrenChildrenId;
                    for i=1:numel(tmp)
                        for j=1:numel(tmp{i})
                            shapeObj=getShapeObj(self.Model,tmp{i}(j));
                            addParent(shapeObj,self.ActionObject.Children(i));
                        end
                    end
                end
                if~(strcmpi(self.ActionInfo.ParentType,'Layer'))
                    if numel(self.ActionInfo.ParentChildrenId)==1
                        shapeObj=getShapeObj(self.Model,self.ActionInfo.ParentParentId);
                        shapeObj.addChild(self.ActionObject.Parent,self.ActionObject.Parent.Index);

                    elseif numel(self.ActionInfo.ParentChildrenId)>=1
                        opnObj=getOperationObj(self.Model,self.ActionObj.ParentId);
                        addChild(opnObj,self.ActionObject);
                    end
                else
                    self.Model.Group.addShape(self.ActionObject);
                end
                if~(self.ActionInfo.TotalShape)
                    restoreVarMaps(self,self.ActionObject);
                    shapeAdded(self.Model,self.ActionObject);
                else
                    callAddedOnAllChildren(self,self.ActionObject);
                end
            case 'Operation'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getOperationObj(self.Model,self.ActionInfo.Id);
                end
                for i=1:numel(self.ActionInfo.ChildrenId)
                    shapeObj=getShapeObj(self.Model,self.ActionInfo.ChildrenId(i));
                    shapeObj.addParent(self.ActionObject);
                end
                if isfield(self.ActionInfo,'ObjectInfo')
                    info=self.ActionInfo.ObjectInfo;
                end
                shapeObj=getShapeObj(self.Model,self.ActionInfo.ParentId);
                addOperation(shapeObj,self.ActionObject,self.ActionObject.Index);
                operationAdded(self.Model,self.ActionObject);
            case 'Layer'
                if~isvalid(self.ActionObject)
                    self.ActionObject=findlayerobj(self.Model,self.ActionInfo.Id);
                end
                insertLayer(self.Model,self.ActionObject,self.ActionInfo.Index);
                restoreVarMaps(self,self.ActionObject);
                layerAdded(self.Model,self.ActionObject);
                childShapes=self.ActionObject.Children;
                if~isempty(childShapes)
                    for i=1:numel(childShapes)
                        callAddedOnAllChildren(self,childShapes(i));
                    end
                end


            case 'BoardShape'
            case 'Feed'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getFeedObj(self.Model,self.ActionInfo.Id);
                end
                addFeed(self.Model,self.ActionObject);
                restoreVarMaps(self,self.ActionObject);
                feedAdded(self.Model,self.ActionObject);
            case 'Via'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getViaObj(self.Model,self.ActionInfo.Id);
                end
                addVia(self.Model,self.ActionObject);
                restoreVarMaps(self,self.ActionObject);
                viaAdded(self.Model,self.ActionObject);
            case 'Load'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getLoadObj(self.Model,self.ActionInfo.Id);
                end
                addLoad(self.Model,self.ActionObject);
                restoreVarMaps(self,self.ActionObject);
                loadAdded(self.Model);
            end
        end


        function execute(self)
            switch self.ActionObjectType

            case 'Shape'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getShapeObj(self.Model,self.ActionInfo.Id);
                end
                infoval=getInfo(self.ActionObject);
                if numel(self.ActionInfo.ParentChildrenId)==1
                    self.ActionObject.Parent.removeParent();


                elseif numel(self.ActionInfo.ParentChildrenId)>=1
                    self.ActionObject.removeParent();
                end

                if~self.ActionInfo.TotalShape

                    tmp=self.ActionInfo.ChildrenChildrenId;
                    for i=1:numel(tmp)
                        for j=1:numel(tmp{i})
                            shapeObj=getShapeObj(self.Model,tmp{i}(j));
                            removeParent(shapeObj);
                        end
                    end
                end
                if~(self.ActionInfo.TotalShape)
                    shapeDeleted(self.Model,infoval);
                    shapeObj.deleteDependentVariableMaps();
                else
                    callDeletedOnAllChildren(self,self.ActionObject);
                end
            case 'Operation'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getOperationObj(self.Model,self.ActionInfo.Id);
                end
                parentShapeObj=self.ActionObject.Parent;
                childShapeObj=self.ActionObject.Children;
                infoval=getInfo(self.ActionObject);
                self.ActionObject.removeParent();
                finpar=getFinalParent(self,parentShapeObj);

                for i=1:numel(self.ActionObject.Children)
                    self.ActionObject.removeChild(childShapeObj(i));
                    addChild(finpar,childShapeObj(i));
                end
                self.ActionInfo.ObjectInfo=infoval;
                operationDeleted(self.Model,infoval);
            case 'Layer'
                if~isvalid(self.ActionObject)
                    self.ActionObject=findlayerobj(self.Model,self.ActionInfo.Id);
                end
                childShapes=self.ActionObject.Children;
                if~isempty(childShapes)
                    for i=1:numel(childShapes)
                        callDeletedOnAllChildrenChildren(self,childShapes(i));
                    end
                end
                removelayerObjFromStack(self.Model,self.ActionObject);
                self.ActionObject.deleteDependentVariableMaps();
                layerDeleted(self.Model,self.ActionInfo);
                reindexlayers(self.Model);
            case 'BoardShape'
            case 'Feed'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getFeedObj(self.Model,self.ActionInfo.Id);
                end
                removeFeed(self.Model,self.ActionObject.Id);
                self.ActionObject.deleteDependentVariableMaps();
                feedDeleted(self.Model,getInfo(self.ActionObject));
            case 'Via'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getViaObj(self.Model,self.ActionInfo.Id);
                end
                removeVia(self.Model,self.ActionObject.Id);
                self.ActionObject.deleteDependentVariableMaps();
                viaDeleted(self.Model,getInfo(self.ActionObject));
            case 'Load'
                if~isvalid(self.ActionObject)
                    self.ActionObject=getLoadObj(self.Model,self.ActionInfo.Id);
                end
                removeLoad(self.Model,self.ActionObject.Id);
                self.ActionObject.deleteDependentVariableMaps();
                loadDeleted(self.Model,getInfo(self.ActionObject));
            end
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
            shapeDeleted(self.Model,infoval);
            actObj.deleteDependentVariableMaps();
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
    end
end
