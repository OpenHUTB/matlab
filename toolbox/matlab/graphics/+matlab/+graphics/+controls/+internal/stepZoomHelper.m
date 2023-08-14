function stepZoomHelper(ax,direction)





    if isa(ax,'map.graphics.axis.MapAxes')
        limitProp1="XMap";
        limitProp2="YMap";
    else
        limitProp1="Latitude";
        limitProp2="Longitude";
    end
    lim1=ax.(limitProp1+"Limits");
    lim2=ax.(limitProp2+"Limits");
    switch direction
    case 'zoomin'
        zoomIn(ax)
    case 'zoomout'
        zoomOut(ax)
    end
    addToUndoStack(ax,lim1,lim2,limitProp1,limitProp2)
    matlab.graphics.interaction.generateLiveCode(ax,...
    matlab.internal.editor.figure.ActionID.PANZOOM);
end


function addToUndoStack(ax,lim1,lim2,limitProp1,limitProp2)
    if isempty(lim1)||isempty(lim2)
        return
    end


    cmd.Name='Zoom';


    axProxy=plotedit({'getProxyValueFromHandle',ax});


    fig=ancestor(ax,'figure');
    cmd.Function=@changeLimits;
    cmd.Varargin={fig,axProxy,...
    ax.(limitProp1+"Limits"),ax.(limitProp2+"Limits"),limitProp1,limitProp2};


    cmd.InverseFunction=@changeLimits;
    cmd.InverseVarargin={fig,axProxy,lim1,lim2,limitProp1,limitProp2};



    uiundo(fig,'function',cmd)
end


function changeLimits(fig,axProxy,lim1,lim2,limitProp1,limitProp2)
    ax=plotedit({'getHandleFromProxyValue',fig,axProxy});

    if(~ishghandle(ax))
        return
    end

    ax.(limitProp1+"LimitsRequest")=lim1;
    ax.(limitProp2+"LimitsRequest")=lim2;
end