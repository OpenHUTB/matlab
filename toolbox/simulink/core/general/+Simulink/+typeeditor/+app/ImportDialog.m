classdef ImportDialog<handle




    properties(Constant,Hidden,Access=private)
        ImportDialogTag='BusEditorImportDialog'
        ImportTextTag=[Simulink.typeeditor.app.ImportDialog.ImportDialogTag,'_textwidget']
        ImportImageTag=[Simulink.typeeditor.app.ImportDialog.ImportDialogTag,'_imagewidget']
        ImportCheckboxTag=[Simulink.typeeditor.app.ImportDialog.ImportDialogTag,'_checkboxwidget']
        ImportYesButtonTag=[Simulink.typeeditor.app.ImportDialog.ImportDialogTag,'_YesButton']
        ImportNoButtonTag=[Simulink.typeeditor.app.ImportDialog.ImportDialogTag,'_NoButton']
    end

    properties(Access=private,Hidden)
        ButtonSelection char
        ShowAgain logical=true
        Scope char
Dialog
    end

    methods(Static,Hidden,Access=?Simulink.typeeditor.app.Editor)
        function instance=getInstance
            persistent obj;
            if isempty(obj)||~isvalid(obj)
                obj=Simulink.typeeditor.app.ImportDialog;
            end
            instance=obj;
        end
    end

    methods(Hidden)
        function[sel,showAgain]=questdlg(this,scopeName)
            if this.ShowAgain
                this.Scope=scopeName;
                this.Dialog=DAStudio.Dialog(this,'TypeEditorQuestionDialog','DLG_STANDALONE');

                screenRes=get(0,'ScreenSize');
                dialogPosML=get(0,'DefaultFigurePosition');
                dialogPosML(4)=70;
                this.Dialog.position(2)=screenRes(4)-(dialogPosML(2)+dialogPosML(4));
                this.Dialog.setFocus(this.ImportNoButtonTag);

                waitfor(this.Dialog,'dialogTag','');
            end
            sel=this.ButtonSelection;
            showAgain=this.ShowAgain;
        end

        function dlgStruct=getDialogSchema(this,~)
            image.Type='image';
            image.Tag=this.ImportImageTag;
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','question.png');

            questWidget.Type='text';
            questWidget.Name=DAStudio.message('Simulink:busEditor:CustomImportOverwriteWarningMsg',this.Scope);
            questWidget.Tag=this.ImportTextTag;
            questWidget.RowSpan=[1,1];
            questWidget.ColSpan=[2,3];
            questWidget.Alignment=5;
            questWidget.WordWrap=true;
            questWidget.MinimumSize=[300,50];

            doNotShowWidget.Type='checkbox';
            doNotShowWidget.Name=DAStudio.message('Simulink:busEditor:ImportDialogDoNotShowAgain');
            doNotShowWidget.Tag=this.ImportCheckboxTag;
            doNotShowWidget.RowSpan=[3,3];
            doNotShowWidget.ColSpan=[3,3];
            doNotShowWidget.Alignment=7;
            doNotShowWidget.ObjectMethod='selectionCB';
            doNotShowWidget.MethodArgs={'%dialog',doNotShowWidget.Tag};
            doNotShowWidget.ArgDataTypes={'handle','string'};

            yesButton.Type='pushbutton';
            yesButton.Name=DAStudio.message('Simulink:busEditor:YesText');
            yesButton.Tag=this.ImportYesButtonTag;
            yesButton.RowSpan=[1,1];
            yesButton.ColSpan=[1,1];
            yesButton.ObjectMethod='selectionCB';
            yesButton.MethodArgs={'%dialog',yesButton.Tag};
            yesButton.ArgDataTypes={'handle','string'};

            noButton.Type='pushbutton';
            noButton.Name=DAStudio.message('Simulink:busEditor:NoText');
            noButton.Tag=this.ImportNoButtonTag;
            noButton.RowSpan=[1,1];
            noButton.ColSpan=[2,2];
            noButton.ObjectMethod='selectionCB';
            noButton.MethodArgs={'%dialog',noButton.Tag};
            noButton.ArgDataTypes={'handle','string'};

            buttonGroup.Type='panel';
            buttonGroup.LayoutGrid=[1,2];
            buttonGroup.Items={yesButton,noButton};
            buttonGroup.RowSpan=[3,3];
            buttonGroup.ColSpan=[1,2];
            buttonGroup.Alignment=6;

            spacer.Type='panel';
            spacer.RowSpan=[2,2];
            spacer.ColSpan=[1,3];

            dlgStruct.LayoutGrid=[3,3];
            dlgStruct.Items={image,questWidget,spacer,buttonGroup,doNotShowWidget};
            dlgStruct.RowStretch=[0,1,0];
            dlgStruct.ColStretch=[0,1,0];
            dlgStruct.DialogTitle=DAStudio.message('Simulink:busEditor:CustomImportOverwriteWarningText');
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.DialogTag=this.ImportDialogTag;
            dlgStruct.Sticky=true;
            dlgStruct.ContentsMargins=10;
            dlgStruct.IsScrollable=false;
        end

        function selectionCB(this,~,tag)
            switch tag
            case this.ImportCheckboxTag
                this.ShowAgain=~this.ShowAgain;
                return;
            case this.ImportYesButtonTag
                sel=DAStudio.message('Simulink:busEditor:YesText');
            case this.ImportNoButtonTag
                sel=DAStudio.message('Simulink:busEditor:NoText');
            end
            this.ButtonSelection=sel;
            this.Dialog.delete;
        end
    end

    methods(Access=private)
        function this=ImportDialog
        end
    end
end