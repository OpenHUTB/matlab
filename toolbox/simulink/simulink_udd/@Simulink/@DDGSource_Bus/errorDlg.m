function dlgStruct=errorDlg(~,h,msg)




    txt.Name=['Error occurred when trying to create dialog',sprintf('\n'),msg];
    txt.Type='text';
    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',...
    strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.Items={txt};
    dlgStruct.CloseMethod='CloseCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};
end
