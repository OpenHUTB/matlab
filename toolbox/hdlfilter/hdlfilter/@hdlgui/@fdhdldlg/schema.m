function schema








    mlock;

    pk=findpackage('hdlgui');
    c=schema.class(pk,'fdhdldlg',findclass(findpackage('siggui'),'actionclosedlg'));

    p=schema.prop(c,'hHdl','mxArray');
    set(p,'Visible','off');

    p=schema.prop(c,'hHdlDlg','mxArray');
    set(p,'Visible','off');


