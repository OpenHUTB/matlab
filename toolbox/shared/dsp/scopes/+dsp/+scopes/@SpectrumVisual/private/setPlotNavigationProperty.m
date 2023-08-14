function setPlotNavigationProperty(~,hPlotNav,pns,prop,defaultValue)




    if isfield(pns,prop)
        setPropertyValue(hPlotNav,prop,pns.(prop));
    else
        setPropertyValue(hPlotNav,prop,defaultValue);
    end

end
