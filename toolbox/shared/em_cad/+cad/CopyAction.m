classdef CopyAction<cad.Actions

    methods

        function self=CopyAction(Model,evt)
            self.Type=evt.Type;
            self.Model=Model;
            self.ActionObjectType=evt.Type;
            if isempty(evt.Data)
                self.ActionInfo.Selection=self.Model.SelectedObj;
            else
                self.Actionobj.Selection=evt.Data;
            end
            self.Actioninfo.PreviousClipBoard=self.Model.ClipBoard;
            self.Actioninfo.PreviousClipBoardType=self.Model.ClipBoardType;
        end


        function undo(self)
            cutobject=self.ActionObject;
            clearClipBoard(self.Model);
            self.ClipBoard=self.Actioninfo.PreviousClipBoard;
            self.ClipBoardType=elf.ActionInfo.PrevuiousClipBoardType;
        end


        function execute(self)
            cutobject=[];
            selectiondata=self.ActionInfo.Selection;
            for i=1:numel(selectiondata{1})
                if isempty(cutobject)
                    cutobject=copyobjectTypeId(self.Model,selectiondata{1}{i},selectiondata{2}(i));

                else
                    cutobject=[cutobject;copyobjectTypeId(self.Model,selectiondata{1}{i},selectiondata{2}(i))];
                end
            end
            self.ActionObject=cutobject;
            for i=1:numel(cutobject)
                removeDependentMapForTree(self,cutobject(i))
            end
            self.ActionInfo.GroupId={cutobject.getGroupId()};
            self.Model.ClipBoard=cutobject;
            self.Model.ClipBoardType='Copy';
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


        function callDeletedOnAllChildren(self,actObj)
            if strcmpi(actObj.categoryType,'Shape')
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
            else
                infoval=getInfo(actObj);
                if strcmpi(actobj.Type,'Feed')
                    feedDeleted(self.Model,actObj);
                elseif strcmpi(actobj.Type,'via')
                    viaDeleted(self.Model,actObj);
                elseif strcmpi(actobj.Type,'load')
                    loadDeleted(self.Model,actObj);
                end
            end
        end


        function callAddedOnAllChildren(self,actObj)
            if strcmpi(actObj.categoryType,'Shape')
                childrenShapes=getChildrenShapes(actObj);

                infoval=getInfo(actObj);
                shapeAdded(self.Model,actObj);
                opnChildren=actObj.Children;
                for i=1:numel(opnChildren)
                    infoval=getInfo(opnChildren(i));
                    operationAdded(self.Model,opnChildren(i));
                end

                for i=1:numel(childrenShapes)
                    callAddedOnAllChildren(self,childrenShapes(i))
                end
            else
                infoval=getInfo(actObj);
                if strcmpi(actobj.Type,'Feed')
                    feedAdded(self.Model,actObj);
                elseif strcmpi(actobj.Type,'via')
                    viaAdded(self.Model,actObj);
                elseif strcmpi(actobj.Type,'load')
                    loadAdded(self.Model,actObj);
                end
            end
        end
    end
end
