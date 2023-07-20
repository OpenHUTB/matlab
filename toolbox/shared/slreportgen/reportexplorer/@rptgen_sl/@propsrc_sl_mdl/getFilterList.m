function fList=getFilterList(h)





    fList={
    'main',getString(message('RptgenSL:rsl_propsrc_sl_mdl:mainPropertiesLabel'))
    'all',getString(message('RptgenSL:rsl_propsrc_sl_mdl:allPropertiesLabel'))
    'version',getString(message('RptgenSL:rsl_propsrc_sl_mdl:versionHistoryPropertiesLabel'))
    'fcn',getString(message('RptgenSL:rsl_propsrc_sl_mdl:functionPropertiesLabel'))
    'sim',getString(message('RptgenSL:rsl_propsrc_sl_mdl:simulationPropertiesLabel'))
    'ext',getString(message('RptgenSL:rsl_propsrc_sl_mdl:extModeLabel'))
    'paper',getString(message('RptgenSL:rsl_propsrc_sl_mdl:printPropertiesLabel'))
    };

    if strcmp(get_param(0,'rtwlicensed'),'on');
        fList(end+1:end+2,:)={'rtw','Simulink Coder Properties';
        'rtwsummary','Model Summary (req Simulink Coder)'};
    end
