classdef CADModel<handle








    properties
SelectionView
ShapeStack
        ShapeIDVal=0;

OperationsStack
        OperationsIDVal=0;

ClipBoard





ShapeFactory

OperationFactory

Actions


RedoStack



Group



SelectedObj



SelectionViewType

ClipBoardType
ModelBusy





        Grid=struct('SnapToGrid',0,'GridSize',0.1);
        Units='mm';
        PasteObjList;
        VariablesManager cad.VariablesManager
    end

    methods
        function self=CADModel(ShapeFactoryObject,OperationFactoryObj)



            self.ShapeFactory=ShapeFactoryObject;
            self.OperationFactory=OperationFactoryObj;
            self.Group=cad.Layer(self,[0.2,0.2,0.2],0.3,1);
            self.VariablesManager=cad.VariablesManager;
        end

        function fact=getUnitsFactor(self)
            if isstruct(self.Units)
                self.Units=self.Units.Units;
            end
            switch self.Units
            case 'um'
                fact=1e-6;
            case 'mil'
                fact=2.54e-5;
            case 'mm'
                fact=1e-3;
            case 'cm'
                fact=1e-2;
            case 'in'
                fact=0.0254;
            case 'm'
                fact=1;
            end
        end

        function shapeObj=getShapeObj(self,id)



            ids=[self.ShapeStack.Id];
            shapeObj=self.ShapeStack(ids==id);
        end

        function removeShapeFromStack(self,id)


            ids=[self.ShapeStack.Id];
            self.ShapeStack(ids==id)=[];
        end

        function opnObj=getOperationObj(self,id)



            ids=[self.OperationsStack.Id];
            opnObj=self.OperationsStack(ids==id);
        end

        function removeOperationFromStack(self,id)


            ids=[self.OperationsStack.Id];
            self.OperationsStack(ids==id)=[];
        end

        function set.ModelBusy(self,val)

            self.ModelBusy=val;
        end
        function FinalParent=getFinalParent(self,obj)


            FinalParent=obj;
            while~isempty(FinalParent.Parent)
                FinalParent=FinalParent.Parent;
            end
        end

        function PrevParent=getFinalShapeParent(self,obj)



            FinalParent=obj;
            PrevParent=obj;
            while~isempty(FinalParent.Parent)
                PrevParent=FinalParent;
                FinalParent=FinalParent.Parent;
            end
        end

        function info=getInfo(self)
            args=getInfo(self.Group);
            info.LayerInfo=args;
            info.Grid=self.Grid;
            info.Units=self.Units;
            info.SelectionViewType=self.SelectionViewType;
        end


        function add(self,evt)



            if self.ModelBusy
                return;
            end

            self.ModelBusy=1;
            self.notify('ActionStarted');

            actionObj=cad.AddAction(self,evt);

            self.SelectedObj=struct('Data',[]);

            actionObj.execute;

            self.Actions=[actionObj;self.Actions];



            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function addVariable(self,evt)



            if self.ModelBusy
                return;
            end

            self.ModelBusy=1;
            self.notify('ActionStarted');

            actionObj=cad.AddVariableAction(self,evt);

            actionObj.execute;

            self.Actions=[actionObj;self.Actions];



            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function changeVariable(self,evt)



            if self.ModelBusy
                return;
            end

            self.ModelBusy=1;
            self.notify('ActionStarted');

            actionObj=cad.ChangeVariableAction(self,evt);

            try

                actionObj.execute;

                self.Actions=[actionObj;self.Actions];
            catch me

                actionObj.undo;
                actionObj.delete;

                msg=['Error while changing Variable ',evt.Name,':',newline,me.message];

                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'Error','Value','',msg,getInfo(self)));
            end



            self.clearRedoStack();
            clearClipboard(self);


            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function deleteVariable(self,evt)



            if self.ModelBusy
                return;
            end

            self.ModelBusy=1;
            self.notify('ActionStarted');

            actionObj=cad.DeleteVariableAction(self,evt);

            actionObj.execute;

            self.Actions=[actionObj;self.Actions];



            self.clearRedoStack();
            clearClipboard(self);

            layerUpdated(self,self.Group);
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function shapeObj=createNewShape(self,ShapeType,Args,varargin)
            if~isempty(varargin)

                if size(varargin{1},2)==3


                    vert=varargin{1};
                    varargin=[];
                else
                    if numel(varargin)==2



                        vert=varargin{2};
                    end
                end
            end
            if isempty(varargin)

                self.ShapeIDVal=self.ShapeIDVal+1;
                idVal=self.ShapeIDVal;
            else

                info=varargin{1};
                idVal=info.Id;
            end


            if strcmpi(ShapeType,'Polygon')
                shapeObj=self.ShapeFactory.createShape(self.Group,ShapeType,Args,idVal,vert);
            else
                shapeObj=self.ShapeFactory.createShape(self.Group,ShapeType,Args,idVal);
            end
            if~isempty(self.ShapeStack)
                typeidx=strcmpi({self.ShapeStack.Type},ShapeType);
                numtype=sum(typeidx);
                shapeObj.Name=[ShapeType,num2str(numtype+1)];
            end

            self.Group.addShape(shapeObj);
            addShapeObjToStack(self,shapeObj);
        end

        function addShapeObjToStack(self,shapeObj)

            self.ShapeStack=[self.ShapeStack,shapeObj];
        end

        function addOperationsObjToStack(self,opnObj)

            self.OperationsStack=[self.OperationsStack,opnObj];
        end

        function shapePropertyChanged(self,shapeObj)


            infoVal=getInfo(shapeObj);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'PropertyChanged','Shape',infoVal.Type,infoVal,getInfo(self),[]));
            end
        end

        function shapeAdded(self,shapeObj)


            infoVal=getInfo(shapeObj);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ShapeChanged','Shape',infoVal.Type,infoVal,getInfo(self),[]));
            Data={{'Shape'},[infoVal.Id]};



        end

        function valueChanged(self,evt)

            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');



            actionObj=cad.ValueChangedAction(self,evt);
            try

                actionObj.execute;

                self.Actions=[actionObj;self.Actions];
            catch me

                actionObj.undo;
                actionObj.delete;

                msg=['Error while changing ',evt.Data.Property,':',newline,me.message];

                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'Error','Value','',msg,getInfo(self)));
            end

            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));

            self.ModelBusy=0;
        end

        function opnObj=createNewOperation(self,OperationName,Shapes,varargin)




            if isempty(varargin)
                self.OperationsIDVal=self.OperationsIDVal+1;
                opnObj=self.OperationFactory.createOperation(OperationName,...
                Shapes(2:end),self.OperationsIDVal);
            else
                info=varargin{1};
                idval=info.Id;
                opnObj=self.OperationFactory.createOperation(OperationName,...
                Shapes(2:end),idval);
            end

            addOperation(Shapes(1),opnObj);
            addOperationsObjToStack(self,opnObj);
        end

        function operationAdded(self,opnObj)


            infoVal=getInfo(opnObj);
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'OperationAdded','Operation',infoVal.Type,infoVal,getInfo(self)));
            self.SelectedObj=[];
            self.SelectedObj.Data=[];
        end
        function deleteNewShape(self,id)

            shapeObj=getShapeObj(self,id);
            removeShapeFromStack(self,id);
            shapeObj.delete();
        end
        function shapeDeleted(self,infoVal)

            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ShapeDeleted','Shape',infoVal.Type,infoVal,getInfo(self),[]));
            Data=[];
            selected(self,cad.events.SelectionEventData(Data));

        end

        function operationDeleted(self,infoVal)

            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'OperationDeleted','Operation',infoVal.Type,infoVal,getInfo(self)));
        end
        function deleteNewOperation(self,id)

            opnObj=getOperationObj(self,id);
            removeOperationFromStack(self,id);
            opnObj.delete();
        end

        function shapeParentChanged(self,shapeObj)

            infoVal=getInfo(shapeObj);
            if isvalid(self)
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ShapeAdded','Shape',infoVal.Type,infoVal,getInfo(self),[]));
            end

        end

        function deleteAct(self,evt)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            actionObj=cad.SelectionDeleteAction(self,evt);
            actionObj.execute;
            self.Actions=[actionObj;self.Actions];

            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end


        function undo(self)



            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            if isempty(self.Actions)
                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                self.ModelBusy=0;
                return;
            end
            actionObj=self.Actions(1);
            self.RedoStack=[actionObj;self.RedoStack];
            self.Actions(1)=[];
            actionObj.undo();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end
        function redo(self)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            if isempty(self.RedoStack)
                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                self.ModelBusy=0;
                return;
            end
            actionObj=self.RedoStack(1);
            self.Actions=[actionObj;self.Actions];
            self.RedoStack(1)=[];
            actionObj.execute();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function layerobj=findlayerobj(self,id)
            layerobj=self.Group;
        end

        function object=getObject(self,type,id)
            if strcmpi(type,'Shape')
                object=(getShapeObj(self,id));
            elseif strcmpi(type,'Operation')
                object=getOperationObj(self,id);
            elseif strcmpi(type,'Layer')
                object=self.Group;
            end
        end

        function callOperationToSubTree(self,name,shapesObj,varargin)
            info=getInfo(shapesObj);
            if~info.EnableMove&&strcmpi(name,'Move')
                return;
            end
            if~info.EnableResize&&strcmpi(name,'Resize')
                return;
            end

            if~info.EnableRotate&&strcmpi(name,'Rotate')
                return;
            end

            childShapes=getChildrenShapes(shapesObj);

            for i=1:numel(childShapes)

                callOperationToSubTree(self,name,childShapes(i),varargin{:});

            end

            shapesObj.TriggerUpdate=0;
            if strcmpi(name,'Move')
                translateShape(shapesObj,varargin{1},varargin{2});
            elseif strcmpi(name,'Resize')
                resizeShape(shapesObj,varargin{1});
            elseif strcmpi(name,'Rotate')
                rotateShape(shapesObj,varargin{:});
            end
            shapesObj.TriggerUpdate=1;
            shapePropertyChanged(self,shapesObj);


        end

        function selected(self,evt)
            self.SelectionViewType=evt.SelectionView;
            if~isempty(evt.Data)
                LayerIdx=strcmpi('Layer',evt.Data{1});
                if any(LayerIdx)
                    layerIndex=find(LayerIdx,1,'last');
                    layerId=evt.Data{2}(layerIndex);
                    layerobj=findlayerobj(self,layerId);
                else
                    shapeIndex=strcmpi('Shape',evt.Data{1});
                    opnIndex=strcmpi('Operation',evt.Data{1});
                    if any(shapeIndex)
                        shapeIndex=find(shapeIndex,1,'last');
                        shapeObj=getShapeObj(self,evt.Data{2}(shapeIndex));

                    elseif any(opnIndex)
                        opnIndex=find(opnIndex,1,'last');
                        opnObj=getOperationObj(self,evt.Data{2}(opnIndex));

                    else
                        layerobj=[];
                    end


                end

                Args=cell(numel(evt.Data{1}),1);
                for i=1:numel(Args)
                    if strcmpi(evt.Data{1}{i},'Layer')
                        layerobj=findlayerobj(self,evt.Data{2}(i));
                        Args{i}=getInfo(layerobj);
                    elseif strcmpi(evt.Data{1}{i},'Shape')
                        shapeObj=getShapeObj(self,evt.Data{2}(i));
                        Args{i}=getInfo(shapeObj);
                    end
                end
                evt.Data{3}=Args;
                modelInfo=getInfo(self);
                evt.Data{4}=modelInfo;
            end

            self.SelectedObj.Data=evt.Data;
            if~isempty(evt.Data)
                if any(strcmpi(evt.Data{1},{'Feed'}))||any(strcmpi(evt.Data{1},{'Via'}))...
                    ||any(strcmpi(evt.Data{1},{'Load'}))
                    feedidx=strcmpi(evt.Data{1},{'Feed'});
                    viaidx=strcmpi(evt.Data{1},{'Via'});
                    loadidx=strcmpi(evt.Data{1},{'Load'});

                    idxval=feedidx|viaidx|loadidx;
                    self.SelectedObj.CategoryType=evt.Data{1};
                    self.SelectedObj.CategoryType(idxval)={'Connection'};
                else
                    self.SelectedObj.CategoryType=evt.Data{1};
                end
                self.SelectedObj.Type=evt.Data{1};
                self.SelectedObj.Id=evt.Data{2};
                self.SelectedObj.Args=evt.Data{3};
                self.SelectedObj.ModelInfo=evt.Data{4};
                self.SelectionView=evt.SelectionView;
            end
            self.notify('ModelChanged',cad.events....
            ModelChangedEventData('UpdateSelection','','',evt.Data,getInfo(self)));
        end

        function layerUpdated(self,layerobj)
            if~isvalid(self.Group)
                return;
            end
            infoVal=getInfo(layerobj);




            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'LayerUpdated','Shape',infoVal.Type,getInfo(self),getInfo(self)));

        end
        function moveobject(self,object,pt1,pt2)
            if strcmpi(object.CategoryType,'Shape')

                callOperationToSubTree(self,'Move',object,pt1,pt2)
            end
        end

        function clearRedoStack(self)



            if~isempty(self.RedoStack)
                for i=1:numel(self.RedoStack)
                    self.RedoStack(i).delete;
                end
                self.RedoStack=[];
            end
        end

        function clearActions(self)

            if~isempty(self.Actions)
                for i=1:numel(self.Actions)
                    self.Actions(i).delete;
                end
                self.Actions=[];
            end
        end

        function move(self,evt)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            actionObj=cad.MoveAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            self.clearRedoStack();
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;

        end

        function moveShape(self,Id,FirstPt,LastPt)

            shapeObj=self.getShapeObj(Id);
            translateShape(shapeObj,FirstPt,LastPt);
        end


        function cut(self,evt)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            if isempty(self.SelectedObj)

                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                self.ModelBusy=0;
                return;
            end

            actionObj=cad.CutAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            clearRedoStack(self);
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function clearClipboard(self)



            if strcmpi(self.ClipBoardType,'Copy')
                for i=1:numel(self.ClipBoard)
                    self.ClipBoard(i).delete;
                end
            end
            self.ClipBoard=[];
            self.ClipBoardType='';
        end

        function copy(self,evt)


            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            if isempty(self.SelectedObj)
                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                self.ModelBusy=0;
                return;
            end

            clearClipboard(self);
            clipboardobj=[];
            dataval=self.SelectedObj.Data;
            for j=1:numel(dataval{1})
                if any(strcmpi(dataval{1}{j},{'Layer','Operation','PCBAntenna','LayerTree'}))
                    continue;
                end
                clipboardobj=[clipboardobj;copyobjectTypeId(self,dataval{1}{j},...
                dataval{2}(j),self.SelectionView)];
            end
            for i=1:numel(clipboardobj)
                removeDependentMapForTree(self,clipboardobj(i));
            end
            self.ClipBoard=clipboardobj;
            self.ClipBoardType='Copy';
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function removeDependentMapForTree(self,obj)
            obj.deleteDependentVariableMaps();
            shapes=[];
            if isa(obj,'cad.Layer')
                shapes=obj.Children;
            elseif isa(obj,'cad.Polygon')
                shapes=getChildrenShapes(obj);
            end

            for i=1:numel(shapes)
                removeDependentMapForTree(self,shapes(i));
            end
        end

        function restoreVarMaps(self,actObj)
            props=fields(actObj.PropertyValueMap);
            for i=1:numel(props)
                fcnhandle=actObj.PropertyValueMap.(props{i});
                if~isempty(fcnhandle)
                    self.VariablesManager.setValueToObject(actObj,props{i},...
                    fcnhandle);
                end
            end

        end

        function c=copyobject(self,object)
            if strcmpi(object.CategoryType,'Shape')
                c=copy(object);
            end
        end

        function pasteobject(self,object,varargin)
            if strcmpi(object.CategoryType,'Shape')
                addGroupToChildren(self,object,varargin{1});
                addShapeTreeToStack(self,object);
                addShape(varargin{1},object);
                layerUpdated(self,object.Parent);
            end
        end

        function removeobject(self,object)
            if strcmpi(object.CategoryType,'Shape')
                removeShapeTreeFromStack(self,object);
                layerUpdated(self,object.Parent);
                removeParent(object);
            end
        end

        function c=copyobjectTypeId(self,type,id,selectionview)

            if strcmpi(type,'Shape')
                object=(getShapeObj(self,id));
                if strcmpi(selectionview,'Canvas')
                    c=copyobject(self,object);
                else
                    c=copyNode(object);
                end
            end
        end






        function addNewIdToShapeTree(self,obj)




            for i=1:numel(obj.Children)
                shapeobjChildren=obj.Children(i).Children;
                for j=1:numel(shapeobjChildren)
                    addNewIdToShapeTree(self,shapeobjChildren(j));
                end
                self.OperationsIDVal=self.OperationsIDVal+1;
                obj.Children(i).Id=self.OperationsIDVal;
            end
            self.ShapeIDVal=self.ShapeIDVal+1;
            obj.Id=self.ShapeIDVal;
        end

        function addShapeTreeToStack(self,obj)


            for i=1:numel(obj.Children)
                shapeobjChildren=obj.Children(i).Children;
                for j=1:numel(shapeobjChildren)
                    addShapeTreeToStack(self,shapeobjChildren(j));
                end
                addOperationsObjToStack(self,obj.Children(i));
            end
            addShapeObjToStack(self,obj);
        end

        function removeShapeTreeFromStack(self,obj)


            operationChildren=obj.Children;
            for i=1:numel(obj.Children)
                shapeobjChildren=obj.Children(i).Children;
                for j=1:numel(shapeobjChildren)
                    removeShapeTreeFromStack(self,shapeobjChildren(j));
                end
                removeOperationFromStack(self,operationChildren(i).Id);
            end
            removeShapeFromStack(self,obj.Id);
        end

        function addGroupToChildren(self,obj,group)


            childrenShapes=getChildrenShapes(obj);
            for i=1:numel(childrenShapes)
                addGroupToChildren(self,childrenShapes(i),group)
            end
            obj.Group=group;
        end

        function paste(self,evt)



            if self.ModelBusy
                return;
            end
            self.ModelBusy=1;
            self.notify('ActionStarted');
            if isempty(self.ClipBoard)
                self.ModelBusy=0;
                self.notify('ActionEnded');
                self.notify('ModelChanged',...
                cad.events.ModelChangedEventData(...
                'ActionEnded','','','',getInfo(self)));
                return;
            end
            actionObj=cad.PasteAction(self,evt);
            self.Actions=[actionObj;self.Actions];
            actionObj.execute;
            clearRedoStack(self);
            self.notify('ActionEnded');
            self.notify('ModelChanged',...
            cad.events.ModelChangedEventData(...
            'ActionEnded','','','',getInfo(self)));
            self.ModelBusy=0;
        end

        function addObjToClipBoard(self,obj)

            self.ClipBoard=obj;
        end


        function delete(self)

        end


    end
    events
ModelChanged
ActionStarted
ActionEnded
    end
end
