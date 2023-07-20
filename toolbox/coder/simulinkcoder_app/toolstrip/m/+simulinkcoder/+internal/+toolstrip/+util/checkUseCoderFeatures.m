function checkUseCoderFeatures(cbinfo,feature)




    cs=getActiveConfigSet(cbinfo.model);
    if isa(cs,'Simulink.ConfigSetRef')
        cs.refresh;
    end
    if~strcmp(cs.get_param(feature),'on')
        DAStudio.error('SimulinkCoderApp:toolstrip:featureIsNotTurnedOn',feature);
    end

end

