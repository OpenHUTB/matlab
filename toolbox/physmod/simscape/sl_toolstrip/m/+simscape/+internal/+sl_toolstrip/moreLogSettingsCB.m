function moreLogSettingsCB(cbinfo,~)





    configset=getActiveConfigSet(cbinfo.model.Name);
    slCfgPrmDlg(configset,'Open','Simscape');

end