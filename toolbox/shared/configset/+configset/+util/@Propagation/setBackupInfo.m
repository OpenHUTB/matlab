function out=setBackupInfo(h)



    text.Type='text';
    text.Name=h.setBackupStr();
    text.Tag='BackupInfo';
    text.RowSpan=[1,1];
    text.ColSpan=[1,6];

    pan.Type='panel';
    pan.LayoutGrid=[2,7];

    st=h.stats();
    col=0;

    col=col+1;
    t.Type='text';
    t.Tag='Total';
    t.Bold=true;
    t.ToolTip=DAStudio.message('configset:util:PropagateReportTotal');
    t.Name=[DAStudio.message('configset:util:Status_Total'),': ',num2str(st.t),'    '];
    t.ColSpan=[col,col];
    t.RowSpan=[2,2];

    col=col+1;
    c.Type='checkbox';
    c.Tag='Converted';
    c.ToolTip=DAStudio.message('configset:util:PropagateReportConverted');
    c.Name=[DAStudio.message('configset:util:Status_Converted'),': ',num2str(st.c),'  '];
    c.ObjectProperty='IsConvertedChecked';
    c.ObjectMethod='setDlg';
    c.ColSpan=[col,col];
    c.RowSpan=[2,2];
    c.Mode=true;
    c.Graphical=true;

    col=col+1;
    r.Type='checkbox';
    r.Tag='Restored';
    r.ToolTip=DAStudio.message('configset:util:PropagateReportRestored');
    r.Name=[DAStudio.message('configset:util:Status_Restored'),': ',num2str(st.r),'  '];
    r.ObjectProperty='IsRestoredChecked';
    r.ObjectMethod='setDlg';
    r.ColSpan=[col,col];
    r.RowSpan=[2,2];
    r.Mode=true;
    r.Graphical=true;

    col=col+1;
    s.Type='checkbox';
    s.Tag='Skipped';
    s.ToolTip=DAStudio.message('configset:util:PropagateReportSkipped');
    s.Name=[DAStudio.message('configset:util:Status_Skipped'),': ',num2str(st.s),'  '];
    s.ObjectProperty='IsSkippedChecked';
    s.ObjectMethod='setDlg';
    s.ColSpan=[col,col];
    s.RowSpan=[2,2];
    s.Mode=true;
    s.Graphical=true;

    col=col+1;
    f.Type='checkbox';
    f.Tag='Failed';
    f.ToolTip=DAStudio.message('configset:util:PropagateReportFailed');
    f.Name=[DAStudio.message('configset:util:Status_Failed'),': ',num2str(st.f),'  '];
    f.ObjectProperty='IsFailedChecked';
    f.ObjectMethod='setDlg';
    f.ColSpan=[col,col];
    f.RowSpan=[2,2];
    f.Mode=true;
    f.Graphical=true;

    col=col+1;
    searchInput.Type='edit';
    searchInput.Tag='searchInput';
    searchInput.RespondsToTextChanged=1;
    searchInput.Graphical=true;
    searchInput.ToolTip=DAStudio.message('configset:util:SearchText');
    searchInput.PlaceholderText=DAStudio.message('configset:util:SearchText');
    searchInput.Clearable=true;
    searchInput.ObjectMethod='setDlg';
    searchInput.RowSpan=[2,2];
    searchInput.ColSpan=[col,col];


    pan.Items={t,c,r,s,f,searchInput};



    infoPan.Type='panel';
    infoPan.LayoutGrid=[1,2];
    infoPan.ColStretch=[1,0];
    infoPan.Items={text};


    out.Type='group';
    out.Name=DAStudio.message('configset:util:PropagationReport');
    out.Items={infoPan,pan};
