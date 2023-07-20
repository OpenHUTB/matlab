function fcncallobj_open_cb(dlg)

    source=dlg.getSource;


    newCache.Dialog=dlg;
    newCache.ArgType='input';
    newCache.ArgIdx=1;
    newCache.Arg=source.Arguments(1);
    newCache.ObjID=source.getUUID;


    slInternal('FcnCallEditorCache',newCache);
    fcncallobj_argSel_cb('obj_in_arg_sel_tag',dlg,source);