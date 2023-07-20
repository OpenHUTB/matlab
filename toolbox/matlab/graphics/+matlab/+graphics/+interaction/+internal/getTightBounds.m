function tight_lim=getTightBounds(ax)

    [x,y,z]=matlab.graphics.interaction.internal.getFiniteLimits(ax);
    tight_lim=[x,y,z];
end