function linearizeBlockAsGain(blk)


    open_system(blk);



    bobj=get_param(blk,'Object');

    open_system(blk);


    src=bobj.getDialogSource;


    tr=DAStudio.ToolRoot;

    dlg=tr.getOpenDialogs(src);

    enableWidgetHighlight(dlg,...
    'Treat as gain when linearizing',...
    [255,0,0]);



