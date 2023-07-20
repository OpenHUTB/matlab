function[new_xlim,new_ylim,new_zlim]=boundLimitsAllAxes(new_limits,bounds,keeplimitdiff)







    new_xlim=matlab.graphics.interaction.internal.boundLimits(new_limits(1:2),bounds(1:2),keeplimitdiff);
    new_ylim=matlab.graphics.interaction.internal.boundLimits(new_limits(3:4),bounds(3:4),keeplimitdiff);
    new_zlim=matlab.graphics.interaction.internal.boundLimits(new_limits(5:6),bounds(5:6),keeplimitdiff);
end