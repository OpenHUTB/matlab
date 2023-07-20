function dlgstruct=stringtypeddg(h,name)








    maxLength.Name=DAStudio.message('Simulink:StringBlocks:MaxNumCharacters');
    maxLength.RowSpan=[1,1];
    maxLength.ColSpan=[1,2];
    maxLength.Type='edit';
    maxLength.Tag='maxLength_tag';
    maxLength.ObjectProperty='MaximumLength';

    spacer.Type='panel';
    spacer.RowSpan=[2,2];

    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.Items={maxLength,spacer};
    dlgstruct.LayoutGrid=[2,2];
    dlgstruct.ColStretch=[0,1];
    dlgstruct.RowStretch=[0,1];


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={'simulink','stringtype'};

end