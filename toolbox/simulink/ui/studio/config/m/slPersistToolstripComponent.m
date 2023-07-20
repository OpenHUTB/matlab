function slPersistToolstripComponent(compname,persist)





    if persist
        dig.config.rememberComponent('sl_toolstrip_plugins',compname);
    else
        dig.config.forgetComponent('sl_toolstrip_plugins',compname);
    end
end