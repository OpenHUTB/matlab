function limits=calculateOrigLimits(ax)





    [xlimit,ylimit,zlimit]=matlab.graphics.interaction.internal.getFiniteLimits(ax);
    limits=[xlimit,ylimit,zlimit];



    if isa(ax.XRuler,'matlab.graphics.axis.decorator.CategoricalRuler')
        limits(1:2)=[-inf,inf];
    end
    if isa(ax.YRuler,'matlab.graphics.axis.decorator.CategoricalRuler')
        limits(3:4)=[-inf,inf];
    end
    if isa(ax.ZRuler,'matlab.graphics.axis.decorator.CategoricalRuler')
        limits(5:6)=[-inf,inf];
    end
