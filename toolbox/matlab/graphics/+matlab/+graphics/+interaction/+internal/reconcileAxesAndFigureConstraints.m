function style=reconcileAxesAndFigureConstraints(axStyle,figStyle)

    if~isempty(axStyle)&&~strcmpi(axStyle,'unconstrained')
        style=axStyle;

        if strcmp(axStyle,'x')&&strcmpi(figStyle,'y')||...
            strcmp(axStyle,'y')&&strcmpi(figStyle,'x')
            style='unconstrained';
        end
    else
        style=figStyle;
    end