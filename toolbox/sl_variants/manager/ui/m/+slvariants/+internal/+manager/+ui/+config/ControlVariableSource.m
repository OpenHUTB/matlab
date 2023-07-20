classdef ControlVariableSource<handle






    properties
        VariantConfigs(1,1)Simulink.VariantConfigurationData;

        ConfigName(1,:)char='';

        Children(1,:)slvariants.internal.manager.ui.config.ControlVariableRow;




        DialogSchema(1,1)

        IsShowAllCtrlVarsOn(1,1)logical=true;

        IsGlobalWksConfig(1,1)logical=false;

        IsEnabled(1,1)logical=true;
    end

    methods(Hidden)

        function obj=ControlVariableSource(aVConfigs,aVConfigName,dialogSchema,isGlobalWksConfig,isEnabled)
            if nargin==0
                return;
            end

            obj.VariantConfigs=aVConfigs;
            obj.ConfigName=aVConfigName;
            obj.DialogSchema=dialogSchema;

            if nargin<=3
                return;
            end
            obj.IsGlobalWksConfig=isGlobalWksConfig;

            if nargin<=4
                return;
            end
            obj.IsEnabled=isEnabled;
        end

        function children=getChildren(obj,~)


            import slvariants.internal.manager.ui.config.ControlVariableRow
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

            children=ControlVariableRow.empty();
            if~obj.IsEnabled
                return;
            end

            if~isempty(obj.Children)
                children=obj.Children;
                if~obj.IsShowAllCtrlVarsOn&&obj.DialogSchema.IsCompBrowserVisible
                    children=getChildrenSubset(obj,children);
                end
                return;
            end


            ctrlVarNames=obj.VariantConfigs.getControlVariableNames(obj.ConfigName);
            nCtrlVars=numel(ctrlVarNames);
            if nCtrlVars==0
                return;
            end

            configIdx=find(strcmp({obj.VariantConfigs.Configurations.Name},obj.ConfigName));
            configObj=obj.VariantConfigs.Configurations(configIdx);

            ctrlVars=[];
            if~isempty(configObj)
                ctrlVars=configObj.ControlVariables;
            end
            hasSourceSpecified=isempty(ctrlVars)||isfield(ctrlVars,'Source');
            for idx=1:nCtrlVars


                if~hasSourceSpecified||...
                    isempty(obj.VariantConfigs.Configurations(configIdx).ControlVariables(idx).Source)
                    obj.VariantConfigs.setControlVariableSource(...
                    obj.VariantConfigs.Configurations(configIdx).Name,...
                    obj.VariantConfigs.Configurations(configIdx).ControlVariables(idx).Name,...
                    getDefaultSource(obj.DialogSchema.BDName));
                end
            end
            children(1,nCtrlVars)=ControlVariableRow();
            for idx=1:nCtrlVars
                children(idx)=ControlVariableRow(obj,ctrlVarNames{idx},idx);
            end

            obj.setReadOnlyStatus(children,obj.VariantConfigs.VariantConfigurations(configIdx).SubModelConfigurations);
            obj.Children=children;

            if~obj.IsShowAllCtrlVarsOn&&obj.DialogSchema.IsCompBrowserVisible
                children=getChildrenSubset(obj,children);
            end
        end

        function setReadOnlyStatus(~,children,subModelConfigurations)

            subModelCtrlVarsName=[];
            for subModelConfig=subModelConfigurations
                if isempty(subModelConfig.ModelName)||~exist(subModelConfig.ModelName,'file')
                    continue
                end
                load_system(subModelConfig.ModelName);
                subModelVcd=Simulink.variant.utils.getConfigurationDataNoThrow(subModelConfig.ModelName);
                if isempty(subModelVcd)
                    continue;
                end
                subModelSelectedConfigIdx=find(strcmp({subModelVcd.Configurations.Name},subModelConfig.ConfigurationName));
                selectedSubModelCtrlVars=subModelVcd.Configurations(subModelSelectedConfigIdx).ControlVariables;
                subModelCtrlVarsName=[{selectedSubModelCtrlVars.Name},subModelCtrlVarsName];%#ok
            end

            [~,idxChildren,~]=intersect({children.CtrlVarName},subModelCtrlVarsName,'stable');
            for idx=idxChildren'

                children(idx).IsReadOnly=true;
            end
        end

        function ctrlVarNames=getControlVariableNames(obj)
            if obj.IsGlobalWksConfig
                ctrlVarNames={obj.Children.CtrlVarName};
            else
                ctrlVarNames=obj.VariantConfigs.getControlVariableNames(obj.ConfigName);
            end
        end

        function ctrlVarNames=getControlVariableFullNames(obj)
            numCtrlVars=numel(obj.Children);
            ctrlVarNames=cell(1,numCtrlVars);
            for i=1:numCtrlVars
                ctrlVarNames{1,i}=[obj.Children(i).CtrlVarName,'/',obj.Children(i).getControlVariableSource()];
            end
        end

        function ctrlVarStruct=getControlVarStruct(obj)
            numCtrlVars=numel(obj.Children);
            ctrlVarNames=cell(1,numCtrlVars);
            ctrlVarValues=cell(1,numCtrlVars);
            ctrlVarSources=cell(1,numCtrlVars);
            for i=1:numCtrlVars
                ctrlVarNames{1,i}=obj.Children(i).CtrlVarName;
                ctrlVarValues{1,i}=obj.Children(i).getControlVariableValue();
                ctrlVarSources{1,i}=obj.Children(i).getControlVariableSource();
            end
            ctrlVarStruct=struct('Name',ctrlVarNames,'Value',ctrlVarValues,'Source',ctrlVarSources);
        end

        function ctrlVar=getNewCtrlVarCtxBased(obj,varargin)
            if numel(varargin)>=1
                newValue=varargin{1};
            else
                newValue=0;
            end

            ctrlVarObjects=obj.Children;
            if(numel(ctrlVarObjects)==0)||any([ctrlVarObjects(:).IsSLVarControl])



                ctrlVar=Simulink.VariantControl(Value=newValue);
            else
                ctrlVar=newValue;
            end
        end

        function removeControlVariable(obj,ctrlVarSSRow,dlg)
            ctrlVarIdx=ctrlVarSSRow.CtrlVarIdx;
            if~obj.IsGlobalWksConfig
                obj.VariantConfigs.removeControlVariableByPos(obj.ConfigName,ctrlVarIdx);
            end

            isDirty=true;
            obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.IsGlobalWksConfig,isDirty);

            obj.Children(ctrlVarIdx)=[];

            obj.updateIndicesForRowsBelow(ctrlVarIdx-1,-1);

            if~isempty(obj.DialogSchema.CompBrowserSSSrc)
                obj.DialogSchema.removeCompSpecificCtrlVarIndex(obj.DialogSchema.CompBrowserSSSrc.Children,ctrlVarIdx);
            end

            ssComp=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
            ctrlVarIdxToSel=min(obj.DialogSchema.SelectedCtrlVarIdx,numel(obj.Children));
            if ctrlVarIdxToSel>0

                obj.DialogSchema.updateSelectedCtrlVarIdx(ctrlVarIdxToSel);
                ssComp.select(obj.Children(ctrlVarIdxToSel));
            end

            isDirty=true;
            if numel(obj.Children)==0


                isDirty=false;
                dlg.setEnabled('showUsageVariantControlVarButtonTag',false);
                dlg.setEnabled('hideUsageVariantControlVarButtonTag',false);
                dlg.setEnabled('convertTypesSplitButtonTag',false);
                dlg.setEnabled('simulinkParameterEditButtonTag',false);
            end
            obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.IsGlobalWksConfig,isDirty);
        end

        function copyControlVariable(obj,ctrlVarSSRow,dlg)
            import slvariants.internal.manager.ui.config.ControlVariableRow


            ctrlVarIdx=ctrlVarSSRow.CtrlVarIdx;
            ctrlVarNames=obj.getControlVariableNames();
            newCtrlVarName=matlab.lang.makeUniqueStrings(ctrlVarSSRow.CtrlVarName,ctrlVarNames);
            newCtrlVarIdx=ctrlVarIdx+1;
            configSchema=obj.DialogSchema;

            if~obj.IsGlobalWksConfig
                obj.VariantConfigs.copyControlVariableByPos(obj.ConfigName,ctrlVarIdx,newCtrlVarName);
            end
            isDirty=true;
            obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.IsGlobalWksConfig,isDirty);
            newRow=ControlVariableRow(obj,newCtrlVarName,newCtrlVarIdx);

            obj.Children=[obj.Children(1:ctrlVarIdx),newRow,obj.Children(ctrlVarIdx+1:end)];
            if obj.IsGlobalWksConfig
                newRow.setControlVariableValue(Simulink.variant.utils.deepCopy(ctrlVarSSRow.CtrlVarStructForGlobalWksConfig.Value,'ErrorForNonCopyableHandles',true));
                newRow.setControlVariableSource(ctrlVarSSRow.CtrlVarStructForGlobalWksConfig.Source);
            end

            if~isempty(configSchema.CompBrowserSSSrc)
                configSchema.copyUpdateCompSpecificCtrlVarIndices(configSchema.CompBrowserSSSrc.Children,ctrlVarIdx);
            end
            if~configSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn&&configSchema.IsCompBrowserVisible
                currCompBrowserRow=configSchema.CompBrowserSSSrc.CurrentCompRow;
                compSpecificCtrlVarIndices=currCompBrowserRow.CompSpecificCtrlVarIndices;
                ctrlVarRowIdx=find(compSpecificCtrlVarIndices==ctrlVarIdx);
                currCompBrowserRow.CompSpecificCtrlVarIndices=...
                [compSpecificCtrlVarIndices(1:ctrlVarRowIdx),newCtrlVarIdx,compSpecificCtrlVarIndices(ctrlVarRowIdx+1:end)];
            end


            obj.updateIndicesForRowsBelow(newCtrlVarIdx,1);
        end

        function addControlVariable(obj,dlg,varargin)
            import slvariants.internal.manager.ui.config.ControlVariableRow
            ctrlVarNames=obj.getControlVariableNames();
            nVarCtrls=numel(ctrlVarNames);
            newCtrlVarName=matlab.lang.makeUniqueStrings('CtrlVar',ctrlVarNames);
            newCtrlVarIdx=nVarCtrls+1;

            if~obj.IsGlobalWksConfig
                obj.VariantConfigs.addControlVariableByName(obj.ConfigName,newCtrlVarName);
            end
            isDirty=true;
            obj.DialogSchema.setControlVariablesDirtyFlag(dlg,obj.IsGlobalWksConfig,isDirty);

            if numel(varargin)==0
                type='addCtxBasedVariable';
            else
                type=varargin{1};
            end

            switch(type)
            case 'addCtxBasedVariable'
                newValue=obj.getNewCtrlVarCtxBased(0);
            case 'addParamVariable'
                newValue=Simulink.Parameter(0);
            case 'addAUTOSARParamVariable'
                newValue=AUTOSAR.Parameter(0);
            case 'addSLVarCtrlVariable'
                newValue=Simulink.VariantControl(Value=0);
            otherwise
                newValue=0;
            end
            newRow=ControlVariableRow(obj,newCtrlVarName,newCtrlVarIdx);
            obj.Children=[obj.Children(1:nVarCtrls),newRow];
            newRow.setControlVariableValue(newValue);
            newRow.setControlVariableSource(getDefaultSource(obj.DialogSchema.BDName));

            if~obj.DialogSchema.CtrlVarSSSrc.IsShowAllCtrlVarsOn...
                &&obj.DialogSchema.IsCompBrowserVisible
                currCompBrowserRow=obj.DialogSchema.CompBrowserSSSrc.CurrentCompRow;
                currCompBrowserRow.CompSpecificCtrlVarIndices(end+1)=newCtrlVarIdx;
            end
            obj.updateIndicesForRowsBelow(newCtrlVarIdx,1);
        end

        function updateIndicesForRowsBelow(obj,newCtrlVarIdx,incrementBy)

            for idx=(newCtrlVarIdx+1):length(obj.Children)
                obj.Children(idx).CtrlVarIdx=obj.Children(idx).CtrlVarIdx+incrementBy;
            end
        end

        function clearHighlightForAllCtrlVar(obj,dlg)

            ctrlVarRows=obj.Children;
            for row=ctrlVarRows
                row.IsHighlighted=false;
            end
            obj.DialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
        end

    end

    methods(Access=private)
        function childrenSubset=getChildrenSubset(obj,children)
            childrenSubset=[];
            currCompBrowserRow=obj.DialogSchema.CompBrowserSSSrc.CurrentCompRow;
            if currCompBrowserRow.isRootRow()
                childrenSubset=obj.Children;
                return;
            end
            if~currCompBrowserRow.isModelRef()
                return;
            end
            childrenSubset=children(currCompBrowserRow.CompSpecificCtrlVarIndices);
            currCompName=currCompBrowserRow.getComponentName();
            selectedConfigName=obj.VariantConfigs.getSelectedConfigForComponent(obj.ConfigName,currCompName);
            if~isempty(selectedConfigName)
                return;
            end
        end

    end
end


function defaultSource=getDefaultSource(modelName)
    import slvariants.internal.manager.ui.config.VMgrConstants
    defaultSource=VMgrConstants.BaseWorkspaceSource;
    if(exist('modelName','var')==0)
        return;
    end
    if~isvarname(modelName)||~bdIsLoaded(modelName)
        return;
    end
    ddName=get_param(modelName,'DataDictionary');
    if~isempty(ddName)
        defaultSource=ddName;
    end
end


