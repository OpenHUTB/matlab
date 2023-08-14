classdef ControlVariableRow<handle








    properties
        CtrlVarSSSrc(1,1)slvariants.internal.manager.ui.config.ControlVariableSource;

        CtrlVarName(1,:)char='';


        CtrlVarIdx(1,1)double=-1;

        DialogSchema(1,1)

        IsHighlighted=false;

        IsReadOnly=false;

        IsSimulinkParameter=false;

        Usage={};



        IsAUTOSARParameter=false;
        IsSLVarControl=false;

        IsCompoundType=false;
    end

    properties(Hidden)
        CtrlVarStructForGlobalWksConfig(1,1)struct=slvariants.internal.config.types.getControlVariableStruct();
    end

    methods(Access=private)
        function vals=getSourcePropAllowedValues(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants
            bdName=obj.DialogSchema.BDName;


            vals={VMgrConstants.BaseWorkspaceSource};
            if isempty(bdName)

                return;
            end
            vals=slvariants.internal.manager.core.getAllSourcesForModelHierarchy(bdName);
        end

        function isAllowed=isSlexprValAllowed(obj)
            ctrlVal=obj.getControlVariableValue;
            isAllowed=isa(ctrlVal,'Simulink.Parameter')||(isa(ctrlVal,'Simulink.VariantControl')...
            &&isa(ctrlVal.Value,'Simulink.Parameter'));
        end

        function toolTip=getToolTip(obj)

            if obj.IsSLVarControl
                if obj.IsAUTOSARParameter
                    toolTip=getString(message("Simulink:VariantManagerUI:SimulinkVariantControlASParamCtrlVarTT"));
                elseif obj.IsSimulinkParameter
                    toolTip=getString(message("Simulink:VariantManagerUI:SimulinkVariantControlParamCtrlVarTT"));
                else
                    toolTip=getString(message("Simulink:VariantManagerUI:SimulinkVariantControlNormalCtrlVarTT"));
                end
            else
                if obj.IsAUTOSARParameter
                    toolTip=getString(message("Simulink:VariantManagerUI:AUTOSARParamCtrlVarTT"));
                elseif obj.IsSimulinkParameter
                    toolTip=getString(message("Simulink:VariantManagerUI:SimulinkParamCtrlVarTT"));
                else
                    toolTip=getString(message("Simulink:VariantManagerUI:NormalCtrlVarTT"));
                end
            end
        end
    end

    methods(Hidden)

        function obj=ControlVariableRow(aCtrlVarSource,aCtrlVarName,ctrlVarIdx)
            if nargin==0
                return;
            end
            obj.CtrlVarSSSrc=aCtrlVarSource;
            obj.CtrlVarName=aCtrlVarName;
            obj.CtrlVarStructForGlobalWksConfig.Name=aCtrlVarName;
            obj.CtrlVarIdx=ctrlVarIdx;
            obj.DialogSchema=aCtrlVarSource.DialogSchema;
            obj.Usage{1}=aCtrlVarSource.DialogSchema.BDName;
            obj.computeTypeInfo();
        end

        function setControlVariableName(obj,val)
            import slvariants.internal.manager.ui.config.highlightVarCtrlUsageCallback

            if obj.IsHighlighted
                hideUsage=false;
                highlightVarCtrlUsageCallback(obj.DialogSchema.BDName,obj.CtrlVarIdx,hideUsage);
            end

            if obj.CtrlVarSSSrc.IsGlobalWksConfig
                obj.CtrlVarStructForGlobalWksConfig.Name=val;
            else


                obj.CtrlVarSSSrc.VariantConfigs.setControlVariableNameByPos(...
                obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarIdx,val);
            end
            if~obj.DialogSchema.IsStandalone
                dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(obj.DialogSchema.BDName);
                isDirty=true;
                obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.CtrlVarSSSrc.IsGlobalWksConfig,isDirty);
            end
            obj.IsHighlighted=0;
            obj.CtrlVarName=val;
        end

        function value=getControlVariableValue(obj)
            if obj.CtrlVarSSSrc.IsGlobalWksConfig
                value=obj.CtrlVarStructForGlobalWksConfig.Value;
            else
                value=obj.CtrlVarSSSrc.VariantConfigs.getControlVariableValueByPos(...
                obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarIdx);
            end
        end

        function setControlVariableValue(obj,val)
            if obj.CtrlVarSSSrc.IsGlobalWksConfig
                obj.CtrlVarStructForGlobalWksConfig.Value=val;
            else
                obj.CtrlVarSSSrc.VariantConfigs.setControlVariableValueByPos(obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarIdx,val);
            end
            if~obj.DialogSchema.IsStandalone
                dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(obj.DialogSchema.BDName);
                isDirty=true;
                obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.CtrlVarSSSrc.IsGlobalWksConfig,isDirty);
            end
            obj.computeTypeInfo();
        end

        function activationTime=getControlVariableActivationTime(obj)
            activationTime='';
            if~obj.IsSLVarControl
                return;
            end
            value=obj.getControlVariableValue();
            activationTime=value.ActivationTime;
        end

        function setControlVariableActivationTime(obj,activationTime)
            if~obj.IsSLVarControl
                return;
            end
            varCtrl=obj.getControlVariableValue();
            varCtrl.ActivationTime=activationTime;

            if obj.CtrlVarSSSrc.IsGlobalWksConfig
                obj.CtrlVarStructForGlobalWksConfig.Value=varCtrl;
            else
                obj.CtrlVarSSSrc.VariantConfigs.setControlVariableValue(...
                obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarName,varCtrl);
            end
            if~obj.DialogSchema.IsStandalone
                dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(obj.DialogSchema.BDName);
                isDirty=true;
                obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.CtrlVarSSSrc.IsGlobalWksConfig,isDirty);
            end
        end

        function value=getControlVariableSource(obj)
            if obj.CtrlVarSSSrc.IsGlobalWksConfig
                value=obj.CtrlVarStructForGlobalWksConfig.Source;
            else
                value=obj.CtrlVarSSSrc.VariantConfigs.getControlVariableSourceByPos(...
                obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarIdx);
            end
        end

        function setControlVariableSource(obj,val)
            if obj.CtrlVarSSSrc.IsGlobalWksConfig
                obj.CtrlVarStructForGlobalWksConfig.Source=val;
            else
                obj.CtrlVarSSSrc.VariantConfigs.setControlVariableSourceByPos(obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarIdx,val);
            end
            if~obj.DialogSchema.IsStandalone
                dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(obj.DialogSchema.BDName);
                isDirty=true;
                obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.CtrlVarSSSrc.IsGlobalWksConfig,isDirty);
            end
        end

        function getPropertyStyle(obj,propName,propertyStyle)
            import slvariants.internal.manager.ui.config.VMgrConstants

            if strcmp(propName,VMgrConstants.Name)

                getPropValue(obj,VMgrConstants.Value);
                propertyStyle.Tooltip=obj.getToolTip();
            end

            if strcmp(propName,VMgrConstants.ActivationTime)
                propertyStyle.Tooltip=getString(message('Simulink:VariantManagerUI:ControlVariablesVATTooltip'));
            end

            if obj.IsHighlighted
                propertyStyle.BackgroundColor=[1,250/255,205/255];
            elseif obj.isReadonlyProperty(propName)






                propertyStyle.BackgroundColor=[224/255,224/255,224/255];
            end

            if obj.IsReadOnly
                readOnlyTooltip=getString(message('Simulink:VariantManagerUI:CtrlVarReadOnlyFromComp'));
                if isempty(propertyStyle.Tooltip)
                    propertyStyle.Tooltip=readOnlyTooltip;
                else
                    propertyStyle.Tooltip=[propertyStyle.Tooltip...
                    ,newline,newline,readOnlyTooltip];
                end
            end

        end


        function iconFile=getDisplayIcon(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants

            if obj.IsSLVarControl
                if obj.IsSimulinkParameter||obj.IsAUTOSARParameter
                    iconFile=VMgrConstants.SLVarCtrlParamTypeIcon;
                else
                    iconFile=VMgrConstants.SLVarCtrlNormalTypeIcon;
                end
            else
                if obj.IsSimulinkParameter||obj.IsAUTOSARParameter
                    iconFile=VMgrConstants.ParamTypeIcon;
                else
                    iconFile=VMgrConstants.NormalTypeIcon;
                end
            end
        end

        function flag=isValidProperty(~,propName)

            import slvariants.internal.manager.ui.config.VMgrConstants
            flag=ismember(propName,{...
            VMgrConstants.Name...
            ,VMgrConstants.Value...
            ,VMgrConstants.ActivationTime...
            ,VMgrConstants.Source...
            });
        end

        function val=getPropValue(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants


            val='';
            if~obj.isValidProperty(propName)
                return;
            end
            switch(propName)
            case VMgrConstants.Value
                val=obj.getControlVariableValue();
                obj.computeTypeInfo();
                val=obj.getCharValue(val);
            case VMgrConstants.ActivationTime
                val=obj.getControlVariableActivationTime();
            case VMgrConstants.Name
                val=obj.CtrlVarName;
            case VMgrConstants.Source
                if obj.CtrlVarSSSrc.IsGlobalWksConfig
                    val=obj.CtrlVarStructForGlobalWksConfig.Source;
                else
                    val=obj.CtrlVarSSSrc.VariantConfigs.getControlVariableSourceByPos(obj.CtrlVarSSSrc.ConfigName,obj.CtrlVarIdx);
                end
            end
        end

        function flag=isEditableProperty(~,~)
            flag=true;
        end

        function flag=isReadonlyProperty(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

            if obj.CtrlVarSSSrc.DialogSchema.ReduceAnalyzeModeFlag~=ReduceAnalyzeModes.Unset
                flag=true;
                return;
            end


            if strcmp(propName,VMgrConstants.ActivationTime)


                flag=~obj.IsSLVarControl;
                return;
            end

            if strcmp(propName,VMgrConstants.Value)&&...
                obj.IsCompoundType
                flag=true;
                return;
            end

            flag=obj.IsReadOnly;
            if isempty(obj.DialogSchema.CompBrowserSSSrc)||...
                isempty(obj.DialogSchema.CompBrowserSSSrc.CurrentCompRow)
                return;
            end

            return;
        end

        function type=getPropDataType(~,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants
            type='string';
            if ismember(propName,{...
                VMgrConstants.ActivationTime...
                ,VMgrConstants.Source})
                type='enum';
            end
        end

        function valueVec=getPropAllowedValues(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants
            switch propName
            case VMgrConstants.ActivationTime
                valueVec={VMgrConstants.ActivationTimeUD...
                ,VMgrConstants.ActivationTimeUDAAC...
                ,VMgrConstants.ActivationTimeCC...
                ,VMgrConstants.ActivationTimeStartup};
            case VMgrConstants.Source
                valueVec=obj.getSourcePropAllowedValues();
            case VMgrConstants.Value
                valueVec=obj.getCtrlVarValueEnumValues();
            otherwise
                valueVec={};
            end
        end

        function valueVec=getCtrlVarValueEnumValues(obj)
            valueVec={};

            val=obj.getActValue(obj.getControlVariableValue());
            if~isenum(val)
                return;
            end
            enumClassName=class(val);

            [~,enumTypes]=enumeration(val);
            valueVec=cellfun(@(x)[enumClassName,'.',x],enumTypes,'UniformOutput',false);
        end

        function setPropValue(obj,propName,val)
            import slvariants.internal.manager.ui.config.VMgrConstants

            switch propName
            case VMgrConstants.Name
                obj.checkAndSetName(val);
            case VMgrConstants.Value
                obj.checkAndSetValue(val);
            case VMgrConstants.ActivationTime
                obj.checkAndSetActivationTime(val);
            case VMgrConstants.Source
                obj.checkAndSetSource(val);
            end
        end

        function checkAndSetName(obj,val)
            if isempty(val)
                slvariants.internal.manager.ui.util.createErrorDialog(...
                val,'Simulink:VariantManagerUI:MessageEmptyvarvalue');
                return;
            end
            if slvariants.internal.manager.ui.config.isValidCtrlVarName(obj,val)
                obj.setControlVariableName(val);
            else


                slvariants.internal.manager.ui.util.createErrorDialog(...
                val,'Simulink:VariantManagerUI:MessageInvalidvarname');
            end
        end

        function checkAndSetSource(obj,val)
            obj.setControlVariableSource(val);
        end

        function checkAndSetValue(obj,value)
            if isempty(value)
                slvariants.internal.manager.ui.util.createErrorDialog(...
                value,'Simulink:VariantManagerUI:MessageEmptyvarvalue');
                return;
            end



            value=strtrim(value);

            if isSlexprValAllowed(obj)&&value(1)=='='
                evalVal=slexpr(value(2:end));
            else
                evalVal=str2num(value);%#ok<ST2NM>
            end

            if isempty(evalVal)
                if isSlexprValAllowed(obj)
                    slvariants.internal.manager.ui.util.createErrorDialog(...
                    value,'Simulink:VariantManagerUI:MessageInvalidparamvarvalue');
                else
                    slvariants.internal.manager.ui.util.createErrorDialog(...
                    value,'Simulink:VariantManagerUI:MessageInvalidvarvalue');
                end
                return;
            end

            try


                ctrlVarValue=Simulink.variant.utils.deepCopy(obj.getControlVariableValue(),'ErrorForNonCopyableHandles',false);

                if isa(ctrlVarValue,'Simulink.VariantControl')
                    if isa(ctrlVarValue.Value,'Simulink.Parameter')
                        ctrlVarValue.Value.Value=evalVal;
                    else
                        ctrlVarValue.Value=evalVal;
                    end
                else
                    if isa(ctrlVarValue,'Simulink.Parameter')
                        ctrlVarValue.Value=evalVal;
                    else
                        ctrlVarValue=evalVal;
                    end
                end
                obj.setControlVariableValue(ctrlVarValue);

            catch ex %#ok<NASGU>
                slvariants.internal.manager.ui.util.createErrorDialog(...
                value,'Simulink:VariantManagerUI:MessageInvalidvarvalue');
                return;
            end
        end

        function checkAndSetActivationTime(obj,activationTime)
            if isempty(activationTime)
                slvariants.internal.manager.ui.util.createErrorDialog(...
                activationTime,'Simulink:VariantManagerUI:MessageEmptyActivationTime');
                return;
            end
            try


                obj.setControlVariableActivationTime(activationTime);
            catch
                slvariants.internal.manager.ui.util.createErrorDialog(...
                activationTime,'Simulink:VariantManagerUI:MessageInvalidVarActivationTime');
            end
        end

        function outVal=getActValue(obj,inVal)



            outVal=inVal;
            if obj.IsSLVarControl
                outVal=outVal.Value;
            end
            if obj.IsSimulinkParameter||obj.IsAUTOSARParameter
                outVal=outVal.Value;
            end

        end

        function outVal=getCharValue(obj,inVal)
            outVal=obj.getActValue(inVal);
            outVal=slvariants.internal.config.utils.iNum2Str(outVal,true);
        end



        function convertToSimulinkParameter(obj)
            varCtrlValue=obj.getControlVariableValue();
            if obj.IsSLVarControl
                if obj.IsAUTOSARParameter
                    varCtrlValue.Value=Simulink.Parameter(varCtrlValue.Value.Value);
                else
                    varCtrlValue.Value=Simulink.Parameter(varCtrlValue.Value);
                end
            else
                if obj.IsAUTOSARParameter
                    varCtrlValue=Simulink.Parameter(varCtrlValue.Value);
                else
                    varCtrlValue=Simulink.Parameter(varCtrlValue);
                end
            end
            obj.setControlVariableValue(varCtrlValue);
        end

        function convertToAUTOSARParameter(obj)
            varCtrlValue=obj.getControlVariableValue();
            if obj.IsSLVarControl
                if obj.IsSimulinkParameter
                    varCtrlValue.Value=AUTOSAR.Parameter(varCtrlValue.Value.Value);
                else
                    varCtrlValue.Value=AUTOSAR.Parameter(varCtrlValue.Value);
                end
            else
                if obj.IsSimulinkParameter
                    varCtrlValue=AUTOSAR.Parameter(varCtrlValue.Value);
                else
                    varCtrlValue=AUTOSAR.Parameter(varCtrlValue);
                end
            end
            obj.setControlVariableValue(varCtrlValue);
        end

        function convertFromSimulinkParameter(obj)
            varCtrlValue=obj.getControlVariableValue();
            if obj.IsSLVarControl
                varCtrlValue.Value=slvariants.internal.manager.ui.config.getValueToSetForCtrlVar(obj.DialogSchema.BDName,varCtrlValue.Value);
            else
                varCtrlValue=slvariants.internal.manager.ui.config.getValueToSetForCtrlVar(obj.DialogSchema.BDName,varCtrlValue);
            end
            obj.setControlVariableValue(varCtrlValue);
        end



        function convertToSlVarCtrl(obj)
            varCtrlValue=obj.getControlVariableValue();
            obj.setControlVariableValue(Simulink.VariantControl(Value=varCtrlValue));
        end


        function convertFromSlVarCtrl(obj)
            varCtrlValue=obj.getControlVariableValue();
            obj.setControlVariableValue(varCtrlValue.Value);
        end
    end

    methods(Access=private)
        function computeTypeInfo(obj)
            val=obj.getControlVariableValue();
            obj.IsSLVarControl=isa(val,'Simulink.VariantControl');
            if obj.IsSLVarControl
                val=val.Value;
            end
            obj.IsSimulinkParameter=isa(val,'Simulink.Parameter');
            obj.IsAUTOSARParameter=isa(val,'AUTOSAR.Parameter');
            obj.IsCompoundType=slvariants.internal.config.utils.isCompoundCtrlVarType(val);
        end
    end

end



