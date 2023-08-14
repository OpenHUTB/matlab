classdef GenerateReport<evolutions.internal.ui.tools.CustomDialogInterface




    properties(Access=protected)

        TitlePagePrompt={'Title page Information'}

        TitleEditFieldLabel={'Title:'}
        AuthorEditFieldLabel={'Author:'}
        FileFormatDropDownLabel={'File Format:'}
        FileNameEditFieldLabel={'File Name:'}

        GenerateReportBodyPrompt={'Report Layout Options'}

        IncludeInReport={'Include in Report'}

        OutputOptionsPrompt={'Output Options'}

        Title='Generate Report'


TitleEditField
AuthorEditField
FileNameEditField


FileFormatDropDown

GenRptCheckBoxes
IncludeInReportCheckBoxes
LauchReportCheckBox

CreateBtn
CancelBtn
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

DialogWidth
DialogHeight

WorkingGridRows
WorkingGridCols
    end

    methods(Access=?evolutions.internal.app.dialogs.customdialogs.CustomDialogFactory)
        function obj=GenerateReport(data)

            obj@evolutions.internal.ui.tools.CustomDialogInterface(data);
            obj.setDialogTitle(obj.Title);
        end

    end
    methods

    end

    methods(Access=protected)

        function installCallbacks(obj)

            obj.CreateBtn.ButtonPushedFcn=@obj.CreateBtnAction;
            obj.CancelBtn.ButtonPushedFcn=@(~,~)delete(obj.Figure);
            obj.TitleEditField.ValueChangedFcn=@obj.textValueChanging;
            obj.AuthorEditField.ValueChangedFcn=@obj.textValueChanging;
        end

        function CreateBtnAction(obj,~,~)


            obj.Output.FileName=obj.FileNameEditField.Value;
            obj.Output.FileFormat=obj.FileFormatDropDown.Value;

            obj.Output.Author=obj.AuthorEditField.Value;
            obj.Output.Title=obj.TitleEditField.Value;
            obj.Output.LaunchReport=obj.LauchReportCheckBox{1}.Value;
            obj.Output.GenerateEvolutionTreeReport=obj.GenRptCheckBoxes{1,1}.Value;
            obj.Output.GenerateEvolutionReport=obj.GenRptCheckBoxes{2,1}.Value;
            obj.Output.GenerateArtifactFileReport=obj.GenRptCheckBoxes{3,1}.Value;
            obj.Output.IncludeEvolutionTreeTopInfoTable=obj.IncludeInReportCheckBoxes{1,1}.Value;
            obj.Output.IncludeEvolutionTreeDetailsTable=obj.IncludeInReportCheckBoxes{1,2}.Value;

            delete(obj.Figure);

        end

        function textValueChanging(obj,~,newEntry)

            obj.CreateBtn.Enable=~isempty(newEntry.Value);
        end
    end

    methods(Access=protected)

        function setDialogSize(obj)
            obj.DialogWidth=500;
            obj.DialogHeight=600;
        end

        function setWorkingGridDimensions(obj)

            obj.WorkingGridRows={'fit','fit','fit',...
            'fit','fit',...
            'fit','fit',...
            'fit',...
            'fit','fit','fit',...
            'fit'};

            obj.WorkingGridCols={'fit'};

        end

        function createDialogComponents(obj)


            obj.createLabel(1,obj.TitlePagePrompt);

            editFieldText=sprintf('Design Tree Report for %s',obj.UserData.Name);


            obj.TitleEditField=obj.createLabelAndEditField(2,...
            obj.TitleEditFieldLabel,...
            editFieldText);


            obj.AuthorEditField=obj.createLabelAndEditField(3,...
            obj.AuthorEditFieldLabel,...
            evolutions.internal.utils.getUserName);



            obj.createLabel(4,obj.GenerateReportBodyPrompt);


            obj.GenRptCheckBoxes=obj.createCheckBoxes(5,{'1x','1x','1x'},{'1x'},...
            {'Evolution Tree','Evolution','Artifact File'},...
            {},...
            1);


            obj.createLabel(6,obj.IncludeInReport)



            obj.IncludeInReportCheckBoxes=obj.createCheckBoxes(7,{'1x'},{'1x','1x'},...
            {'Evolution Tree Summary'},...
            {'Evolution Tree Details'},...
            1);


            obj.LauchReportCheckBox=obj.createCheckBoxes(8,{'1x'},{'1x'},...
            {'Launch Report'},...
            {},...
            1);

            obj.createLabel(9,obj.OutputOptionsPrompt);


            obj.FileFormatDropDown=obj.createDropDown(10,{'1x'},{'1x','2x','1x'},...
            obj.FileFormatDropDownLabel,{'zip','pdf','docx'});


            obj.FileNameEditField=obj.createLabelAndEditField(11,...
            obj.FileNameEditFieldLabel,...
            'Untitled');


            obj.createButtons;
        end



        function createLabel(obj,parentRow,labelProp)
            labelPrompt=uilabel(obj.WorkingGrid,'Text',labelProp);
            labelPrompt.Layout.Row=parentRow;
            labelPrompt.FontWeight='bold';
        end

        function editFieldProp=createLabelAndEditField(obj,parentRow,...
            label,...
            defaultInput)

            lblEditFieldGridRow={'1x'};
            lblEditFieldGridCols={'1x','3x'};
            editFieldGrid=uigridlayout...
            (obj.WorkingGrid,'RowHeight',lblEditFieldGridRow,'ColumnWidth',lblEditFieldGridCols);

            editFieldGrid.Layout.Row=parentRow;


            labelObj=uilabel(editFieldGrid,'Text',label);
            labelObj.Layout.Row=1;
            labelObj.Layout.Column=1;


            editFieldObj=uieditfield(editFieldGrid,'Editable','on',...
            'BackgroundColor','white');
            editFieldObj.Layout.Row=1;
            editFieldObj.Layout.Column=2;
            editFieldObj.Value=defaultInput;
            editFieldProp=editFieldObj;
        end


        function DropDownProp=createDropDown(obj,parentRow,dropDownGridRow,dropDownGridCol,DropDownLabel,DropDownItemsCell)

            dropDownGrid=uigridlayout...
            (obj.WorkingGrid,'RowHeight',dropDownGridRow,'ColumnWidth',dropDownGridCol);

            dropDownGrid.Layout.Row=parentRow;


            dsgnTrDropDownLabel=uilabel(dropDownGrid,'Text',DropDownLabel);
            dsgnTrDropDownLabel.Layout.Column=1;


            dsgnTrDropDownInput=uidropdown(dropDownGrid,'Items',DropDownItemsCell);
            dsgnTrDropDownInput.Layout.Column=2;

            DropDownProp=dsgnTrDropDownInput;


        end


        function checkBoxProp=createCheckBoxes(obj,parentRow,childRowCell,childColCell,...
            checkBoxNamesInCol1,...
            checkBoxNamesInCol2,...
            chBxdefaultValue)

            chBxGrid=uigridlayout...
            (obj.WorkingGrid,'RowHeight',childRowCell,'ColumnWidth',childColCell);

            chBxGrid.Layout.Row=parentRow;


            checkBoxProp=cell(numel(childRowCell),numel(childColCell));
            for i=1:numel(checkBoxNamesInCol1)
                checkBoxProp{i,1}=uicheckbox(chBxGrid,'Text',checkBoxNamesInCol1{i},'Value',chBxdefaultValue);
                checkBoxProp{i,1}.Layout.Row=i;checkBoxProp{i,1}.Layout.Column=1;
            end
            for i=1:numel(checkBoxNamesInCol2)
                checkBoxProp{i,2}=uicheckbox(chBxGrid,'Text',checkBoxNamesInCol2{i},'Value',chBxdefaultValue);
                checkBoxProp{i,2}.Layout.Row=i;checkBoxProp{i,2}.Layout.Column=2;
            end


        end

        function createButtons(obj)
            btnGridRow={'1x'};
            btnGridCols={'2x','1x','1x'};
            btnGrid=uigridlayout...
            (obj.WorkingGrid,'RowHeight',btnGridRow,'ColumnWidth',btnGridCols);
            btnGrid.Layout.Row=numel(obj.WorkingGridRows);
            createBtn=uibutton(btnGrid,'Text','Create');
            createBtn.Layout.Column=2;

            cancelBtn=uibutton(btnGrid,'Text','Cancel');
            cancelBtn.Layout.Column=3;
            obj.CreateBtn=createBtn;
            obj.CancelBtn=cancelBtn;
        end
    end
end
