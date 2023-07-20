classdef CompBrowserSSRow<handle





    properties


        Children(1,:)slvariants.internal.manager.ui.compbrowser.CompBrowserSSRow;



        HierViewRow sl_variants.manager.view.HierarchyViewRow;



        CompBrowserViewSrc(1,1)slvariants.internal.manager.ui.compbrowser.CompBrowserSSSource;




        CompSpecificCtrlVarIndices(1,:)double;
    end

    methods(Hidden)
        function obj=CompBrowserSSRow(hierarchyViewRow,compBrowserViewSrc)
            if nargin==0
                return;
            end
            obj.HierViewRow=hierarchyViewRow;
            obj.CompBrowserViewSrc=compBrowserViewSrc;
        end

        function children=getHierarchicalChildren(obj)
            children=obj.getChildren();
        end

        function children=getChildren(obj)
            import slvariants.internal.manager.ui.compbrowser.CompBrowserSSRow;
            if~isempty(obj.Children)
                children=obj.Children;
                return;
            end
            childRows=obj.HierViewRow.ChildRows;
            if(double(childRows.Size)==1)&&isa(childRows(1).Controller,'sl_variants.manager.controller.HierarchyRowProxy')


                childRows(1).Controller.loadChildBlocks();
            end
            obj.Children=CompBrowserSSRow.empty;
            for i=1:childRows.Size
                if obj.filterComponents(childRows(i).Controller)
                    continue;
                end
                obj.Children=[obj.Children,CompBrowserSSRow(childRows(i),obj.CompBrowserViewSrc)];
            end
            children=obj.Children;
        end

        function label=getDisplayIcon(obj)
            label=obj.HierViewRow.Controller.getEditTimeNameIcon();
        end

        function hierarchical=isHierarchical(~)
            hierarchical=true;
        end

        function propVal=getPropValue(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            switch propName
            case VMgrConstants.ComponentColName
                propVal=obj.HierViewRow.getDisplayLabel();
                return;
            case VMgrConstants.SelectedConfigColName
                propVal='';
                if~obj.isModelRef()


                    return;
                end
                if isempty(obj.getCompConfigs())

                    return;
                end

                topModelConfigName=obj.getTopModelConfigurationName();
                compName=obj.getComponentName();
                variantConfigs=obj.CompBrowserViewSrc.ConfigDialogSchema.SourceObj;
                selectedConfig=variantConfigs.getSelectedConfigForComponent(topModelConfigName,compName);

                propVal=VMgrConstants.CustomSelectedConfig;
                if isempty(selectedConfig)


                    return;
                end
                propVal=selectedConfig;
            otherwise

                assert(false,'Invalid column name');
            end
        end

        function isValid=isValidProperty(~,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            validColNames={VMgrConstants.ComponentColName,VMgrConstants.SelectedConfigColName};
            isValid=ismember(propName,validColNames);
        end

        function setPropValue(obj,propName,propVal)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema;
            if~strcmp(propName,VMgrConstants.SelectedConfigColName)
                return;
            end
            selectedConfigName='';
            if~strcmp(propVal,VMgrConstants.CustomSelectedConfig)


                selectedConfigName=propVal;
            end

            topModelConfigName=obj.getTopModelConfigurationName();
            compName=obj.getComponentName();
            variantConfigs=obj.CompBrowserViewSrc.ConfigDialogSchema.SourceObj;

            obj.CompBrowserViewSrc.CurrentCompRow=obj;
            ConfigurationsDialogSchema.setSourceObjDirtyFlag(obj.CompBrowserViewSrc.ConfigDialogSchema);
            obj.updateCtrlVariablesRowReadOnlyProperty();
            variantConfigs.removeComponentConfiguration(...
            'ConfigurationName',topModelConfigName,...
            'ComponentName',compName);

            dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(...
            obj.CompBrowserViewSrc.ConfigDialogSchema.BDName);

            if isempty(selectedConfigName)



                ConfigurationsDialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
                return;
            end
            variantConfigs.setSelectedConfigForComponent(topModelConfigName,compName,selectedConfigName);
            compConfig=obj.getCompConfigs();
            selectedConfigIdx=strcmp(selectedConfigName,{compConfig.Name});
            selectedConfig=compConfig(selectedConfigIdx);
            if isempty(selectedConfig.ControlVariables)


                ConfigurationsDialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
                return;
            end

            obj.addCtrlVarsToSS(selectedConfig.ControlVariables);
        end

        function updateCtrlVariablesRowReadOnlyProperty(obj)



            import slvariants.internal.manager.ui.config.VMgrConstants;
            topModelConfigName=obj.getTopModelConfigurationName();
            compName=obj.getComponentName();
            variantConfigs=obj.CompBrowserViewSrc.ConfigDialogSchema.SourceObj;
            oldSelectedConfigName=variantConfigs.getSelectedConfigForComponent(topModelConfigName,compName);
            if isempty(oldSelectedConfigName)
                return;
            end
            allCompRows=obj.CompBrowserViewSrc.getAllRows();
            compConfigs=obj.getCompConfigs();
            oldCompConfig=compConfigs(strcmp({compConfigs.Name},oldSelectedConfigName));
            oldCompConfigCtrlVars=oldCompConfig.ControlVariables;
            for oldCompConfigCtrlVar=oldCompConfigCtrlVars
                editable=true;
                for compRow=allCompRows

                    if compRow==obj
                        continue;
                    end
                    compRowSelectedConfigName=compRow.getPropValue(VMgrConstants.SelectedConfigColName);
                    if isempty(compRowSelectedConfigName)||strcmp(compRowSelectedConfigName,VMgrConstants.CustomSelectedConfig)
                        continue;
                    end
                    compRowConfigs=compRow.getCompConfigs();
                    compRowSelectedConfig=compRowConfigs(strcmp({compRowConfigs.Name},compRowSelectedConfigName));
                    if isempty(compRowSelectedConfig.ControlVariables)
                        continue;
                    end

                    for compRowCtrlVar=compRowSelectedConfig.ControlVariables
                        if strcmp(compRowCtrlVar.Name,oldCompConfigCtrlVar.Name)
                            editable=false;
                            break;
                        end
                    end
                    if~editable
                        break;
                    end
                end
                ctrlVarRow=obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc.Children(find(strcmp({obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc.Children.CtrlVarName},oldCompConfigCtrlVar.Name)));
                ctrlVarRow.IsReadOnly=~editable;
            end
        end

        function isEditable=isEditableProperty(obj,propName)
            isEditable=false;
            if~strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.SelectedConfigColName)
                return;
            end

            if~obj.isModelRef()
                return;
            end

            if isempty(obj.getCompConfigs())
                return;
            end

            isEditable=true;
        end

        function type=getPropDataType(~,propName)
            type='string';

            if strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.SelectedConfigColName)
                type='enum';
            end
        end

        function allowedValues=getPropAllowedValues(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            allowedValues={};
            if~strcmp(propName,VMgrConstants.SelectedConfigColName)||~obj.isModelRef()
                return;
            end

            compConfigs=obj.getCompConfigs();
            if isempty(compConfigs)
                return;
            end

            ctrlVars=obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc.getControlVarStruct();
            if isempty(ctrlVars)
                allowedValues={compConfigs.Name,VMgrConstants.CustomSelectedConfig};
                return;
            end



            allowedValues={};
            for compConfig=compConfigs
                allow=true;
                for cv=compConfig.ControlVariables
                    ctrlVarRow=obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc.Children(strcmp({obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc.Children.CtrlVarName},cv.Name));

                    if isempty(ctrlVarRow)
                        continue;
                    end

                    if~ctrlVarRow.IsReadOnly
                        continue;
                    end

                    ctrlVar=ctrlVars(strcmp({ctrlVars.Name},cv.Name));
                    if cv.Value==ctrlVar.Value
                        continue;
                    end



                    allCompRows=obj.CompBrowserViewSrc.getAllRows();
                    for compRow=allCompRows

                        if compRow==obj
                            continue;
                        end
                        compRowSelectedConfigName=compRow.getPropValue(VMgrConstants.SelectedConfigColName);
                        if isempty(compRowSelectedConfigName)||strcmp(compRowSelectedConfigName,VMgrConstants.CustomSelectedConfig)
                            continue;
                        end
                        compRowConfigs=compRow.getCompConfigs();
                        compRowSelectedConfig=compRowConfigs(strcmp({compRowConfigs.Name},compRowSelectedConfigName));
                        if isempty(compRowSelectedConfig.ControlVariables)
                            continue;
                        end

                        for compRowCtrlVar=compRowSelectedConfig.ControlVariables
                            if strcmp(compRowCtrlVar.Name,ctrlVar.Name)
                                allow=false;
                                break;
                            end
                        end
                        if~allow
                            break;
                        end
                    end
                    if~allow
                        break;
                    end
                end
                if allow
                    allowedValues{end+1}=compConfig.Name;%#ok
                end
            end
            allowedValues{end+1}=VMgrConstants.CustomSelectedConfig;
        end

        function getPropertyStyle(obj,propName,propStyle)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            if~strcmp(propName,VMgrConstants.ComponentColName)
                return;
            end
            if obj.compHasConfiguration()
                propStyle.Icon=slvariants.internal.manager.ui.config.VMgrConstants.CompBrowserHasCtrlVarsIcon;
                propStyle.IconAlignment='right';
            end
            if obj.compHasControlVariables()
                propStyle.Italic=true;
            end

        end

        function compName=getComponentName(obj)
            compName='';
            if~obj.isModelRef()
                return;
            end
            compName=obj.HierViewRow.Controller.OwnerBlock.EditTimeBlock.ModelName;
        end

        function isRoot=isRootRow(obj)
            isRoot=true;
            if isempty(obj)


                return;
            end
            isRoot=obj.HierViewRow.ViewSource.RootRow==obj.HierViewRow;
        end

        function out=isModelRef(obj)
            out=false;
            if isempty(obj)


                return;
            end
            compBlock=obj.HierViewRow.Controller.OwnerBlock;
            out=(sl_variants.manager.model.VMgrBlockType.ModelReference==...
            compBlock.EditTimeBlock.getBlockType());
        end

        function compConfigs=getCompConfigs(obj)


            compConfigs=slvariants.internal.config.types.getConfigurationStruct(true);
            mdlRefName=obj.getComponentName();
            key=[obj.CompBrowserViewSrc.ConfigDialogSchema.ConfigObjVarName,'/',mdlRefName];
            if~obj.CompBrowserViewSrc.CompConfigMap.isKey(key)
                oldVCD=Simulink.variant.utils.getConfigurationDataNoThrow(mdlRefName);
                if isempty(oldVCD)
                    return;
                end
                slvariants.internal.config.migrateVCD(oldVCD,mdlRefName);
                compConfigs=oldVCD.Configurations;
                obj.CompBrowserViewSrc.CompConfigMap(key)=compConfigs;
                return;
            end

            compConfigsCell=obj.CompBrowserViewSrc.CompConfigMap.values({key});
            compConfigs=compConfigsCell{1};
        end
    end

    methods(Access=private)

        function flag=compHasControlVariables(obj)
            flag=obj.HierViewRow.Controller.getShowinViewFilter(...
            sl_variants.manager.model.viewfilters.Filter.VARIANTS);
        end

        function flag=compHasConfiguration(obj)
            flag=false;
            if~obj.isModelRef()


                return;
            end
            compName=obj.getComponentName();
            try
                vcd=get_param(compName,'VariantConfigurationObject');
            catch

                return;
            end
            flag=~isempty(vcd);
        end

        function toFilter=filterComponents(~,hierarchyRow)





            compBlock=hierarchyRow.OwnerBlock;


            blkType=compBlock.EditTimeBlock.getBlockType();
            isGenericVMgrBlk=blkType==sl_variants.manager.model.VMgrBlockType.GenericVMgrBlock;
            isIVBlk=blkType==sl_variants.manager.model.VMgrBlockType.VariantSrcSink;
            toFilter=isGenericVMgrBlk||isIVBlk;
        end

        function configName=getTopModelConfigurationName(obj)
            configName=obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc.ConfigName;
        end

        function addCtrlVarsToSS(obj,ctrlVars)






            ctrlVarSSSrc=obj.CompBrowserViewSrc.ConfigDialogSchema.CtrlVarSSSrc;
            ctrlVarsInConfig=ctrlVarSSSrc.getControlVariableNames();


            [~,configIdx,ctrlVarsIdx]=intersect(ctrlVarsInConfig,{ctrlVars.Name},'stable');
            [~,ctrlVarsDiffIdx]=setdiff({ctrlVars.Name},ctrlVarsInConfig);

            configSchema=obj.CompBrowserViewSrc.ConfigDialogSchema;
            nCtrlVarsOld=length(ctrlVarsInConfig);


            for idx=1:length(configIdx)
                ctrlVarSSRow=ctrlVarSSSrc.Children(configIdx(idx));
                ctrlVarSSRow.setControlVariableValue(ctrlVars(ctrlVarsIdx(idx)).Value);
                ctrlVarSSRow.setControlVariableSource(ctrlVars(ctrlVarsIdx(idx)).Source);
                ctrlVarSSRow.IsReadOnly=true;
            end

            dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(...
            obj.CompBrowserViewSrc.ConfigDialogSchema.BDName);

            nCtrlVarsToAdd=numel(ctrlVarsDiffIdx);
            nTotalCtrlVars=nCtrlVarsOld+nCtrlVarsToAdd;
            for idx=1:nCtrlVarsToAdd
                ctrlVarSSSrc.addControlVariable(dlg);
                newCtrlVarRow=ctrlVarSSSrc.Children(end);
                newCtrlVarRow.setControlVariableName(ctrlVars(ctrlVarsDiffIdx(idx)).Name);
                newCtrlVarRow.setControlVariableValue(ctrlVars(ctrlVarsDiffIdx(idx)).Value);
                newCtrlVarRow.setControlVariableSource(ctrlVars(ctrlVarsDiffIdx(idx)).Source);
                newCtrlVarRow.IsReadOnly=true;
            end

            obj.CompSpecificCtrlVarIndices=[configIdx',(nCtrlVarsOld+1):nTotalCtrlVars];
            configSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');
        end
    end
end


