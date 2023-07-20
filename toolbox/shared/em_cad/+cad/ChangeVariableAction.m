classdef ChangeVariableAction<cad.Actions
    methods

        function self=ChangeVariableAction(Model,evt)
            self.Type="ChangeVariable";
            self.Model=Model;
            self.ActionInfo.Name=evt.Name;
            self.ActionInfo.Data.Indices=evt.Data.Indices;
            self.ActionInfo.Data.NewData=evt.Data.NewData;
            self.ActionInfo.Data.PreviousData=evt.Data.PreviousData;
        end

        function execute(self)
            evt=self.ActionInfo;
            if evt.Data.Indices(2)==3
                [funchandle,depvars,opval]=self.Model.VariablesManager.parseExpression(evt.Data.NewData);
                varobj=self.Model.VariablesManager.getVarObj(evt.Name);
                depShapeObj=self.getDependentObj(varobj,1);
                self.setTriggerUpdate(depShapeObj,0);
                if isempty(depvars)
                    self.Model.VariablesManager.set(evt.Name,opval);
                else
                    self.Model.VariablesManager.set(evt.Name,funchandle);
                end
                layerobj=self.updateTree(depShapeObj);

                self.setTriggerUpdate(depShapeObj,1);

                [depObj,varPropObj,propNames]=self.getDependentObj(varobj);
                depObj=arrayfun(@(x)x,depObj,'UniformOutput',false);
                for i=1:numel(depObj)
                    self.Model.callPropertyChanged(depObj{i},getInfo(depObj{i}));
                end

                for i=1:numel(layerobj)
                    if~(isa(layerobj(i),'cad.Layer'))
                        continue;
                    end
                    self.Model.callPropertyChanged(layerobj(i),getInfo(layerobj(i)));
                end

                if~isempty(varPropObj)
                    propNames=unique(propNames);
                    for i=1:numel(propNames)
                        if strcmpi(propNames{i},'FeedDiameter')
                            self.Model.feedDiameterChanged();
                        elseif strcmpi(propNames{i},'ViaDiameter')
                            self.Model.viaDiameterChanged();
                        end
                    end
                end

            else

                self.Model.VariablesManager.changeVariableName(evt.Name,evt.Data.NewData);
                varobj=getVarObj(self.Model.VariablesManager,evt.Data.NewData);
                callPropChangedOnAllDepObjects(self,varobj);
            end



            self.Model.notify('ModelChanged',cad.events.ModelChangedEventData(...
            'VariableChanged','Variable','exec',evt,getInfo(self.Model),''))

        end

        function undo(self)
            evt=self.ActionInfo;
            if evt.Data.Indices(2)==3
                [funchandle,depvars,opval]=self.Model.VariablesManager.parseExpression(evt.Data.PreviousData);
                varobj=self.Model.VariablesManager.getVarObj(evt.Name);
                depShapeObj=self.getDependentObj(varobj,1);
                self.setTriggerUpdate(depShapeObj,0);

                if isempty(depvars)
                    self.Model.VariablesManager.set(evt.Name,opval);
                else
                    self.Model.VariablesManager.set(evt.Name,funchandle);
                end

                layerobj=self.updateTree(depShapeObj);

                self.setTriggerUpdate(depShapeObj,1);

                [depObj,varPropObj,propNames]=self.getDependentObj(varobj);
                depObj=arrayfun(@(x)x,depObj,'UniformOutput',false);
                for i=1:numel(depObj)
                    self.Model.callPropertyChanged(depObj{i},getInfo(depObj{i}));
                end

                for i=1:numel(layerobj)
                    if~(isa(layerobj(i),'cad.Layer'))
                        continue;
                    end
                    self.Model.callPropertyChanged(layerobj(i),getInfo(layerobj(i)));
                end

                if~isempty(varPropObj)
                    propNames=unique(propNames);
                    for i=1:numel(propNames)
                        if strcmpi(propNames{i},'FeedDiameter')
                            self.Model.feedDiameterChanged();
                        elseif strcmpi(propNames{i},'ViaDiameter')
                            self.Model.viaDiameterChanged();
                        end
                    end
                end

            else

                self.Model.VariablesManager.changeVariableName(evt.Data.NewData,evt.Data.PreviousData)
                varobj=getVarObj(self.Model.VariablesManager,evt.Data.PreviousData);
                callPropChangedOnAllDepObjects(self,varobj);
            end

            self.Model.notify('ModelChanged',cad.events.ModelChangedEventData(...
            'VariableChanged','Variable','undo',evt,getInfo(self.Model),''))
        end

        function callPropChangedOnAllDepObjects(self,varObj)
            for i=1:numel(varObj.VariableMap)
                mapObj=varObj.VariableMap(i);
                if~isa(mapObj.DependentObject,'cad.Variable')
                    self.Model.callPropertyChanged(mapObj.DependentObject,getInfo(mapObj.DependentObject));
                end
            end
        end

        function[depObj,varPropObj,varPropNames]=getDependentObj(self,varObj,varargin)
            varPropNames={};
            varPropObj=[];
            depObj=[];
            checkShape=@(x)isa(x,'cad.Polygon');
            if isempty(varargin)
                onlyShape=0;
                condn=@(x)~isa(x,'cad.Variable');
            else
                onlyShape=1;
                condn=checkShape;
            end
            for i=1:numel(varObj.VariableMap)
                if condn(varObj.VariableMap(i).DependentObject)
                    if~isa(getFinalParent(self,varObj.VariableMap(i).DependentObject),...
                        'cad.Layer')&&checkShape(varObj.VariableMap(i).DependentObject)
                        continue;
                    end
                    if isa(varObj.VariableMap(i).DependentObject,'em.internal.pcbDesigner.VarProperties')
                        varPropObj=varObj.VariableMap(i).DependentObject;
                        varPropNames=[varPropNames;{varObj.VariableMap(i).PropertyName}];
                    else
                        if isempty(depObj)
                            depObj=varObj.VariableMap(i).DependentObject;
                        else
                            depObj=[depObj;varObj.VariableMap(i).DependentObject];
                        end
                    end
                elseif isa(varObj.VariableMap(i).DependentObject,'cad.Variable')
                    [depObjNew,varPropObjNew,varPropNamesNew]=getDependentObj(self,varObj.VariableMap(i).DependentObject,varargin{:});
                    depObj=[depObj;depObjNew];
                    if~isempty(varPropObjNew)
                        varPropObj=varPropObjNew;
                        varPropNames=[varPropNames;varPropNamesNew];
                    end
                end
            end
        end


        function shapeObj=getBottomLevelShapeObj(self,parent)
            shapeObj=[];
            childShapes=getChildrenShapes(parent);
            if isempty(childShapes)
                shapeObj=parent;
            else
                for i=1:numel(childShapes)
                    bottomLevelObj=getBottomLevelShapeObj(self,childShapes);
                    if isempty(shapeObj)
                        shapeObj=bottomLevelObj;
                    else
                        shapeObj=[shapeObj;bottomLevelObj];
                    end

                end
            end

            shapeObj=unique(shapeObj);
        end

        function parObj=getFinalParent(self,shape)
            obj=shape;
            while isprop(obj,'Parent')&&~isempty(obj.Parent)
                obj=obj.Parent;
            end
            parObj=obj;

        end

        function setTriggerUpdate(self,shapeobj,val)
            for i=1:numel(shapeobj)
                shapeobj(i).TriggerUpdate=val;
            end
        end

        function nodedepthstack=getNodeDepthStack(self,shapeobj)
            for i=1:numel(shapeobj)
                nodedepthstack(i)=shapeobj(i).getNodeDepth();
            end
        end

        function layerobj=updateTree(self,shapeobj)
            if isempty(shapeobj)
                layerobj=[];
                return;
            end
            nodeDepthStack=getNodeDepthStack(self,shapeobj);
            while~all(nodeDepthStack==1)

                maxdepth=max(nodeDepthStack);
                idx=nodeDepthStack==maxdepth;

                currShapeObj=shapeobj(idx);
                setTriggerUpdate(self,currShapeObj,0);
                for i=1:numel(currShapeObj)
                    currShapeObj(i).updateShape();
                end
                if maxdepth==2
                    newShapeObj=[currShapeObj.Parent];
                else
                    opnParent=[currShapeObj.Parent];
                    newShapeObj=[opnParent.Parent];
                end
                shapeobj(idx)=newShapeObj;
                shapeobj=unique(shapeobj);
                setTriggerUpdate(self,currShapeObj,1);

                nodeDepthStack=getNodeDepthStack(self,shapeobj);


            end
            layerobj=shapeobj;

            for i=1:numel(layerobj)
                if isa(layerobj(i),'cad.Layer')
                    layerobj(i).childUpdated(0);
                end
            end
        end
    end
end