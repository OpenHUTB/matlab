function dlg=errorDlg(err)






    dlg.DialogTitle=[message('RTW:configSet:titleCp').getString,' ',message('RTW:configSet:titleStrError').getString];
    widget1.Name=message('RTW:configSet:exceptionOccurredMsg').getString;
    widget2.Name=['    ',err.message];
    widget3.Name=['    file: ',err.stack(1).file];
    widget4.Name=['    name: ',err.stack(1).name];
    widget5.Name=['    line: ',num2str(err.stack(1).line)];
    widget1.Type='text';
    widget2.Type='text';
    widget3.Type='text';
    widget4.Type='text';
    widget5.Type='text';
    widget1.WordWrap=true;
    widget2.WordWrap=true;
    widget3.WordWrap=true;
    widget6.Name=' ';
    widget6.Type='text';
    dlg.Items={widget1,widget2,widget3,widget4,widget5,widget6};
    dlg.LayoutGrid=[7,1];
    dlg.RowStretch=[0,0,0,0,0,0,1];
    dlg.HelpMethod='ERROR';
    dlg.StandaloneButtonSet={'OK'};
    dlg.EmbeddedButtonSet={''};

