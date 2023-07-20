classdef VariantConfigurationsObjectSelectorDialog<handle




    properties
        VariantConfigObjectNames={};
        VariantConfigObjects={};
        ConfigurationsDialogSchema slvariants.internal.manager.ui.config.ConfigurationsDialogSchema;
        VariantConfigurationsDialog;
        ObjectDestructionListener;
        SelectedConfigObjectIdx;
    end

    methods

        function obj=VariantConfigurationsObjectSelectorDialog(configDlgSchema,varConfigObjectNames,varConfigObjects,configDlg)
            obj.VariantConfigObjectNames=varConfigObjectNames;
            obj.VariantConfigObjects=varConfigObjects;
            obj.ConfigurationsDialogSchema=configDlgSchema;
            obj.VariantConfigurationsDialog=configDlg;
        end

        function dlgStruct=getDialogSchema(obj,~)
            configRadioButtonWidget.Name=message('Simulink:VariantManagerUI:VariantManagerImportRequestMessage').getString();
            configRadioButtonWidget.Entries=obj.VariantConfigObjectNames;
            configRadioButtonWidget.Type='radiobutton';
            configRadioButtonWidget.Tag='configRadioButtonWidgetTag';
            configRadioButtonWidget.Value=0;
            configRadioButtonWidget.RowSpan=[1,1];
            configRadioButtonWidget.ColSpan=[1,1];

            dlgStruct.DialogTitle=message('Simulink:VariantManagerUI:VariantManagerImportSelectTitle').getString();
            dlgStruct.Items={configRadioButtonWidget};
            dlgStruct.DialogTag='VariantConfigurationsObjectSelectorDialogTag';
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};
            dlgStruct.EmbeddedButtonSet={'OK','Cancel'};
            dlgStruct.PostApplyCallback='slvariants.internal.manager.ui.config.varConfigsObjSelectorDDGCallback';
            dlgStruct.PostApplyArgs={obj,'%dialog'};
            dlgStruct.LayoutGrid=[1,1];
        end
    end
end
