function dlgstruct=imagetypeddg(h,name)








    rowIdx=0;






    rowIdx=rowIdx+1;
    rowsLbl.Name=DAStudio.message('Simulink:dialog:ImageTypeRowsPrompt');
    rowsLbl.Type='text';
    rowsLbl.RowSpan=[rowIdx,rowIdx];
    rowsLbl.ColSpan=[1,1];
    rowsLbl.Tag='RowsLbl';

    rows.Name='';
    rows.RowSpan=[rowIdx,rowIdx];
    rows.ColSpan=[2,2];
    rows.Tag='Rows';
    rows.Type='edit';
    rows.ObjectProperty='RowsString';
    rows.Mode=1;
    rows.DialogRefresh=1;
    catVal=h.Rows;






    rowIdx=rowIdx+1;
    colsLbl.Name=DAStudio.message('Simulink:dialog:ImageTypeColsPrompt');
    colsLbl.Type='text';
    colsLbl.RowSpan=[rowIdx,rowIdx];
    colsLbl.ColSpan=[1,1];
    colsLbl.Tag='ColsLbl';

    cols.Name='';
    cols.RowSpan=[rowIdx,rowIdx];
    cols.ColSpan=[2,2];
    cols.Tag='Cols';
    cols.Type='edit';
    cols.ObjectProperty='ColsString';
    cols.Mode=1;
    cols.DialogRefresh=1;
    catVal=h.Cols;






    rowIdx=rowIdx+1;
    channelsLbl.Name=DAStudio.message('Simulink:dialog:ImageTypeChannelsPrompt');
    channelsLbl.Type='text';
    channelsLbl.RowSpan=[rowIdx,rowIdx];
    channelsLbl.ColSpan=[1,1];
    channelsLbl.Tag='ChannelsLbl';

    channels.Name='';
    channels.RowSpan=[rowIdx,rowIdx];
    channels.ColSpan=[2,2];
    channels.Tag='Channels';
    channels.Type='edit';
    channels.ObjectProperty='ChannelsString';
    channels.Mode=1;
    channels.DialogRefresh=1;
    catVal=h.Channels;






    rowIdx=rowIdx+1;
    classUnderlyingLbl.Name=DAStudio.message('Simulink:dialog:ImageTypeClassUnderlyingPrompt');
    classUnderlyingLbl.Type='text';
    classUnderlyingLbl.RowSpan=[rowIdx,rowIdx];
    classUnderlyingLbl.ColSpan=[1,1];
    classUnderlyingLbl.Tag='ClassUnderlyingLbl';

    classUnderlying.Name='';
    classUnderlying.RowSpan=[rowIdx,rowIdx];
    classUnderlying.ColSpan=[2,2];
    classUnderlying.Tag='ClassUnderlying';
    classUnderlying.Type='combobox';
    classUnderlying.Entries=getPropAllowedValues(h,'ClassUnderlying')';
    classUnderlying.ObjectProperty='ClassUnderlying';
    classUnderlying.Mode=1;
    classUnderlying.DialogRefresh=1;






    rowIdx=rowIdx+1;
    colorFormatLbl.Name=DAStudio.message('Simulink:dialog:ImageTypeColorFormatPrompt');
    colorFormatLbl.Type='text';
    colorFormatLbl.RowSpan=[rowIdx,rowIdx];
    colorFormatLbl.ColSpan=[1,1];
    colorFormatLbl.Tag='ColorFormatLbl';

    colorFormat.Name='';
    colorFormat.RowSpan=[rowIdx,rowIdx];
    colorFormat.ColSpan=[2,2];
    colorFormat.Tag='ColorFormat';
    colorFormat.Type='combobox';
    colorFormat.Entries=getPropAllowedValues(h,'ColorFormat')';
    colorFormat.ObjectProperty='ColorFormat';
    colorFormat.Mode=1;
    colorFormat.DialogRefresh=1;






    rowIdx=rowIdx+1;
    layoutLbl.Name=DAStudio.message('Simulink:dialog:ImageTypeLayoutPrompt');
    layoutLbl.Type='text';
    layoutLbl.RowSpan=[rowIdx,rowIdx];
    layoutLbl.ColSpan=[1,1];
    layoutLbl.Tag='LayoutLbl';

    layout.Name='';
    layout.RowSpan=[rowIdx,rowIdx];
    layout.ColSpan=[2,2];
    layout.Tag='Layout';
    layout.Type='combobox';
    layout.Entries=getPropAllowedValues(h,'Layout')';
    layout.ObjectProperty='Layout';
    layout.Mode=1;
    layout.DialogRefresh=1;





    dlgstruct.LayoutGrid=[rowIdx+1,2];
    dlgstruct.RowStretch=[zeros(1,rowIdx),1];
    dlgstruct.ColStretch=[0,1];
    dlgstruct.Items={rowsLbl,rows,...
    colsLbl,cols,...
    channelsLbl,channels,...
    classUnderlyingLbl,classUnderlying,...
    colorFormatLbl,colorFormat,...
    layoutLbl,layout};




    dlgstruct.DialogTitle=[class(h),': ',name];


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/vision/vision.map'],'simulink_image_type'};


