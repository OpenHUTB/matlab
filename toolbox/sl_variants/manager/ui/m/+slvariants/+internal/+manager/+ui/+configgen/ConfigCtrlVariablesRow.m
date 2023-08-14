classdef(Sealed)ConfigCtrlVariablesRow<handle





    properties(Access=private)




        CtrlVariableInfo;
    end

    methods
        function obj=ConfigCtrlVariablesRow(ctrlVariableInfo)
            if nargin==0
                return;
            end

            obj.CtrlVariableInfo=ctrlVariableInfo;
        end

        function ctrlVarInfo=getControlVariableInfo(obj)
            ctrlVarInfo=obj.CtrlVariableInfo;
        end

        function propValue=getPropValue(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            switch propName
            case VMgrConstants.Name
                propValue=obj.CtrlVariableInfo.Name;
            case VMgrConstants.AutoGenConfigDataType
                propValue=obj.CtrlVariableInfo.DataType;
            case VMgrConstants.AutoGenConfigValues
                propValue=obj.CtrlVariableInfo.ValuesStr;
            otherwise
                propValue='Unknown';
            end
        end

        function setPropValue(obj,propName,val)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            switch propName
            case VMgrConstants.AutoGenConfigValues
                if isempty(val)
                    return;
                end
                obj.CtrlVariableInfo.ValuesStr=val;
            end

        end


        function flag=isValidProperty(~,propName)

            import slvariants.internal.manager.ui.config.VMgrConstants;
            flag=ismember(propName,{VMgrConstants.Name...
            ,VMgrConstants.AutoGenConfigDataType...
            ,VMgrConstants.AutoGenConfigValues});
        end

        function flag=isEditableProperty(~,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            flag=isequal(propName,VMgrConstants.AutoGenConfigValues);
        end

        function flag=isReadonlyProperty(~,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            flag=~isequal(propName,VMgrConstants.AutoGenConfigValues);
        end
    end
end
