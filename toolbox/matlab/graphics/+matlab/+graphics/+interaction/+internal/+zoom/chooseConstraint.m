function[cons,cursor]=chooseConstraint(hAx,modeConstraint,behaviorConstraint)
    fig=ancestor(hAx,'figure');

    if is2D(hAx)

        xymodeConstraint=horizontalVerticalToXY(modeConstraint);
        cons=matlab.graphics.interaction.internal.reconcileAxesAndFigureConstraints(behaviorConstraint,xymodeConstraint);
    elseif~strcmp(matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(fig,hAx),'limits')
        cons='unconstrained';
    else
        if isempty(behaviorConstraint)
            cons='unconstrained';
        else
            cons=behaviorConstraint;
        end
    end

    cursor=cons;

    function con=horizontalVerticalToXY(str)
        switch str
        case 'horizontal'
            con='x';
        case 'vertical'
            con='y';
        case 'none'
            con='unconstrained';
        otherwise
            con=str;
        end