function ps=pt_getPropertySource(c)








    switch lower(c.ObjectType)
    case 'system'
        ps=rptgen_sl.propsrc_sl_sys;
    case 'model'
        ps=rptgen_sl.propsrc_sl_mdl;
    case 'signal'
        ps=rptgen_sl.propsrc_sl_sig;
    case 'block'
        ps=rptgen_sl.propsrc_sl_blk;
    case 'annotation'
        ps=rptgen_sl.propsrc_sl_annotation;
    case 'configset'
        ps=rptgen_sl.propsrc_sl_configset;
    otherwise
        error(message(RptgenSL:rsl_csl_prop_table:invalidObjectTypeError,c.ObjectType))
    end
