function defaultTypeInfo=summ_getDefaultTypeInfo(typeID)%#ok









    defaultTypeInfo=rptgen_sl.summsrc_sl_blk(...
    'fixed-point block',...
    rptgen_fp.propsrc_fp_blk,...
    rptgen_fp.cfp_blk_loop,...
    {'Name','Parent','%<SplitDialogParameters>'},...
    true);

