function btn=addUnlockLibraryButton(dlgSrc,row,col)
    btn.Name=DAStudio.message('Simulink:CodeContext:UnlockLibrary');
    btn.Type='pushbutton';
    btn.Tag='CodeContextUnlockLibraryButton';
    btn.Visible=strcmpi(get_param(dlgSrc.mdlH,'lock'),'on');
    btn.RowSpan=[row,row];
    btn.ColSpan=[col,col];
    btn.Alignment=1;
    btn.ObjectMethod='unlocklibrary_cb';
    btn.MethodArgs={'%dialog'};
    btn.ArgDataTypes={'handle'};

end

