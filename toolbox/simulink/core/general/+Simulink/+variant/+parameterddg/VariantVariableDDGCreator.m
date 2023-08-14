classdef(Sealed=true,Hidden=true)VariantVariableDDGCreator<handle




























    properties(SetAccess=private,GetAccess=public)
        fVariantVariable;
        fVariableName char;
    end

    properties(Hidden,Constant)
        AddChoiceIconPath=slfullfile(matlabroot,...
        'toolbox/simulink/blockSupport/resources','add_port.png');
        DeleteChoiceIconPath=slfullfile(matlabroot,...
        'toolbox/simulink/blockSupport/resources','delete_port.png');
        SpreadSheetTag='SlVariantVariable_choice_spreadsheet_tag';
        AddChoiceTag='SlVariantVariable_addchoice_btn_tag';
        DeleteChoiceTag='SlVariantVariable_delete_btn_tag';
        SpecificationEditTag='SlVariantVariable_spec_edit_tag';
    end

    methods

        function obj=VariantVariableDDGCreator(aVariantVariable,aVarName)
            obj.fVariantVariable=aVariantVariable;
            obj.fVariableName=aVarName;
        end


        function dlgStruct=getDialogStruct(obj)
            dlgStruct.DialogTitle=[class(obj.fVariantVariable),...
            ': ',obj.fVariableName];
            dlgStruct.Items={obj.createDescriptionGroup(),...
            obj.createEditPanel(),...
            obj.createChoicesSpreadSheet(),...
            obj.createSpecDescriptionGroup(),...
            obj.createSpecificationLabel(),...
            obj.createSpecificationEditBox()};
            dlgStruct.LayoutGrid=[4,2];

            dlgStruct.PreApplyArgs={obj,'%dialog'};
            dlgStruct.PreApplyCallback='Simulink.variant.parameterddg.preApplyCallVariantVariable';

            mapfile='/mapfiles/simulink.map';
            helpTopicKey='simulinkvariantvariable';
            dlgStruct.HelpMethod='helpview';
            dlgStruct.HelpArgs={[docroot,mapfile],helpTopicKey};
        end
    end

    methods(Access=?tVariantVariableDDG)
        function descText=createDescriptionText(~)
            descMsg1=message('Simulink:VariantParameters:SlVariantVariableDDGDesc');
            descMsg2=message('Simulink:VariantParameters:SlVariantVariableCondDesc');
            descText.Name=[descMsg1.getString(),newline,newline,descMsg2.getString()];
            descText.Type='text';
            descText.WordWrap=true;
        end

        function descGroup=createDescriptionGroup(obj)
            descGroup.Name='Simulink.VariantVariable';
            descGroup.Type='group';
            descGroup.Items={obj.createDescriptionText()};
            descGroup.RowSpan=[1,1];
            descGroup.ColSpan=[1,2];
        end

        function descText=createSpecDescriptionText(~)
            descMsg=message('Simulink:VariantParameters:SlVariantVariableSpecDesc');
            descText.Name=descMsg.getString();
            descText.Type='text';
            descText.WordWrap=true;
        end

        function descGroup=createSpecDescriptionGroup(obj)
            descGroup.Type='group';
            descGroup.Items={obj.createSpecDescriptionText()};
            descGroup.RowSpan=[3,3];
            descGroup.ColSpan=[1,2];
        end

        function addChoiceButton=createAddChoiceButton(obj)
            addChoiceButton.Name='';
            addChoiceButton.Type='pushbutton';
            addChoiceButton.RowSpan=[1,1];
            addChoiceButton.ColSpan=[1,1];
            addChoiceButton.Enabled=true;
            addChoiceButton.FilePath=obj.AddChoiceIconPath;
            addChoiceButton.ToolTip='Add choice';
            addChoiceButton.Tag=Simulink.variant.parameterddg.VariantVariableDDGCreator.AddChoiceTag;
            addChoiceButton.MatlabMethod='Simulink.variant.parameterddg.addNewChoice';
            addChoiceButton.MatlabArgs={obj,'%dialog'};
        end

        function deleteChoiceButton=createDeleteChoiceButton(obj)
            deleteChoiceButton.Name='';
            deleteChoiceButton.Type='pushbutton';
            deleteChoiceButton.RowSpan=[2,2];
            deleteChoiceButton.ColSpan=[1,1];
            deleteChoiceButton.Enabled=true;
            deleteChoiceButton.FilePath=obj.DeleteChoiceIconPath;
            deleteChoiceButton.ToolTip='Delete choice';
            deleteChoiceButton.Tag=Simulink.variant.parameterddg.VariantVariableDDGCreator.DeleteChoiceTag;
            deleteChoiceButton.MatlabMethod='Simulink.variant.parameterddg.deleteChoice';
            deleteChoiceButton.MatlabArgs={obj,'%dialog'};
        end

        function spacer=createSpacer(~,rowIdx,colIdx)
            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[rowIdx,rowIdx];
            spacer.ColSpan=[colIdx,colIdx];
        end

        function editPanel=createEditPanel(obj)
            editPanel.Type='panel';
            editPanel.Items={obj.createAddChoiceButton(),...
            obj.createDeleteChoiceButton(),...
            obj.createSpacer(3,1)};
            editPanel.LayoutGrid=[3,1];
            editPanel.RowStretch=[0,0,1];
            editPanel.RowSpan=[2,2];
            editPanel.ColSpan=[1,1];
        end

        function choicesTable=createChoicesSpreadSheet(obj)
            choicesTable.Type='spreadsheet';
            choicesTable.Columns={'Condition','Value'};
            choicesTable.RowSpan=[2,2];
            choicesTable.ColSpan=[2,2];
            choicesTable.Enabled=true;
            choicesTable.Source=Simulink.variant.parameterddg...
            .ChoicesSpreadSheetSource(obj);
            choicesTable.Tag=Simulink.variant.parameterddg.VariantVariableDDGCreator.SpreadSheetTag;
            choicesTable.Visible=true;
            choicesTable.ValueChangedCallback=@choiceTableValueChanged;
            choicesTable.DialogRefresh=true;
            choicesTable.Mode=true;
        end

        function specLabel=createSpecificationLabel(~)
            specLabel.Name='Specification';
            specLabel.Type='text';
            specLabel.RowSpan=[4,4];
            specLabel.ColSpan=[1,1];
            specLabel.Tag='SpecificationLabel';
        end

        function specEditBox=createSpecificationEditBox(obj)
            specEditBox.Name='';
            specEditBox.RowSpan=[4,4];
            specEditBox.ColSpan=[2,2];
            specEditBox.Type='edit';
            specEditBox.Tag=Simulink.variant.parameterddg.VariantVariableDDGCreator.SpecificationEditTag;
            specEditBox.ObjectProperty='Specification';
            specEditBox.MatlabMethod='Simulink.variant.parameterddg.updateSpec';
            specEditBox.MatlabArgs={obj,'%dialog'};
        end



        function specWidget=createSpecificationWidget(obj)
            specWidget.Type='text';
            specWidget.Name='';
            if~isempty(obj.fVariantVariable.Specification)
                specDlg=sl_get_dialog_schema(obj.fVariantVariable.Specification,'');
                specWidget=specDlg.Items{1};
            end
            specWidget.RowSpan=[4,4];
            specWidget.ColSpan=[1,2];
        end
    end

    methods(Hidden)
        function updateChoice(obj,aCondition,aValue)

            obj.fVariantVariable=obj.fVariantVariable.setChoice({aCondition,aValue});
        end

        function addChoice(obj,aCondition,aValue)

            obj.fVariantVariable=obj.fVariantVariable.addChoice({aCondition,aValue});
        end

        function removeChoice(obj,aCondition)

            obj.fVariantVariable=obj.fVariantVariable.removeChoice(aCondition);
        end

        function updateSpec(obj,aNewSpec)

            obj.fVariantVariable.Specification=aNewSpec;
        end
    end
end


function choiceTableValueChanged(~,sels,name,value,dlg)
    selRowObj=sels{1};
    try
        selRowObj.updateProp(name,value,dlg);
    catch ME
        dp=DAStudio.DialogProvider;
        dp.errordlg(ME.message,'Error',true);
    end

    updateSpreadSheet(dlg);
end

function updateSpreadSheet(dlg)
    spreadSheetInterface=dlg.getWidgetInterface(Simulink.variant.parameterddg...
    .VariantVariableDDGCreator.SpreadSheetTag);
    spreadSheetInterface.update();
end



