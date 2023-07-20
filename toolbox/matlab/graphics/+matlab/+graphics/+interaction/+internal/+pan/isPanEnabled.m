function[en,cons]=isPanEnabled(hAx,cons,rulere)




    fig=ancestor(hAx,'figure');
    if isempty(hAx)||...
        (~isempty(rulere)&&isappdata(hAx(1),'graphicsPlotyyPeer'))||...
        (~isempty(rulere)&&~strcmp(matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(fig,hAx(1)),'limits'))
        en=false;
        cons='';
        return;
    end

    if~isempty(rulere)
        if contains(cons,rulere)
            en=true;
            cons=rulere;
        elseif strcmp(cons,'unconstrained')
            en=true;
            cons=rulere;
        else
            en=false;
        end
    else
        en=true;
    end
