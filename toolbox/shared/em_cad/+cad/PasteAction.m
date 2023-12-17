classdef PasteAction<cad.Actions

    methods

        function self=PasteAction(Model,evt)
            self.Type='Paste';
            self.Model=Model;
            self.ActionObject=[];
            self.ActionInfo.LayerId=evt.Data.LayerId;
            self.ActionInfo.AxesLim=evt.Data.AxesLim;
            self.ActionInfo.ClipBoardType=self.Model.ClipBoardType;
            self.ActionInfo.ClipBoard=self.Model.ClipBoard;
        end


        function undo(self)

            pastedobj=self.ActionObject;
            for i=1:numel(pastedobj)
                removeobject(self.Model,pastedobj(i));
                removeDependentMapForTree(self.Model,pastedobj(i));
                callDeletedOnAllChildren(self,pastedobj(i));
            end
            if strcmpi(self.ActionInfo.ClipBoardType,'Cut')
                self.Model.ClipBoard=self.ActionInfo.ClipBoardObj;
            else
                self.Model.PasteObjList(end-numel(self.Model.ClipBoard)+1:end,:)=[];
            end
            self.Model.ClipBoardType=self.ActionInfo.ClipBoardType;

        end


        function execute(self)
            clipBoardObj=self.Model.ClipBoard;
            pastedobject=[];
            point1=[mean(self.ActionInfo.AxesLim'),0];
            cornerpt=[self.ActionInfo.AxesLim(1,2),self.ActionInfo.AxesLim(2,1),0];
            diffmove=cornerpt-point1;
            for i=1:numel(clipBoardObj)

                layerobj=findlayerobj(self.Model,self.ActionInfo.LayerId);
                if strcmpi(self.ActionInfo.ClipBoardType,'Copy')

                    if~isempty(self.Model.Actions)
                        actiontypes={self.Model.Actions.Type};
                    else
                        actiontypes={''};
                    end
                    numcpy=strcmpi(actiontypes,'Paste');
                    indx=find(numcpy,1,'first');
                    indxotheract=find(~numcpy,1,"first");
                    if isempty(indxotheract)
                        indx=sum(numcpy);
                    else
                        indx=indxotheract-indx;
                        if indx<0
                            indx=1;
                        end
                    end
                    if isempty(indx)
                        indx=numel(actiontypes);
                    end

                    if isempty(self.ActionObject)
                        pasteobj=copyobject(self.Model,clipBoardObj(i));


                        if strcmpi(pasteobj.CategoryType,'Shape')
                            addNewIdToShapeTree(self.Model,pasteobj);
                        else
                            addNewIdToShapeTree(self.Model,pasteobj);
                        end

                        self.Model.PasteObjList=[self.Model.PasteObjList;{clipBoardObj(i).Id,clipBoardObj(i).Name,clipBoardObj(i).CategoryType}];

                        previouslyCopiedInstancesWithSameId=[self.Model.PasteObjList{:,1}]==clipBoardObj(i).Id;
                        previouslyCopiedInstancesWithSameName=strcmpi(self.Model.PasteObjList(:,2),clipBoardObj(i).Name);
                        previouslyCopiedInstancesWithSameCategory=strcmpi(self.Model.PasteObjList(:,3),clipBoardObj(i).CategoryType);

                        previousCopiedInstances=previouslyCopiedInstancesWithSameId'&...
                        previouslyCopiedInstancesWithSameName&previouslyCopiedInstancesWithSameCategory;
                        indx=sum(previousCopiedInstances);

                        namestr=['_Copy',num2str(indx)];

                        appendNameToTree(self,pasteobj,namestr);


                        pasteobject(self.Model,pasteobj,layerobj);


                        if i==1
                            self.ActionInfo.GroupId={pasteobj.getGroupId()};
                        else
                            self.ActionInfo.GroupId=[self.ActionInfo.GroupId;{pasteobj.getGroupId()}];
                        end

                        moveobject(self.Model,pasteobj,point1,point1+diffmove.*0.1.*(indx))
                    else
                        pasteobj=self.ActionObject(i);
                        if strcmpi(pasteobj.CategoryType,'Shape')
                            prevlayerobj=findlayerobj(self.Model,self.ActionInfo.GroupId{i});

                        elseif strcmpi(pasteobj.CategoryType,'Connection')
                            prevlayerobj=[findlayerobj(self.Model,self.ActionInfo.GroupId{i}(1));...
                            findlayerobj(self.Model,self.ActionInfo.GroupId{i}(2))];
                            pasteobj.StartLayer=prevlayerobj(1);
                            pasteobj.StopLayer=prevlayerobj(2);
                        end
                        self.Model.PasteObjList=[self.Model.PasteObjList;{clipBoardObj(i).Id,clipBoardObj(i).Name,clipBoardObj(i).CategoryType}];


                        pasteobject(self.Model,pasteobj,layerobj);
                    end

                else
                    pasteobj=clipBoardObj(i);
                    self.Model.pasteobject(pasteobj,layerobj);
                end
                if isempty(pastedobject)
                    pastedobject=pasteobj;
                else
                    pastedobject=[pastedobject,pasteobj];
                end

                callAddedOnAllChildren(self,pasteobj);
            end

            if strcmpi(self.ActionInfo.ClipBoardType,'Cut')
                self.ActionInfo.ClipBoardObj=clipBoardObj;
                clearClipboard(self.Model);
            end
            self.ActionObject=pastedobject;
        end


        function appendNameToTree(self,actObj,namestr)

            if strcmpi(actObj.CategoryType,'Shape')
                childrenShapes=getChildrenShapes(actObj);
                for i=1:numel(childrenShapes)
                    appendNameToTree(self,childrenShapes(i),namestr)
                end
            end
            actObj.Name=[actObj.Name,namestr];
        end


        function callDeletedOnAllChildren(self,actObj)

            if strcmpi(actObj.CategoryType,'Shape')
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
                if strcmpi(actObj.Type,'Feed')
                    feedDeleted(self.Model,infoval);
                elseif strcmpi(actObj.Type,'via')
                    viaDeleted(self.Model,infoval);
                elseif strcmpi(actObj.Type,'load')
                    loadDeleted(self.Model,infoval);
                end
            end
        end


        function callAddedOnAllChildren(self,actObj)

            if strcmpi(actObj.CategoryType,'Shape')
                childrenShapes=getChildrenShapes(actObj);

                infoval=getInfo(actObj);
                self.Model.restoreVarMaps(actObj);
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
                self.Model.restoreVarMaps(actObj);
                if strcmpi(actObj.Type,'Feed')
                    feedAdded(self.Model,actObj);
                elseif strcmpi(actObj.Type,'via')
                    viaAdded(self.Model,actObj);
                elseif strcmpi(actObj.Type,'load')
                    loadAdded(self.Model,actObj);
                end
            end
        end

    end
end
