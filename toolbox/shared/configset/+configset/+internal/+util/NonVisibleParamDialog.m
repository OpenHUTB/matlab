classdef NonVisibleParamDialog<handle






    properties
paramName
paramPrompt
configSet
warnMessage
parentDlg
    end

    methods
        function h=NonVisibleParamDialog(cs,param,prompt,message)
            h.paramName=param;
            h.paramPrompt=prompt;
            h.configSet=cs;
            h.parentDlg=cs.getDialogHandle;
            h.warnMessage=message;
        end

        function dlg=getDialogSchema(hSrc)
            dlg=[];

            tag='Tag_NonVisibleParamDialog_';


            widget=[];
            widget.Name=message(hSrc.warnMessage,hSrc.paramPrompt).getString;
            widget.Type='text';
            widget.Tag=[tag,'Message'];
            widget.WordWrap=true;
            widget.RowSpan=[1,1];
            widget.ColSpan=[1,1];
            widget.MinimumSize=[350,10];
            msg=widget;

            widget=[];
            widget.Name=message('Simulink:dialog:ListViewHighlightHyperlink',hSrc.paramPrompt).getString;
            widget.Type='hyperlink';
            widget.Tag=[tag,'Hyperlink'];
            widget.ObjectMethod='highlightListViewParam';
            widget.MethodArgs={'%dialog'};
            widget.ArgDataTypes={'handle'};
            widget.RowSpan=[2,2];
            widget.ColSpan=[1,1];
            link=widget;

            cancelButton.Name=message('MATLAB:uistring:popupdialogs:Cancel').getString;
            cancelButton.Type='pushbutton';
            cancelButton.ObjectMethod='closeHighlightWarningDialog';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.MaximumSize=[75,25];
            cancelButton.Alignment=9;

            panel=[];
            panel.Type='panel';
            panel.Items={msg,link,cancelButton};
            panel.BackgroundColor=get(0,'DefaultUicontrolBackgroundColor')*255;
            panel.LayoutGrid=[2,1];

            dlg.DialogTitle=message('Simulink:dialog:ListViewOnly').getString;
            dlg.DisplayIcon='toolbox/shared/dastudio/resources/indicators/sign_warning.png';
            dlg.Items={panel};


            dlg.StandaloneButtonSet={''};

        end

        function highlightListViewParam(hSrc,dlg)
            dlg.delete;

            if~isempty(hSrc.parentDlg)&&isa(hSrc.parentDlg,'DAStudio.Dialog')
                configset.highlightParameter(hSrc.configSet,hSrc.paramName,'default','List');
            end
        end

        function closeHighlightWarningDialog(~,dlg)
            dlg.delete;
        end
    end

end