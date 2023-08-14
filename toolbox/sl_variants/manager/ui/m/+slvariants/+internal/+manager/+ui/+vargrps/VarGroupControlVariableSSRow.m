classdef VarGroupControlVariableSSRow<handle




    properties


        CtrlVar;

        CtrlVarName;

        CtrlVarValues;
        ReferenceValue;

        VariableGroupSrc slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSSource;
        ActivationTime='';

        IsSLVarCtrl(1,1)logical=false;
        IsSimParam(1,1)logical=false;
        IsAUTOSARParam(1,1)logical=false;

        IsFullRange(1,1)logical=false;
        IsIgnored(1,1)logical=false;
    end

    methods(Hidden)

        function obj=VarGroupControlVariableSSRow(ctrlVarName,ctrlVar,varGrpSrc)
            if nargin==0
                return;
            end
            obj.IsSLVarCtrl=isa(ctrlVar,'Simulink.VariantControl');
            obj.CtrlVar=ctrlVar;
            ctrlVarValue=obj.CtrlVar;
            if obj.IsSLVarCtrl
                obj.ActivationTime=ctrlVar.ActivationTime;
                ctrlVarValue=ctrlVarValue.Value;
            end
            obj.IsSimParam=isa(ctrlVarValue,'Simulink.Parameter');
            obj.IsAUTOSARParam=isa(ctrlVarValue,'AUTOSAR.Parameter');
            if obj.IsSimParam||obj.IsAUTOSARParam
                if obj.IsSLVarCtrl
                    obj.CtrlVar=slvariants.internal.config.utils.deepCopyVariantControl(ctrlVarValue);
                else
                    obj.CtrlVar=copy(ctrlVarValue);
                end
            end
            obj.CtrlVarName=ctrlVarName;
            obj.VariableGroupSrc=varGrpSrc;
        end

        function flag=isValidProperty(~,propName)
            flag=ismember(propName,{slvariants.internal.manager.ui.config.VMgrConstants.Name...
            ,slvariants.internal.manager.ui.config.VMgrConstants.Values...
            ,slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue...
            ,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime});
        end

        function val=getPropValue(obj,propName)
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.Name
                val=obj.CtrlVarName;
            case slvariants.internal.manager.ui.config.VMgrConstants.Values
                val=obj.getCharValue();
            case slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime
                if obj.IsIgnored
                    val='';
                else
                    val=obj.ActivationTime;
                end
            case slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue
                if obj.IsIgnored
                    val='';
                else
                    val=obj.getReferenceValue();
                end
            otherwise
                val='';
            end
        end

        function flag=isEditableProperty(obj,propName)
            if strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime)
                flag=obj.IsSLVarCtrl;
            elseif strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue)
                flag=obj.IsFullRange;
            else
                flag=ismember(propName,{slvariants.internal.manager.ui.config.VMgrConstants.Values});
            end
        end

        function flag=isReadonlyProperty(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            flag=false;
            if strcmp(propName,VMgrConstants.ActivationTime)
                flag=~obj.IsSLVarCtrl;
            elseif strcmp(propName,VMgrConstants.ReferenceValue)
                flag=~obj.IsFullRange;
            elseif strcmp(propName,VMgrConstants.Name)
                flag=true;
            end
        end

        function type=getPropDataType(~,propName)
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime
                type='enum';
            otherwise
                type='string';
            end
        end

        function valueVec=getPropAllowedValues(obj,propName)
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime
                if obj.IsSLVarCtrl
                    valueVec={slvariants.internal.manager.ui.config.VMgrConstants.ActivationTimeUD...
                    ,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTimeUDAAC...
                    ,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTimeCC...
                    ,slvariants.internal.manager.ui.config.VMgrConstants.ActivationTimeStartup};
                else
                    valueVec={};
                end
            case slvariants.internal.manager.ui.config.VMgrConstants.Values
                modelHandle=get_param(obj.VariableGroupSrc.getModelName(),'Handle');
                activeTab=slvariants.internal.manager.ui.utils.getActiveTabInVM(modelHandle);
                if strcmp(activeTab,'variantAnalyzerTab')
                    valueVec={slvariants.internal.manager.ui.config.VMgrConstants.Ignored};
                else
                    valueVec={slvariants.internal.manager.ui.config.VMgrConstants.FullRange...
                    ,slvariants.internal.manager.ui.config.VMgrConstants.Ignored};
                end
            otherwise
                valueVec={};
            end
        end

        function setPropValue(obj,propName,val)
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.Values
                if isempty(val)


                    errId='Simulink:VariantManagerUI:VariantReducerCtrlvarValidationEmptyValues';
                    createErrorDialogForVarCtrlGroup(errId,obj.CtrlVarName);
                    return;
                end
                obj.setValidValue(val);
            case slvariants.internal.manager.ui.config.VMgrConstants.ReferenceValue
                if~obj.IsFullRange
                    return;
                end
                obj.setReferenceValue(val);
            case slvariants.internal.manager.ui.config.VMgrConstants.ActivationTime
                if~obj.IsSLVarCtrl
                    return;
                end
                obj.ActivationTime=val;
            end
        end

        function newObj=deepCopy(obj,newVarGrpSrc)
            newObj=slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSRow(obj.CtrlVarName,obj.CtrlVar,...
            newVarGrpSrc);
            newObj.CtrlVarValues=obj.CtrlVarValues;
            newObj.ReferenceValue=obj.ReferenceValue;
            newObj.IsFullRange=obj.IsFullRange;
            newObj.IsIgnored=obj.IsIgnored;
        end

        function iconFile=getDisplayIcon(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants

            if obj.IsSLVarCtrl
                if obj.IsSimParam||obj.IsAUTOSARParam
                    iconFile=VMgrConstants.SLVarCtrlParamTypeIcon;
                else
                    iconFile=VMgrConstants.SLVarCtrlNormalTypeIcon;
                end
            else
                if obj.IsSimParam||obj.IsAUTOSARParam
                    iconFile=VMgrConstants.ParamTypeIcon;
                else
                    iconFile=VMgrConstants.NormalTypeIcon;
                end
            end
        end

    end

    methods(Access=private)
        function out=getCharValue(obj)
            if obj.IsFullRange
                out=obj.getFullRangeEvalVal();
                return;
            end
            if obj.IsIgnored
                out=slvariants.internal.manager.ui.config.VMgrConstants.Ignored;
                return;
            end
            if~isempty(obj.CtrlVarValues)
                out=strcat('[',num2str(obj.CtrlVarValues),']');
            else
                out=slvariants.internal.manager.ui.utils.getCharValueForCtrlVar(obj.CtrlVar,obj.IsSLVarCtrl,obj.IsSimParam,obj.IsAUTOSARParam);
            end
        end

        function out=getReferenceValue(obj)
            out='';
            if~obj.IsFullRange
                return;
            end
            out=slvariants.internal.config.utils.iNum2Str(obj.ReferenceValue,true);
        end

        function setValidValue(obj,val)
            import slvariants.internal.manager.ui.config.findDDGByTagIdAndTag;
            if strcmp(val,slvariants.internal.manager.ui.config.VMgrConstants.Ignored)
                obj.IsIgnored=true;
                obj.IsFullRange=false;
                return;
            end
            obj.IsIgnored=false;
            if strcmp(val,slvariants.internal.manager.ui.config.VMgrConstants.FullRange)
                obj.IsFullRange=true;
                obj.IsIgnored=false;
                if~isempty(obj.CtrlVarValues)
                    obj.ReferenceValue=obj.CtrlVarValues;
                else
                    value=obj.CtrlVar;
                    if obj.IsSLVarCtrl
                        value=value.Value;
                    end
                    if obj.IsSimParam||obj.IsAUTOSARParam
                        value=value.Value;
                    end
                    obj.ReferenceValue=value;
                end

                dlg=findDDGByTagIdAndTag(obj.VariableGroupSrc.getModelName(),'varGrpsDDG');
                slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.callUpdateOnSpreadsheet(dlg,'varGrpSS');
                return;
            end
            try
                ctrlVar=str2num(val);%#ok<ST2NM>


                isValidValue=isValidCtrlValForVarGrp(ctrlVar);
                if~isValidValue


                    errId='Simulink:VariantManagerUI:VariantReducerCtrlvarValidationInvalidValuePrefix';
                    createErrorDialogForVarCtrlGroup(errId,val);
                    return;
                end

                if isscalar(ctrlVar)

                    if ctrlVar~=floor(ctrlVar)

                        errId='Simulink:VariantManagerUI:VariantReducerCtrlvarValidationInvalidValuePrefix';
                        createErrorDialogForVarCtrlGroup(errId,val);
                        return;
                    end
                    obj.CtrlVarValues=[];
                    if obj.IsSLVarCtrl
                        obj.setSlVarCtrlVal(ctrlVar);
                    elseif obj.IsSimParam||obj.IsAUTOSARParam
                        obj.setParamValue(ctrlVar);
                    else
                        obj.CtrlVar=ctrlVar;
                    end
                else
                    obj.CtrlVarValues=ctrlVar;
                    if obj.IsSLVarCtrl&&~(obj.IsSimParam||obj.IsAUTOSARParam)
                        obj.IsSLVarCtrl=false;
                        obj.ActivationTime='';
                    end
                    obj.CtrlVar=[];
                end
            catch
                errId='Simulink:VariantManagerUI:VariantReducerCtrlvarValidationInvalidValuePrefix';
                createErrorDialogForVarCtrlGroup(errId,val);
                return;
            end
            obj.IsFullRange=false;
            obj.IsIgnored=false;
        end

        function setReferenceValue(obj,val)
            try
                valToSet=str2num(val);%#ok<ST2NM>
                if isValidCtrlValForVarGrp(valToSet)
                    obj.ReferenceValue=valToSet;
                else
                    errId='Simulink:VariantManagerUI:VariantReducerCtrlvarValidationInvalidValuePrefix';
                    createErrorDialogForVarCtrlGroup(errId,val);
                end
            catch
                createErrorDialogForVarCtrlGroup('Simulink:VariantManagerUI:VariantReducerCtrlvarValidationEmptyRefvalues',val);
            end
        end

        function setParamValue(obj,ctrlval)


            obj.CtrlVar.Value=ctrlval;
        end

        function setSlVarCtrlVal(obj,ctrlval)
            if obj.IsSimParam||obj.IsAUTOSARParam


                obj.CtrlVar.Value.Value=ctrlval;
            else


                obj.CtrlVar.Value=ctrlval;
            end
        end

        function val=getFullRangeEvalVal(obj)


            modelname=obj.VariableGroupSrc.getModelName;
            activeTab=slvariants.internal.manager.ui.utils.getActiveTabInVM(get_param(modelname,'handle'));
            if strcmp(activeTab,'variantReducerTab')
                val=slvariants.internal.manager.ui.config.VMgrConstants.FullRange;
                return;
            end

            if isempty(obj.ReferenceValue)

                ctrlVal=0;
            else


                ctrlVal=obj.ReferenceValue;
            end
            val=slvariants.internal.config.utils.iNum2Str(ctrlVal,true);
        end
    end
end

function createErrorDialogForVarCtrlGroup(errId,val,varargin)
    dp=DAStudio.DialogProvider;
    errorMessage=DAStudio.message(errId,val);
    if nargin>2
        errorMessage=[errorMessage,'. ',DAStudio.message(varargin{:})];
    end
    dp.errordlg(errorMessage,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),true);
end

function isValid=isValidCtrlValForVarGrp(value)
    isValid=~isempty(value)&&((isnumeric(value)&&all(isfinite(value)))||...
    islogical(value));
end


