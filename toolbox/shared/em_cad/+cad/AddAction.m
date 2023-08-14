classdef AddAction<cad.Actions












    methods

        function self=AddAction(Model,evt)

            self.Type='Add';
            self.Model=Model;
            self.ActionObjectType=evt.CategoryType;
            switch self.ActionObjectType
            case 'Shape'

                self.ActionInfo.ShapeType=evt.ObjectType;
                if strcmpi(self.ActionInfo.ShapeType,'Polygon')

                    self.ActionInfo.Vertices=evt.Data.Vertices;
                end


                self.ActionInfo.BBox=evt.Data.BBox;
            case 'Operation'


                self.ActionInfo.Name=evt.ObjectType;
                self.ActionInfo.ShapeIDval=evt.Data.ShapesId;
                if strcmpi(self.ActionInfo.Name,'Move')
                    self.ActionInfo.FirstPoint=evt.Data.FirstPoint;
                    self.ActionInfo.LastPoint=evt.Data.LastPoint;
                elseif strcmpi(self.ActionInfo.Name,'Resize')
                    self.ActionInfo.BoundsVal=evt.Data.BoundsVal;
                elseif strcmpi(self.ActionInfo.Name,'Rotate')
                    self.ActionInfo.RotateVal=evt.Data.RotateVal;
                    self.ActionInfo.RotateAxis=evt.Data.RotateAxis;
                end
            case 'Layer'

                self.ActionInfo.LayerType=evt.ObjectType;
                self.ActionInfo.CurrentLayerId=self.Model.Group.Id;
            case 'Feed'


                self.ActionInfo.FeedType=evt.ObjectType;
                self.ActionInfo.CurrentLayerId=self.Model.Group.Id;
                self.ActionInfo.BBox=evt.Data.BBox;
            case 'Via'

                self.ActionInfo.ViaType=evt.ObjectType;
                self.ActionInfo.CurrentLayerId=self.Model.Group.Id;
                self.ActionInfo.BBox=evt.Data.BBox;
            case 'Load'

                self.ActionInfo.LoadType=evt.ObjectType;
                self.ActionInfo.CurrentLayerId=self.Model.Group.Id;
                self.ActionInfo.BBox=evt.Data.BBox;
            end
        end

        function undo(self)
            switch self.ActionObjectType
            case 'Shape'
                parentlayer=self.ActionObject.Parent;
                infoVal=getInfo(self.ActionObject);
                deleteNewShape(self.Model,self.ActionObject.Id);
                shapeDeleted(self.Model,infoVal);
                layerUpdated(self.Model,parentlayer);
            case 'Operation'
                for i=1:numel(self.ActionInfo.ShapeIDval)
                    shapesObj(i)=getShapeObj(self.Model,self.ActionInfo.ShapeIDval(i));
                end
                if strcmpi(self.ActionInfo.Name,'Move')
                    for i=1:numel(self.ActionInfo.ShapeIDval)
                        callOperationToSubTree(self.Model,self.ActionInfo.Name,...
                        shapesObj(i),self.ActionInfo.LastPoint,self.ActionInfo.FirstPoint);
                        shapesObj(i).updated();
                    end

                elseif strcmpi(self.ActionInfo.Name,'Resize')
                    for i=1:numel(self.ActionInfo.ShapeIDval)
                        callOperationToSubTree(self.Model,self.ActionInfo.Name,...
                        shapesObj(i),self.ActionInfo.BoundsVal(2:-1:1));
                        shapesObj(i).updated();
                    end
                elseif strcmpi(self.ActionInfo.Name,'Rotate')
                    for i=1:numel(self.ActionInfo.ShapeIDval)
                        callOperationToSubTree(self.Model,self.ActionInfo.Name,...
                        shapesObj(i),[self.ActionInfo.RotateVal(2),self.ActionInfo.RotateVal(1)],self.ActionInfo.RotateAxis);
                        shapesObj(i).updated();
                    end

                else
                    for i=1:numel(self.ActionObject)
                        infoVal=getInfo(self.ActionObject(i));
                        childrenShapesValNew=self.ActionObject(i).Children;
                        for j=1:numel(self.ActionObject(i).Children)
                            self.Model.Group.addShape(childrenShapesValNew(j));
                        end
                        deleteNewOperation(self.Model,self.ActionObject(i).Id);
                        operationDeleted(self.Model,infoVal);

                    end
                end

                for i=1:numel(shapesObj)

                    shapeParentChanged(self.Model,shapesObj(i));
                end
                layerUpdated(self.Model,shapesObj(1).Group);
            case 'Layer'
                infoVal=getLayerInfo(self.ActionObject);

                layerobj=findlayerobj(self.Model,self.ActionInfo.CurrentLayerId);
                setGroup(self.Model,layerobj);

                deleteNewLayer(self.Model,infoVal.Id);
                layerDeleted(self.Model,infoVal);

                currentLayerChanged(self.Model);
            case 'BoardShape'
            case 'Feed'
                infoVal=getInfo(self.ActionObject);
                deleteNewFeed(self.Model,self.ActionObject.Id);
                feedDeleted(self.Model,infoVal);
                layerUpdated(self.Model,findlayerobj(self.Model,infoVal.Args.StartLayer.Id));

            case 'Via'
                infoVal=getInfo(self.ActionObject);
                deleteNewVia(self.Model,self.ActionObject.Id);
                viaDeleted(self.Model,infoVal);
                layerUpdated(self.Model,findlayerobj(self.Model,infoVal.Args.StartLayer.Id));
            case 'Load'
                infoVal=getInfo(self.ActionObject);
                deleteNewLoad(self.Model,self.ActionObject.Id);
                loadDeleted(self.Model,infoVal);
                layerUpdated(self.Model,findlayerobj(self.Model,infoVal.Args.StartLayer.Id));
            end
        end

        function execute(self)

            switch self.ActionObjectType
            case 'Shape'

                if isfield(self.ActionInfo,'ObjectInfo')


                    if strcmpi(self.ActionInfo.ShapeType,'Polygon')
                        self.ActionObject=self.Model.createNewShape(self.ActionInfo.ShapeType,...
                        self.ActionInfo.BBox,self.ActionInfo.ObjectInfo,self.ActionInfo.Vertices);
                    else
                        self.ActionObject=self.Model.createNewShape(self.ActionInfo.ShapeType,...
                        self.ActionInfo.BBox,self.ActionInfo.ObjectInfo);
                    end
                else


                    if strcmpi(self.ActionInfo.ShapeType,'Polygon')
                        self.ActionObject=self.Model.createNewShape(self.ActionInfo.ShapeType,...
                        self.ActionInfo.BBox,self.ActionInfo.Vertices);
                    else
                        self.ActionObject=self.Model.createNewShape(self.ActionInfo.ShapeType,...
                        self.ActionInfo.BBox);
                    end


                    self.ActionInfo.ObjectInfo=getInfo(self.ActionObject);
                end

                shapeAdded(self.Model,self.ActionObject);

                layerUpdated(self.Model,self.ActionObject.Group);
            case 'Operation'


                for i=1:numel(self.ActionInfo.ShapeIDval)
                    shapesObj(i)=getShapeObj(self.Model,self.ActionInfo.ShapeIDval(i));
                end

                if strcmpi(self.ActionInfo.Name,'Move')
                    for i=1:numel(self.ActionInfo.ShapeIDval)
                        callOperationToSubTree(self.Model,self.ActionInfo.Name,...
                        shapesObj(i),self.ActionInfo.FirstPoint,self.ActionInfo.LastPoint);
                        shapesObj(i).updated();
                    end
                    self.Model.setSelectedObj(shapesObj);

                elseif strcmpi(self.ActionInfo.Name,'Resize')
                    for i=1:numel(self.ActionInfo.ShapeIDval)
                        callOperationToSubTree(self.Model,self.ActionInfo.Name,...
                        shapesObj(i),self.ActionInfo.BoundsVal);
                        shapesObj(i).updated();
                    end
                    self.Model.setSelectedObj(shapesObj);

                elseif strcmpi(self.ActionInfo.Name,'Rotate')
                    for i=1:numel(self.ActionInfo.ShapeIDval)
                        callOperationToSubTree(self.Model,self.ActionInfo.Name,...
                        shapesObj(i),self.ActionInfo.RotateVal,self.ActionInfo.RotateAxis);
                        shapesObj(i).updated();
                    end
                    self.Model.setSelectedObj(shapesObj);


                else



                    if isfield(self.ActionInfo,'ObjectInfo')
                        self.ActionObject=self.Model.createNewOperation(self.ActionInfo.Name,...
                        shapesObj,self.ActionInfo.ObjectInfo);
                    else
                        self.ActionObject=self.Model.createNewOperation(self.ActionInfo.Name,...
                        shapesObj);

                        self.ActionInfo.ObjectInfo=getInfo(self.ActionObject);
                    end
                    for i=1:numel(shapesObj)

                        shapeParentChanged(self.Model,shapesObj(i));
                    end



                    self.Model.setSelectedObj(shapesObj(1));
                end


                layerUpdated(self.Model,shapesObj(1).Group);

            case 'Layer'
                if isfield(self.ActionInfo,'ObjectInfo')

                    self.ActionObject=self.Model.createNewLayer(self.ActionInfo.LayerType,...
                    self.ActionInfo.ObjectInfo);
                else

                    self.ActionObject=self.Model.createNewLayer(self.ActionInfo.LayerType);

                    self.ActionInfo.ObjectInfo=getLayerInfo(self.ActionObject);
                end


                layerAdded(self.Model,self.ActionObject);

                setGroup(self.Model,self.ActionObject);

                currentLayerChanged(self.Model);
            case 'Feed'
                if isfield(self.ActionInfo,'ObjectInfo')

                    self.ActionObject=self.Model.createNewFeed(self.ActionInfo.FeedType,...
                    self.ActionInfo.BBox,self.ActionInfo.ObjectInfo);
                else

                    self.ActionObject=self.Model.createNewFeed(self.ActionInfo.FeedType,self.ActionInfo.BBox);

                    self.ActionInfo.ObjectInfo=getInfo(self.ActionObject);
                end

                feedAdded(self.Model,self.ActionObject);
                layerUpdated(self.Model,self.ActionObject.StartLayer);
            case 'Via'
                if isfield(self.ActionInfo,'ObjectInfo')
                    self.ActionObject=self.Model.createNewVia(self.ActionInfo.ViaType,...
                    self.ActionInfo.BBox,self.ActionInfo.ObjectInfo);
                else
                    self.ActionObject=self.Model.createNewVia(self.ActionInfo.ViaType,self.ActionInfo.BBox);
                    self.ActionInfo.ObjectInfo=getInfo(self.ActionObject);
                end

                viaAdded(self.Model,self.ActionObject);
                layerUpdated(self.Model,self.ActionObject.StartLayer);
            case 'Load'
                if isfield(self.ActionInfo,'ObjectInfo')
                    self.ActionObject=self.Model.createNewLoad(self.ActionInfo.LoadType,...
                    self.ActionInfo.BBox,self.ActionInfo.ObjectInfo);
                else
                    self.ActionObject=self.Model.createNewLoad(self.ActionInfo.LoadType,self.ActionInfo.BBox);
                    self.ActionInfo.ObjectInfo=getInfo(self.ActionObject);
                end

                loadAdded(self.Model,self.ActionObject);
                layerUpdated(self.Model,self.ActionObject.StartLayer);
            end
        end

    end
end
