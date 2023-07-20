classdef VariantConfigurationRow<handle






    properties
        VarConfigName(1,:)char;

        VarConfigIdx(1,1)double=-1;

        VarConfigSSSrc(1,1)


        CtrlVarSSSrc(1,1)slvariants.internal.manager.ui.config.ControlVariableSource;


        IsSelected(1,1)logical=false;


        IsCompBrowserVisibleForConfig(1,1)logical=false;
    end

    methods(Hidden)

        function obj=VariantConfigurationRow(aVConfigSSSrc,aVConfigName,configIndex,aCtrlVarSSSrc)
            if nargin==0
                return;
            end
            obj.VarConfigName=aVConfigName;
            obj.VarConfigIdx=configIndex;
            obj.VarConfigSSSrc=aVConfigSSSrc;
            if nargin<=3
                return;
            end
            obj.CtrlVarSSSrc=aCtrlVarSSSrc;
        end

        function status=isGlobalWksConfig(obj)
            status=obj.VarConfigIdx==0;
        end

        function propType=getPropDataType(obj,propName)
            propType='string';
            if~strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.SelectCol)
                return;
            end
            nConfigs=numel(obj.VarConfigSSSrc.getConfigurationNames());
            if obj.VarConfigIdx<=nConfigs&&obj.VarConfigIdx>0
                propType='bool';
            end
        end

        function getPropertyStyle(obj,~,propertyStyle)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            import slvariants.internal.manager.ui.config.VariantConfigurationRow;

            if obj.VarConfigIdx==0
                propertyStyle.Italic=true;
                propertyStyle.Tooltip=getString(message('Simulink:VariantManagerUI:GlobalWorkspaceConfigTooltip'));





            end

            propertyStyle.Bold=obj.CtrlVarSSSrc.DialogSchema.getIsActivatedConfig(...
            obj.getPropValue(slvariants.internal.manager.ui.config.VMgrConstants.Name));
        end

        function flag=isEditableProperty(obj,propName)
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;


            if obj.CtrlVarSSSrc.DialogSchema.ReduceAnalyzeModeFlag~=ReduceAnalyzeModes.Unset
                flag=false;
                return;
            end

            flag=obj.VarConfigIdx~=0&&obj.isValidProperty(propName);
        end

        function flag=isValidProperty(~,propName)

            flag=ismember(propName,{...
            slvariants.internal.manager.ui.config.VMgrConstants.Name...
            ,slvariants.internal.manager.ui.config.VMgrConstants.SelectCol});
        end

        function val=getPropValue(obj,propName)


            val='';
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.Name
                val=obj.VarConfigName;
            case slvariants.internal.manager.ui.config.VMgrConstants.SelectCol
                nConfigs=numel(obj.VarConfigSSSrc.getConfigurationNames());
                if obj.VarConfigIdx<=nConfigs&&obj.VarConfigIdx>0
                    val=num2str(obj.IsSelected);
                end
            end
        end

        function setPropValue(obj,propName,value)



            if~obj.isValidProperty(propName)
                return;
            end

            if strcmp(slvariants.internal.manager.ui.config.VMgrConstants.SelectCol,propName)
                obj.IsSelected=str2double(value);

                slvariants.internal.manager.ui.callRefresherForReduceAnalyseBtn(obj.VarConfigSSSrc.DialogSchema.BDName);
                return;
            end

            if isempty(value)
                slvariants.internal.manager.ui.util.createErrorDialog(value,'Simulink:VariantManagerUI:MessageEmptyconfigname');
                return;
            end
            if slvariants.internal.manager.ui.config.isValidConfigName(obj,value)


                obj.VarConfigSSSrc.VariantConfigs.setConfigurationName(obj.VarConfigName,value);
                varConfigOldName=obj.VarConfigName;
                obj.VarConfigName=value;
                obj.CtrlVarSSSrc.ConfigName=value;
                obj.VarConfigSSSrc.DialogSchema.setSourceObjDirtyFlag(obj.VarConfigSSSrc.DialogSchema);


                slvariants.internal.manager.ui.renameConfigLabel(obj.VarConfigSSSrc.DialogSchema,value);

                prefConfigName=obj.VarConfigSSSrc.VariantConfigs.getPreferredConfiguration();
                if strcmp(varConfigOldName,prefConfigName)&&~strcmp(varConfigOldName,value)
                    obj.VariantConfigs.setPreferredConfiguration('');
                end
            else
                slvariants.internal.manager.ui.util.createErrorDialog(value,'Simulink:VariantManagerUI:MessageInvalidconfigname');
            end
        end

        function flag=isReadonlyProperty(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            flag=false;
            if strcmp(propName,VMgrConstants.Name)&&...
                obj.CtrlVarSSSrc.DialogSchema.ReduceAnalyzeModeFlag~=ReduceAnalyzeModes.Unset
                flag=true;
            end
        end
    end

    methods(Static,Hidden)

        function openGlobalWSCB(dlg,obj,propertyName)%#ok<INUSD>
            import slvariants.internal.manager.ui.config.VMgrConstants;
            globalWS=obj{1}.VarConfigName;
            if strcmp(globalWS,VMgrConstants.BaseWorkspaceTitle)
                daexplr;
            else
                open(globalWS);
            end
        end
    end

end


