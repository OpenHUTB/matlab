function DeselectLinesAndChildren(line)
    set_param(line,'Selected','off');
    children=get_param(line,'LineChildren');
    if iscell(children)
        children=[children{:}]';
    end
    for j=1:length(children)
        Simulink.scopes.Util.DeselectLinesAndChildren(children(j));
    end
end
