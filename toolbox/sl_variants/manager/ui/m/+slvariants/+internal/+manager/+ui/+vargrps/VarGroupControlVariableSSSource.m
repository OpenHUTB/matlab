classdef VarGroupControlVariableSSSource<handle




    properties
        Children(1,:)slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSRow;

        VariableGroupNameRow slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;
    end

    methods(Hidden)

        function obj=VarGroupControlVariableSSSource(nameRow)
            if nargin==0
                return;
            end
            obj.VariableGroupNameRow=nameRow;
        end

        function children=getChildren(obj,~)
            children=obj.Children;
            if~isempty(children)
                return;
            end
            ctrlVars=slvariants.internal.manager.core.findVariantControlVars(obj.VariableGroupNameRow.getModelName());

            [~,idx]=unique({ctrlVars.Name});
            ctrlVars=struct(ctrlVars(idx));

            nCtrlVars=numel(ctrlVars);
            if nCtrlVars==0
                return;
            end
            children(1,nCtrlVars)=slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSRow();
            for ctrlVarIdx=1:nCtrlVars
                children(ctrlVarIdx)=slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSRow(...
                ctrlVars(ctrlVarIdx).Name,ctrlVars(ctrlVarIdx).Value,obj);
            end
            obj.Children=children;
        end

        function newObj=deepCopy(obj,newNameRow)
            newObj=slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSSource(newNameRow);
            numChildren=length(obj.Children);
            newObj.Children(numChildren)=slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSRow;
            for i=1:numChildren
                newObj.Children(i)=obj.Children(i).deepCopy(newObj);
            end
        end

        function mdlName=getModelName(obj)
            mdlName=obj.VariableGroupNameRow.getModelName();
        end

        function groupName=getGroupName(obj)
            groupName=slvariants.internal.manager.ui.config.VMgrConstants.DefaultGroupName;
            if isempty(obj.VariableGroupNameRow)
                return;
            end
            groupName=obj.VariableGroupNameRow.GroupName;
        end
    end

end
