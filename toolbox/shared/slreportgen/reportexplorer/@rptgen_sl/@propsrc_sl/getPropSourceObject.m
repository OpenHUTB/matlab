function pso=getPropSourceObject(this,objType)%#ok












    switch lower(objType)
    case{'model','mdl'}
        pso=rptgen_sl.propsrc_sl_mdl();

    case{'system','sys'}
        pso=rptgen_sl.propsrc_sl_sys();

    case{'signal','sig'}
        pso=rptgen_sl.propsrc_sl_sig();

    case{'block','blk'}
        pso=rptgen_sl.propsrc_sl_blk();

    case{'annotation','anno'}
        pso=rptgen_sl.propsrc_sl_annotation();

    case{'workspacevar','simulink workspace variable'}
        pso=rptgen_sl.propsrc_sl_ws_var();

    otherwise
        error(message('Simulink:rptgen_sl:UndefinedObjectType'));
    end
