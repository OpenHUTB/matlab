
function algLoop=removehighlight(algLoop)

    import Simulink.SLHighlight.*;
    for i=1:numel(algLoop.hstyle)
        removeHighlight(algLoop.hstyle(i));
    end
    algLoop.hstyle=[];
end