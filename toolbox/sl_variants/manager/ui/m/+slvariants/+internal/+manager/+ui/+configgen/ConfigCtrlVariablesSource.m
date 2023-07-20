classdef(Sealed)ConfigCtrlVariablesSource<handle





    properties(Access=private)

        ConfigCtrlVarsInfoInitial;

        ConfigCtrlVarsInfo;

        ConfigCtrlVarRows(1,:)slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesRow;

        SelectedCtrlVarName(1,:)char;

        ModelName(1,:)char;
    end

    methods
        function obj=ConfigCtrlVariablesSource(configCtrlVarsInfo,modelName)
            obj.ConfigCtrlVarsInfoInitial=configCtrlVarsInfo;
            obj.ConfigCtrlVarsInfo=configCtrlVarsInfo;
            obj.ModelName=modelName;

            slvariants.internal.manager.ui.configgen.refreshToolStripActions(modelName);
        end

        function delete(obj)
            obj.ConfigCtrlVarRows.delete();
        end

        function ctrlVarsData=getControlVarsInfoInitial(obj)
            ctrlVarsData=obj.ConfigCtrlVarsInfoInitial;
        end

        function ctrlVarsData=getControlVarsInfo(obj)
            ctrlVarsData=obj.ConfigCtrlVarsInfo;
        end

        function varName=getSelectedCtrlVarName(obj)
            varName=obj.SelectedCtrlVarName;
        end

        function setSelectedCtrlVarName(obj,varName)
            obj.SelectedCtrlVarName=varName;
        end

        function children=getChildren(obj,~)
            numOfCtrlVars=numel(obj.ConfigCtrlVarsInfo);
            if isempty(obj.ConfigCtrlVarRows)&&numOfCtrlVars>0
                obj.ConfigCtrlVarRows(1,numOfCtrlVars)=slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesRow;
                for idx=1:numOfCtrlVars
                    obj.ConfigCtrlVarRows(idx)=slvariants.internal.manager.ui.configgen.ConfigCtrlVariablesRow(obj.ConfigCtrlVarsInfo(idx));
                end
            end
            children=obj.ConfigCtrlVarRows;
        end

        function moveControlVariableUp(obj,ctrlVarName)
            varIdx=obj.getCtrlVarIdx(ctrlVarName);

            if varIdx>1
                obj.ConfigCtrlVarsInfo([varIdx-1,varIdx])=obj.ConfigCtrlVarsInfo([varIdx,varIdx-1]);
                obj.ConfigCtrlVarRows([varIdx-1,varIdx])=obj.ConfigCtrlVarRows([varIdx,varIdx-1]);
            end
        end

        function moveControlVariableDown(obj,ctrlVarName)
            varIdx=obj.getCtrlVarIdx(ctrlVarName);

            if varIdx>0&&varIdx<numel(obj.ConfigCtrlVarsInfo)
                obj.ConfigCtrlVarsInfo([varIdx,varIdx+1])=obj.ConfigCtrlVarsInfo([varIdx+1,varIdx]);
                obj.ConfigCtrlVarRows([varIdx,varIdx+1])=obj.ConfigCtrlVarRows([varIdx+1,varIdx]);
            end
        end

        function enable=canGenerateButtonEnabled(obj)

            childRows=obj.getChildren();
            enable=(numel(childRows)>0);
        end
    end

    methods(Access=private)

        function varIdx=getCtrlVarIdx(obj,ctrlVarName)
            varIdx=-1;
            for idx=1:numel(obj.ConfigCtrlVarsInfo)
                if isequal(ctrlVarName,obj.ConfigCtrlVarsInfo(idx).Name)
                    varIdx=idx;
                    break;
                end
            end
        end
    end
end
