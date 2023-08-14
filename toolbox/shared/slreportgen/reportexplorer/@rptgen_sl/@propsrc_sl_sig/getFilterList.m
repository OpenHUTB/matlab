function fList=getFilterList(h)





    fList={
    'all',getString(message('RptgenSL:rsl_propsrc_sl_sig:allPropertiesLabel'))
    'main',getString(message('RptgenSL:rsl_propsrc_sl_sig:mainPropertiesLabel'))
    'display',getString(message('RptgenSL:rsl_propsrc_sl_sig:displayPropertiesLabel'))
    'other',getString(message('RptgenSL:rsl_propsrc_sl_sig:otherPropertiesLabel'))
    'object',getString(message('RptgenSL:rsl_propsrc_sl_sig:dataPropertiesLabel'))
    };