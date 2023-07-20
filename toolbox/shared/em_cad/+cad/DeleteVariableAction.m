classdef DeleteVariableAction<cad.Actions
    methods

        function self=DeleteVariableAction(Model,evt)
            self.Type="DeleteVariable";
            self.Model=Model;
            self.ActionInfo.Data.Name=evt.Name;
            self.ActionInfo.VarInfo=[];
            self.ActionInfo.VarNames=self.Model.VariablesManager.getVarNames();
        end

        function execute(self)
            evt=self.ActionInfo.Data;
            names=evt.Name;
            VarInfo=[];
            for i=1:numel(names)
                varObj=self.Model.VariablesManager.getVarObj(names{i});
                VarInfo=[VarInfo;generateVarInfo(self,varObj,1)];
                info=VarInfo(i);
                for j=1:numel(info.VarMapInfo)
                    depObjInfo=info.VarMapInfo(j);
                    if strcmpi(depObjInfo.DependentObject.CategoryType,'Variable')
                        depObj=self.Model.VariablesManager.getVarObj(depObjInfo.DependentObject.Name);
                        isvariable=1;
                    else
                        isvariable=0;
                        if strcmpi(depObjInfo.PropertyName,'FeedDiameter')||strcmpi(depObjInfo.PropertyName,'ViaDiameter')
                            depObj=self.Model.VarProperties;
                        else
                            depObj=getObject(self.Model,depObjInfo.DependentObject.CategoryType,depObjInfo.DependentObject.Id);
                        end
                    end

                    if isvariable
                        if numel(depObj.DependentMap)==1
                            val=depObj.getValue();
                            self.Model.VariablesManager.set(depObj.Name,val);
                        else
                            exprsnString=depObj.getExpressionWithoutInputs(depObj.Value);

                            value=getValue(varObj);
                            if isnumeric(value)
                                if isscalar(value)
                                    value=num2str(value);
                                else
                                    value=mat2str(value);
                                end
                            end

                            exprsnString=regexprep(exprsnString,['\<',varObj.Name,'\>'],value);
                            [fcnhandle,~,~]=self.Model.VariablesManager.parseExpression(exprsnString);
                            self.Model.VariablesManager.set(depObj.Name,fcnhandle);

                        end
                    else
                        depMap=depObj.DependentMap;
                        propnames={depMap.PropertyName};
                        idx=strcmpi(propnames,depObjInfo.PropertyName);
                        depMap=depMap(idx);
                        value=getValue(varObj);
                        if isnumeric(value)
                            if isscalar(value)
                                value=num2str(value);
                            else
                                value=mat2str(value);
                            end
                        end

                        if numel(depMap)==1
                            self.Model.VariablesManager.setValueToObject(depObj,...
                            depObjInfo.PropertyName,depObj.getValueOfProperty(...
                            depObjInfo.PropertyName,getValue(varObj),varObj.Name));
                        else
                            propFcnHandle=depObj.PropertyValueMap.(depObjInfo.PropertyName);
                            exprsnString=getExpressionWithoutInputs(depObj,propFcnHandle);
                            exprsnString=regexprep(exprsnString,['\<',varObj.Name,'\>'],value);
                            [fcnhandle,~,~]=self.Model.VariablesManager.parseExpression(exprsnString);
                            self.Model.VariablesManager.setValueToObject(...
                            depObj,depObjInfo.PropertyName,fcnhandle);
                        end
                        self.Model.callPropertyChanged(depObj,depObjInfo.DependentObject);
                    end
                end

                self.Model.VariablesManager.removeVariable(names{i});

            end
            self.ActionInfo.VarInfo=VarInfo;
        end

        function undo(self)
            evt=self.ActionInfo.Data;
            names=evt.Name;
            for i=numel(names):-1:1
                info=self.ActionInfo.VarInfo(i);
                self.Model.VariablesManager.addVariable(names{i},info.Value);
            end
            for i=numel(names):-1:1
                info=self.ActionInfo.VarInfo(i);
                for j=1:numel(info.VarMapInfo)
                    depObjInfo=info.VarMapInfo(j);
                    if strcmpi(depObjInfo.DependentObject.CategoryType,'Variable')
                        depObj=self.Model.VariablesManager.getVarObj(depObjInfo.DependentObject.Name);
                        isvariable=1;
                    else
                        isvariable=0;
                        if strcmpi(depObjInfo.PropertyName,'FeedDiameter')||strcmpi(depObjInfo.PropertyName,'ViaDiameter')
                            depObj=self.Model.VarProperties;
                        else
                            depObj=getObject(self.Model,depObjInfo.DependentObject.CategoryType,depObjInfo.DependentObject.Id);
                        end
                    end

                    if isvariable
                        self.Model.VariablesManager.set(depObj.Name,depObjInfo.DependentObject.Value);
                    else
                        self.Model.VariablesManager.setValueToObject(depObj,...
                        depObjInfo.PropertyName,depObjInfo.DependentObject.PropertyValueMap.(depObjInfo.PropertyName));
                        self.Model.callPropertyChanged(depObj,depObjInfo.DependentObject);
                    end
                end

            end

            newvarNames=self.Model.VariablesManager.getVarNames();
            oldvarNames=self.ActionInfo.VarNames;

            [~,idx1]=sort(newvarNames);
            [~,idx2]=sort(oldvarNames);
            [~,newidx]=sort(idx2);

            vars=self.Model.VariablesManager.Variables;
            vars=vars(idx1);
            vars=vars(newidx);

            self.Model.VariablesManager.Variables=vars;
        end


        function shapeObj=getDependentShapeObj(self,varObj)
            shapeObj=[];
            for i=1:numel(varObj.VariableMap)
                if isa(varObj.VariableMap(i).DependentObject,'cad.Polygon')
                    if~isa(getFinalParent(self,varObj.VariableMap(i).DependentObject),...
                        'cad.Layer')
                        continue;
                    end
                    if isempty(shapeObj)
                        shapeObj=varObj.VariableMap(i).DependentObject;
                    else
                        shapeObj=[shapeObj;varObj.VariableMap(i).DependentObject];
                    end
                elseif isa(varObj.VariableMap(i).DependentObject,'cad.Variable')
                    shapeObj=[shapeObj;getDependentShapeObj(self,varObj.VariableMap(i).DependentObject)];
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
            while~isempty(obj.Parent)
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
        end

        function info=generateVarInfo(self,var,traverseTree)
            info.Name=var.Name;
            info.Value=var.Value;
            VarMapInfo=[];
            if traverseTree
                for i=1:numel(var.VariableMap)
                    VarMapInfo=[VarMapInfo;genVarMapInfo(self,var.VariableMap(i))];
                end
            end
            info.VarMapInfo=VarMapInfo;
            info.CategoryType='Variable';

        end

        function info=genVarMapInfo(self,varmap)
            info.Variable=varmap.Variable.Name;
            if isa(varmap.DependentObject,'cad.Variable')
                info.DependentObject=generateVarInfo(self,varmap.DependentObject,0);
            else
                info.DependentObject=getInfo(varmap.DependentObject);
            end
            info.PropertyName=varmap.PropertyName;
        end
    end




end