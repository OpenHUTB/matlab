function dlgstruct=getDialogSchema(~,~)







    label.Type='text';
    label.Name=DAStudio.message('Simulink:prefs:SelectListEntry');
    label.RowSpan=[1,1];
    label.ColSpan=[1,1];

    hlink.Type='hyperlink';
    hlink.Name=DAStudio.message('Simulink:prefs:MATLABPreferences');
    hlink.MatlabMethod='preferences';
    hlink.RowSpan=[3,3];
    hlink.ColSpan=[1,1];

    dlgstruct.DialogTitle=DAStudio.message('Simulink:prefs:PreferencesTitle');

    dlgstruct.LayoutGrid=[3,1];
    dlgstruct.RowStretch=[0,1,0];
    dlgstruct.Items={label,hlink};

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={'mapkey:Simulink.Preferences','help_button','CSHelpWindow'};

