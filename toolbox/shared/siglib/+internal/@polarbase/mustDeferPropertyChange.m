function y=mustDeferPropertyChange(p,propName)





    y=~p.pPlotExecutedAtLeastOnce;
    if y
        warning('polari:DeferredPropertySetting',...
        'Cannot change ''%s'' property until plot is created.',propName);
    end
