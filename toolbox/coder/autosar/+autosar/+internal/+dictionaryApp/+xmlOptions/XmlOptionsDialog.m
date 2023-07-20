classdef XmlOptionsDialog<handle




    properties(GetAccess=private,SetAccess=immutable)
        M3IRoot Simulink.metamodel.arplatform.common.AUTOSAR;
        DictName;
    end

    properties(Access=private)
        DialogH;
    end

    methods(Static,Access=public)
        function xmlOptionsDialog=launchDialog(m3iModel,slddFilePath)

            xmlOptionsDialog=...
            autosar.internal.dictionaryApp.xmlOptions.XmlOptionsDialog(...
            m3iModel,slddFilePath);
        end

        function closeCB(xmlOptionsDialog)

            xmlOptionsDialog.DialogH=[];
        end
    end

    methods(Access=private)
        function this=XmlOptionsDialog(m3iModel,slddFilePath)
            this.M3IRoot=m3iModel.RootPackage.front();
            [~,name,ext]=fileparts(slddFilePath);
            this.DictName=[name,ext];
            this.DialogH=DAStudio.Dialog(this);
            this.show();
        end
    end

    methods(Access=public)
        function dlgStruct=getDialogSchema(this)

            dlgStruct=autosar.ui.utils.getPreferencesDlg(this.M3IRoot,IsDlgForInterfaceEditor=true);

            dlgStruct.DialogTitle=[dlgStruct.DialogTitle,': ',this.DictName];

            dlgStruct.CloseCallback='autosar.internal.dictionaryApp.xmlOptions.XmlOptionsDialog.closeCB';
            dlgStruct.CloseArgs={this};
            dlgStruct.IsScrollable=true;
        end

        function show(this)
            this.DialogH.show();
        end

        function isValid=dialogIsValid(this)
            isValid=~isempty(this.DialogH);
        end

        function close(this)
            if this.dialogIsValid()
                this.DialogH.delete();
            end
        end
    end
end
