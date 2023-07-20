function graphic=getLegendGraphic(hObj)



    hasHorizontalBars=...
    (~isempty(hObj.XNegativeDelta_I)&&any(isfinite(hObj.XNegativeDelta_I)))||...
    (~isempty(hObj.XPositiveDelta_I)&&any(isfinite(hObj.XPositiveDelta_I)));

    hasVerticalBars=...
    (~isempty(hObj.YNegativeDelta_I)&&any(isfinite(hObj.YNegativeDelta_I)))||...
    (~isempty(hObj.YPositiveDelta_I)&&any(isfinite(hObj.YPositiveDelta_I)));

    hasDataLine=~strcmp(hObj.LineStyle_I,'none');

    graphic=matlab.graphics.primitive.world.Group;

    if hasDataLine
        edge=copyobj(hObj.Line,graphic);
        edge.LineWidth=min(edge.LineWidth,2);

        if hasHorizontalBars




            n=45;
            controlPoints=[0.15,0.45,0.55,0.85;0,0,1,1];
            t=linspace(0,1,n);
            pts=kron((1-t).^3,controlPoints(:,1))+...
            kron(3*(1-t).^2.*t,controlPoints(:,2))+...
            kron(3*(1-t).*t.^2,controlPoints(:,3))+...
            kron(t.^3,controlPoints(:,4));

            vd=single([[0;0;0],[pts;zeros(1,n)],[1;1;0]]);
            sd=uint32([1,n+3]);
        else
            vd=single([0,1;.5,.5;0,0]);
            sd=uint32([1,3]);
        end

        edge.VertexData=vd;
        edge.StripData=sd;
    end

    if hasHorizontalBars
        bvd=single([.25,.75;.5,.5;0,0]);

        capH=copyobj(hObj.CapH,graphic);
        capH.Size=min(capH.Size,6);
        capH.LineWidth=min(capH.LineWidth,2);
        capH.Style='vbar';
        capH.VertexData=bvd;
    else
        bvd=zeros(3,0,'single');
    end

    if hasVerticalBars
        vd=single([.5,.5;0,1;0,0]);
        bvd=[bvd,vd];

        cap=copyobj(hObj.Cap,graphic);
        cap.Size=min(cap.Size,6);
        cap.LineWidth=min(cap.LineWidth,2);
        cap.Style='hbar';
        cap.VertexData=vd;
    end

    if hasVerticalBars||hasHorizontalBars
        bar=copyobj(hObj.Line,graphic);
        bar.VertexData=bvd;
        bar.StripData=[];
        bar.LineStyle='solid';
        bar.LineWidth=min(bar.LineWidth,2);
        bar.AlignVertexCenters='on';
    end

    marker=copyobj(hObj.MarkerHandle,graphic);
    marker.VertexData=single([.5;.5;0]);
    if strcmp(marker.Style,'point')
        maxSize=18;
    else
        maxSize=6;
    end
    marker.Size=min(marker.Size,maxSize);
    marker.LineWidth=min(marker.LineWidth,2);
