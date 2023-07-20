function fList=getFilterList(h)





    fList={
    'main',getString(message('RptgenSL:rsl_propsrc_sl_sys:mainProperties'))
    'mask',getString(message('RptgenSL:rsl_propsrc_sl_sys:maskProperties'))
    'paper',getString(message('RptgenSL:rsl_propsrc_sl_sys:printProperties'))
    'fcn',getString(message('RptgenSL:rsl_propsrc_sl_sys:fcnProperties'))
    'all',getString(message('RptgenSL:rsl_propsrc_sl_sys:allProperties'))
    };