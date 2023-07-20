function pinAtAffordance(hObj,affNum,vertexData)


    [hFig,hContainer]=getContainers(hObj);
    if isempty(hContainer)
        return;
    end


    hObj.unpinAtAffordance(affNum);



    if nargin<3||isempty(vertexData)
        hAff=hObj.Srect(affNum);



        if isempty(hAff.VertexData)
            drawnow expose;
        end
        pt=double(hAff.VertexData).';
    else
        pt=double(vertexData);
    end
    pt=pt(1:2);



    ptrect=hgconvertunits(hFig,[pt,0,0],'Normalized','Pixels',hContainer);
    point=ptrect(1:2);

    if~isAxesUnderPoint(hContainer,point)
        return;
    end


    hPin=matlab.graphics.shape.internal.ScribePin(hContainer,point(1:2));
    hPin.UserData=affNum;


    setappdata(hPin.Axes,'ContainsPinnedScribeObject',true);

    hObj.addPinListeners(hPin,affNum);


    hObj.Pin(end+1)=hPin;

    hPin.Axes.MarkDirty('all');


    function ret=isAxesUnderPoint(hContainer,point)

        ret=false;


        axList=findobj(hContainer,'-isa','matlab.graphics.axis.AbstractAxes');
        axList=axList(arrayfun(@(a)supportsPinning(a),axList));
        hFig=ancestor(hContainer,'figure');
        vp=matlab.graphics.interaction.internal.getViewportInDevicePixels(hFig,hContainer);
        for i=1:numel(axList)
            if matlab.graphics.interaction.internal.isAxesHit(axList(i),vp,point,[0,0])
                ret=true;
                return;
            end
        end

        function r=supportsPinning(ax)

            r=isempty(ax.TargetManager)||(numel(ax.TargetManager.Children)<2);
