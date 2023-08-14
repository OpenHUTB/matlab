function ret=isWebAxes(ax)




    ret=false;
    if isa(ax,'matlab.graphics.axis.AbstractAxes')
        can=ancestor(ax,'matlab.graphics.primitive.canvas.Canvas','node');
        ret=isa(can,'matlab.graphics.primitive.canvas.HTMLCanvas');
    end

