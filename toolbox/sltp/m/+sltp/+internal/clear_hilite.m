function clear_hilite(mdl)

    mdlName=get_param(mdl,'Name');

    legend=Simulink.SampleTimeLegend;
    legend.clearHilite(mdlName);

end
