classdef GetName<evolutions.internal.ui.tools.CustomDialogInterface




    properties(Access=protected)

        Prompt={getString(message('evolutions:ui:NamePrompt'))}

TextInput

OkayBtn
CancelBtn
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

DialogWidth
DialogHeight

WorkingGridRows
WorkingGridCols

    end

    methods(Access=?evolutions.internal.app.dialogs.customdialogs.CustomDialogFactory)
        function obj=GetName(title)

            obj@evolutions.internal.ui.tools.CustomDialogInterface;
            obj.setDialogTitle(title);

        end
    end
    methods

    end

    methods(Access=protected)

        function installCallbacks(obj)

            obj.OkayBtn.ButtonPushedFcn=@obj.okayBtnAction;
            obj.CancelBtn.ButtonPushedFcn=@(~,~)delete(obj.Figure);
            obj.TextInput.ValueChangingFcn=@obj.textValueChanging;
        end

        function okayBtnAction(obj,~,~)
            obj.Output=obj.TextInput.Value;
            delete(obj.Figure);
        end

        function textValueChanging(obj,~,newEntry)

            obj.OkayBtn.Enable=isvarname(newEntry.Value);
        end
    end

    methods(Access=protected)

        function setDialogSize(obj)
            obj.DialogWidth=410;
            obj.DialogHeight=140;
        end

        function setWorkingGridDimensions(obj)
            obj.WorkingGridRows={'1x','1x','2x'};
            obj.WorkingGridCols={'1x'};
        end

        function createDialogComponents(obj)

            obj.createLabel(obj.Prompt);


            obj.createTextBox;


            obj.createButtons;
        end

        function createTextBox(obj)
            defaultInput=char.empty;
            textInput=uieditfield(obj.WorkingGrid,'Editable','on',...
            'BackgroundColor','white');
            textInput.Layout.Row=2;
            textInput.Value=defaultInput;
            obj.TextInput=textInput;
        end

        function createButtons(obj)
            btnGridRow={'1x'};
            btnGridCols={'2x','1x','1x'};
            btnGrid=uigridlayout...
            (obj.WorkingGrid,'RowHeight',btnGridRow,'ColumnWidth',btnGridCols);
            btnGrid.Layout.Row=3;
            okBtn=uibutton(btnGrid,'Text',getString(message('evolutions:ui:Ok')),...
            'Enable','off');
            okBtn.Layout.Column=2;

            cancelBtn=uibutton(btnGrid,'Text',getString(message('evolutions:ui:Cancel')));
            cancelBtn.Layout.Column=3;
            obj.OkayBtn=okBtn;
            obj.CancelBtn=cancelBtn;
        end
    end
end
