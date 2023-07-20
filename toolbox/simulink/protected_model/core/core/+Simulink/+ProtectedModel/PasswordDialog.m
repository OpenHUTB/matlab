classdef(Sealed)PasswordDialog<handle




    properties

        Password{matlab.internal.validation.mustBeASCIICharRowVector(Password,'Password')}=''

        File{matlab.internal.validation.mustBeCharRowVector(File,'File')}=''
    end

    properties(Access=private)
        Tag='Tag_Simulink_ProtectedModel_PasswordDialog_'
        WidgetId='Simulink.ProtectedModel.PasswordDialog.'
    end

    methods
        function obj=PasswordDialog(aFile)
            obj.File=aFile;
        end

        function dlg=getDialogSchema(obj)



            [~,file,ext]=fileparts(obj.File);
            file=[file,ext];


            widget=[];
            widget.Type='text';
            widget.Tag=[obj.Tag,'Description'];
            widget.WidgetId=[obj.WidgetId,'Description'];
            widget.Name=getString(message('Simulink:protectedModel:PasswordDialogDescriptionCertificate',file));
            widget.Visible=~isempty(obj.File);
            description=widget;


            widget=[];
            widget.Type='edit';
            widget.Tag=[obj.Tag,'Password'];
            widget.WidgetId=[obj.WidgetId,'Password'];
            widget.Name=getString(message('Simulink:protectedModel:PasswordDialogPassword'));
            widget.Mode=true;
            widget.EchoMode='password';
            widget.ObjectProperty='Password';
            password=widget;


            dlg.DialogTitle=getString(message('Simulink:protectedModel:PasswordDialogTitle'));
            dlg.DialogTag=[obj.Tag,'dialog'];
            dlg.Items={description,password};
            dlg.StandaloneButtonSet={'OK','Cancel'};
            dlg.Sticky=true;
        end

        function openDialog(obj)

            dlg=DAStudio.Dialog(obj);

            dlg.setFocus([obj.Tag,'Password']);
            waitfor(dlg);
        end
    end

    methods(Static)
        function out=getPassword(aFile)


            dialog=Simulink.ProtectedModel.PasswordDialog(aFile);
            dialog.openDialog;
            out=dialog.Password;
        end
    end
end


