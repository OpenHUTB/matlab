classdef(Sealed,Hidden)SpreadSheetTabChange<handle




    properties(Constant)
        CompBrowserViewTabTag='CBV';
    end

    methods(Static,Hidden)
        function spreadSheetTabChangeCallback(ssModelHierComp,tabTag,~)
            modelName='';%#ok
            ssSrc=ssModelHierComp.getSource();
            if isa(ssModelHierComp.getSource,'slvariants.internal.manager.ui.compbrowser.CompBrowserSSSource')
                modelName=ssSrc.HierViewSource.RootRow.getDisplayLabel;
            else
                modelName=ssSrc.RootRow.getDisplayLabel;
            end

            src='';%#ok
            modelHandle=get_param(modelName,'Handle');
            CBV=slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.CompBrowserViewTabTag;
            if strcmp(tabTag,CBV)
                dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
                configSchema=dlg.getSource();
                if isempty(configSchema.CompBrowserSSSrc)
                    configSchema.CompBrowserSSSrc=slvariants.internal.manager.ui.compbrowser.CompBrowserSSSource(configSchema);
                end
                src=configSchema.CompBrowserSSSrc;

                Component=slvariants.internal.manager.ui.config.VMgrConstants.ComponentColName;
                SelectedConfiguration=slvariants.internal.manager.ui.config.VMgrConstants.SelectedConfigColName;
                ssModelHierComp.setColumns({Component,SelectedConfiguration},'','',true);
            else
                src=slvariants.internal.manager.core.getViewSource(modelHandle);
                Name=slvariants.internal.manager.ui.config.VMgrConstants.Name;
                VariantControl=slvariants.internal.manager.ui.config.VMgrConstants.VariantCondition;
                Condition=slvariants.internal.manager.ui.config.VMgrConstants.Condition;
                ssModelHierComp.setColumns({Name,VariantControl,Condition},'','',true);
            end
            ssModelHierComp.setSource(src);



            ssModelHierComp.updateTitleView();

            slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.updateNavAndBlkView(modelHandle);
        end

        function compBrowserToggle(modelName)
            dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
            configSchema=dlg.getSource();
            slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.setCompBrowserVisible(modelName,~configSchema.IsCompBrowserVisible);
        end

        function setCompBrowserVisible(modelName,visible)
            vmStudioHandle=slvariants.internal.manager.core.getStudio(get_param(modelName,'Handle'));
            ssModelHierComp=vmStudioHandle.getComponent('GLUE2:SpreadSheet',message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
            CBV=slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.CompBrowserViewTabTag;
            dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);

            helpCompIdx=slvariants.internal.manager.ui.utils.getHelpComponentIndices();

            configSchema=dlg.getSource();
            hierSSIdx=slvariants.internal.manager.ui.utils.getHierSSIndices();
            if configSchema.IsCompBrowserVisible&&~visible
                ssModelHierComp.removeNamedTab(CBV);



                ssModelHierComp.setCurrentTab(hierSSIdx.Blocks);

                slvariants.internal.manager.ui.utils.setHelpDocIndex(vmStudioHandle,helpCompIdx.DefineConfigs);
            elseif~configSchema.IsCompBrowserVisible&&visible
                ssModelHierComp.addTab(...
                message('Simulink:VariantManagerUI:CompBrowserTitle').getString(),...
                CBV,...
                message('Simulink:VariantManagerUI:CompBrowserViewTabTooltip').getString());
                ssModelHierComp.setCurrentTab(hierSSIdx.ComponentConfigurations);

                slvariants.internal.manager.ui.utils.setHelpDocIndex(vmStudioHandle,helpCompIdx.ComposeComponents);
            else
                return;
            end

            configSchema.showHideCompBrowser(dlg,visible);
        end

        function updateCompBrowser(modelName)
            vmStudioHandle=slvariants.internal.manager.core.getStudio(get_param(modelName,'Handle'));
            ssModelHierComp=vmStudioHandle.getComponent('GLUE2:SpreadSheet',message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
            ssModelHierComp.update(true);
        end

        function isCurrentTab=isCompBrowserCurrentTab(modelHandle)
            vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
            ssModelHierComp=vmStudioHandle.getComponent('GLUE2:SpreadSheet',message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
            hierSSIdx=slvariants.internal.manager.ui.utils.getHierSSIndices();
            isCurrentTab=isequal(ssModelHierComp.getCurrentTab(),hierSSIdx.ComponentConfigurations);
        end

        function updateNavAndBlkView(modelHandle)
            vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
            toolStrip=vmStudioHandle.getToolStrip;
            as=toolStrip.getActionService();
            as.refreshAction('viewBlocksFilterAction');
            as.refreshAction('navigateChoicesComboBoxAction');
            as.refreshAction('navigateLabelAction');
            as.refreshAction('viewBlocksLabelAction');
            as.refreshAction('navigateLeftChoicesAction');
            as.refreshAction('navigateRightChoicesAction');
        end
    end
end


