function dName=getDisplayName(~)






    model=get(rptgen_sl.appdata_sl,'CurrentModel');
    if~isempty(model)
        dName=[get_param(model,'Name'),' ',rptgen_sl.csl_cfgset.msg('CfgSetTitle')];
    else
        dName='';
    end