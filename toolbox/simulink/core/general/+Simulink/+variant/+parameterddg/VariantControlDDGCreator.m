classdef(Sealed=true,Hidden=true)VariantControlDDGCreator<handle


























    properties(Access=private)
        fVarCtrlObject;
        fVariableName char;
    end

    properties(Hidden,Constant)



        ValueTag='SlVarControl_Value_tag';
        VATTag='SlVarControl_VAT_tag';
        ValTypeTag='SlVarControl_ValType_tag';
        EmptyWidgetTag='EmptyTag';
    end

    methods

        function obj=VariantControlDDGCreator(aVarCtrl,aVarName)
            obj.fVarCtrlObject=aVarCtrl;
            obj.fVariableName=aVarName;
        end


        function dlgStruct=getDialogStruct(obj)
            dlgStruct.DialogTitle=[class(obj.fVarCtrlObject),...
            ': ',obj.fVariableName];
            dlgStruct.Items={
            obj.createDescriptionGroup(),...
            obj.createValueTypeLabel(),...
            obj.createValueLabel(),...
            obj.createValueDialog(),...
            obj.createSlParamValGrp(),...
            obj.createValueComboBox(),...
            obj.createActivationTimeLabel(),...
            obj.createActivationTimeComboBox()};

            dlgStruct.LayoutGrid=[5,2];
            dlgStruct.RowStretch=[1,1,0,1,5];

            mapfile='/mapfiles/simulink.map';
            helpTopicKey='simulinkvariantcontrol';
            dlgStruct.HelpMethod='helpview';
            dlgStruct.HelpArgs={[docroot,mapfile],helpTopicKey};
        end
    end

    methods(Access=?tVariantControlDDG)
        function descText=createDescriptionText(~)
            descMsg=message('Simulink:VariantParameters:SlVariantControlDDGDesc');
            descText.Name=descMsg.getString();
            descText.Type='text';
            descText.WordWrap=true;
        end

        function emptyWidget=createEmptyWidget(~)
            emptyWidget.Type='text';
            emptyWidget.Visible=false;
            emptyWidget.Name='';
            emptyWidget.Tag=Simulink.variant.parameterddg.VariantControlDDGCreator.EmptyWidgetTag;
        end

        function descGroup=createDescriptionGroup(obj)
            descGroup.Name='Simulink.VariantControl';
            descGroup.Type='group';
            descGroup.Items={obj.createDescriptionText()};
            descGroup.RowSpan=[1,1];
            descGroup.ColSpan=[1,2];
        end

        function valueTypeLabel=createValueTypeLabel(~)
            valueTypeLabel.Name='Value Type';
            valueTypeLabel.Type='text';
            valueTypeLabel.RowSpan=[2,2];
            valueTypeLabel.ColSpan=[1,1];
            valueTypeLabel.Tag='ValueTypeLabel';
        end

        function valueTypeComboBox=createValueComboBox(obj)
            valueTypeComboBox.RowSpan=[2,2];
            valueTypeComboBox.ColSpan=[2,2];
            valueTypeComboBox.Name='';
            valueTypeComboBox.Type='combobox';
            valueTypeComboBox.Entries={'Numeric','Simulink.Parameter','AUTOSAR.Parameter'};
            valueTypeComboBox.Editable=true;
            valueTypeComboBox.Tag=Simulink.variant.parameterddg.VariantControlDDGCreator.ValTypeTag;
            valueTypeComboBox.DialogRefresh=true;
            valueTypeComboBox.ObjectProperty='ValueType';
            valueTypeComboBox.Mode=true;
            valueTypeComboBox.Value=getPropValue(obj.fVarCtrlObject,'ValueType');
        end

        function valueLabel=createValueLabel(obj)
            if~isa(obj.fVarCtrlObject.Value,'Simulink.Parameter')
                valueLabel.Type='text';
                valueLabel.RowSpan=[3,3];
                valueLabel.ColSpan=[1,1];
                valueLabel.Name='Value';
                valueLabel.Tag='ValueLabel';
            else
                valueLabel=obj.createEmptyWidget();
            end
        end

        function valueDialog=createValueDialog(obj)
            if~isa(obj.fVarCtrlObject.Value,'Simulink.Parameter')
                valueDialog.Tag=Simulink.variant.parameterddg.VariantControlDDGCreator.ValueTag;
                valueDialog.RowSpan=[3,3];
                valueDialog.ColSpan=[2,2];
                valueDialog.Type='edit';
                valueDialog.Name='';
                valueDialog.Value=getPropValue(obj.fVarCtrlObject,'Value');
                valueDialog.DialogRefresh=true;
                valueDialog.ObjectProperty='Value';
                valueDialog.Mode=true;
            else
                valueDialog=obj.createEmptyWidget();
            end
        end

        function slParamValGrp=createSlParamValGrp(obj)
            if isa(obj.fVarCtrlObject.Value,'Simulink.Parameter')
                slParamValGrp.Type='group';
                slParamDlgStruct=dataddg(obj.fVarCtrlObject.Value,'','data');
                slParamValGrp.Items={slParamDlgStruct.Items{1}};%#ok<CCAT1> 
                slParamValGrp.Tag='slParamValGrp';
                slParamValGrp.RowSpan=[3,3];
                slParamValGrp.ColSpan=[2,2];
                slParamValGrp.Name='';
            else
                slParamValGrp=obj.createEmptyWidget();
            end
        end

        function activationTimeLabel=createActivationTimeLabel(~)
            activationTimeLabel.Name='ActivationTime';
            activationTimeLabel.Type='text';
            activationTimeLabel.RowSpan=[4,4];
            activationTimeLabel.ColSpan=[1,1];
            activationTimeLabel.Tag='ActivationTimeLabel';
        end

        function activationTimeComboBox=createActivationTimeComboBox(obj)
            activationTimeComboBox.Name='';
            activationTimeComboBox.Type='combobox';
            activationTimeComboBox.Tag=Simulink.variant.parameterddg.VariantControlDDGCreator.VATTag;
            activationTimeComboBox.WidgetId='ActivationTime_wid';
            activationTimeComboBox.Editable=false;
            activationTimeComboBox.Value=obj.fVarCtrlObject.ActivationTime;
            activationTimeComboBox.ObjectProperty='ActivationTime';
            entries=set(obj.fVarCtrlObject,'ActivationTime');
            activationTimeComboBox.Entries=entries;
            activationTimeComboBox.RowSpan=[4,4];
            activationTimeComboBox.ColSpan=[2,2];
            activationTimeComboBox.Mode=true;
        end
    end
end


