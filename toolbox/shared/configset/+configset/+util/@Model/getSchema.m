function schema=getSchema(h)



    height=16;
    l=[16,210,25,160,180,25,25];
    ali=5;
    col=0;

    schema.Type='panel';
    schema.Tag=strcat('a_',h.Name);
    schema.Flat=true;
    schema.LayoutGrid=[3,7];
    schema.ColStretch=[0,6,1,3,5,1,1];
    schema.BackgroundColor=255*[1,1,1];

    ck.Type='checkbox';
    ck.Value=h.IsSelected;
    ck.Tag=strcat('c_',h.Name);
    ck.Graphical=true;
    ck.ObjectMethod='selectModel';
    ck.MethodArgs={'%tag','%value'};
    ck.ArgDataTypes={'string','logical'};
    ck.RowSpan=[2,2];
    col=col+1;
    ck.ColSpan=[col,col];

    ck.Alignment=5;

    mdl.Type='hyperlink';
    if length(h.Name)<25
        mdl.Name=h.Name;
    else
        mdl.Name=strcat(h.Name(1:22),'...');
    end
    mdl.ToolTip=which(h.Name);
    mdl.Tag=strcat('m_',h.Name);
    mdl.ObjectMethod='showModel';
    mdl.MethodArgs={'%tag'};
    mdl.ArgDataTypes={'string'};
    mdl.RowSpan=[2,2];
    mdl.BackgroundColor=128*[1,1,1];
    col=col+1;
    mdl.ColSpan=[col,col];

    mdl.Alignment=5;

    pc.Type='image';
    pc.Tag=strcat('pc',h.Name);
    pc.Visible=strcmp(h.Status,'Converted');

    pc.FilePath=fullfile(matlabroot,'toolbox','shared','configset','resources','Converted_16.png');
    pc.RowSpan=[2,2];
    col=col+1;
    pc.ColSpan=[col,col];

    pc.Alignment=7;

    ps.Type='image';
    ps.Tag=strcat('ps',h.Name);
    ps.Visible=strcmp(h.Status,'Skipped')||strcmp(h.Status,'Restored')||strcmp(h.Status,'Initial');
    ps.FilePath=fullfile(matlabroot,'toolbox1','shared','dastudio','resources','Default.gif');
    ps.RowSpan=[2,2];

    ps.ColSpan=[col,col];

    ps.Alignment=7;

    pf.Type='image';
    pf.Tag=strcat('pf',h.Name);
    pf.Visible=strcmp(h.Status,'Failed');

    pf.FilePath=fullfile(matlabroot,'toolbox','shared','configset','resources','Failed_16.png');
    pf.RowSpan=[2,2];

    pf.ColSpan=[col,col];

    pf.Alignment=7;

    pp.Type='image';
    pp.Tag=strcat('pp',h.Name);
    pp.Visible=false;
    pp.FilePath=fullfile(matlabroot,'toolbox1','shared','dastudio','resources','ConfigurationComponent.png');
    pp.RowSpan=[2,2];

    pp.ColSpan=[col,col];

    pp.Alignment=7;

    pw.Type='image';
    pw.Tag=strcat('pw',h.Name);
    pw.Visible=false;
    pw.FilePath=fullfile(matlabroot,'toolbox1','shared','dastudio','resources','append_row.gif');
    pw.RowSpan=[2,2];

    pw.ColSpan=[col,col];

    pw.Alignment=7;

    st.Type='text';
    st.Name=h.Status;
    st.Name=DAStudio.message(strcat('configset:util:Status_',h.Status));
    st.Tag=strcat('s_',h.Name);
    st.RowSpan=[2,2];

    col=col+1;
    st.ColSpan=[col,col];

    st.Alignment=ali;

    d.Type='hyperlink';
    if isempty(h.DiffNum)
        d.Name='';
    elseif h.DiffNum==0||h.DiffNum==1
        d.Name=DAStudio.message('configset:util:ShowDiff',h.DiffNum);
    elseif h.DiffNum>=2
        d.Name=DAStudio.message('configset:util:ShowDiffs',h.DiffNum);
    else
        d.Name='';
    end
    d.Tag=strcat('d_',h.Name);
    d.ToolTip=DAStudio.message('configset:util:ShowDiffToolTip');
    d.Visible=strcmp(h.Status,'Converted');
    d.ObjectMethod='showDetail';
    d.MethodArgs={'%tag'};
    d.ArgDataTypes={'string'};
    d.RowSpan=[2,2];
    col=col+1;
    d.ColSpan=[col,col];

    d.Alignment=6;

    u.Type='pushbutton';


    u.FilePath=fullfile(matlabroot,'toolbox','shared','configset','resources','Undo_16.png');
    u.Tag=strcat('u_',h.Name);
    u.Enabled=strcmp(h.Status,'Converted');
    u.ObjectMethod='undoModel';
    u.MethodArgs={'%tag'};
    u.ArgDataTypes={'string'};
    u.RowSpan=[2,2];
    col=col+1;
    u.ColSpan=[col,col];
    u.MaximumSize=[l(col),height];

    u.Alignment=7;

    r.Type='pushbutton';


    r.FilePath=fullfile(matlabroot,'toolbox','shared','configset','resources','Redo_16.png');
    r.Tag=strcat('r_',h.Name);
    r.Enabled=strcmp(h.Status,'Restored');
    r.ObjectMethod='redoModel';
    r.MethodArgs={'%tag'};
    r.ArgDataTypes={'string'};
    r.RowSpan=[2,2];
    col=col+1;
    r.ColSpan=[col,col];
    r.MaximumSize=[l(col),height];

    r.Alignment=ali;

    err.Type='hyperlink';
    err.Name=DAStudio.message('configset:util:ErrorMessage');
    err.ToolTip=DAStudio.message('configset:util:ErrorToolTip');
    err.Tag=strcat('e_',h.Name);
    err.RowSpan=[2,2];
    err.ColSpan=[5,5];
    err.ObjectMethod='showError';
    err.MethodArgs={'%tag'};
    err.ArgDataTypes={'string'};

    err.Visible=false;
    err.Alignment=6;

    notResolve.Type='text';
    notResolve.Name=DAStudio.message('configset:util:NotResolved');
    notResolve.ToolTip=DAStudio.message('configset:util:NotResolvedToolTip');
    notResolve.Tag=strcat('nr',h.Name);
    notResolve.ForegroundColor=[255,0,0];
    notResolve.RowSpan=[2,2];
    notResolve.ColSpan=[5,5];
    if~isempty(h.DiffNum)
        notResolve.Visible=isnan(h.DiffNum)&&strcmp(h.Status,'Converted');
    else
        notResolve.Visible=false;
    end
    notResolve.Alignment=6;

    schema.Items={ck,mdl,pc,ps,pf,pp,pw,st,d,err,notResolve,u,r};
