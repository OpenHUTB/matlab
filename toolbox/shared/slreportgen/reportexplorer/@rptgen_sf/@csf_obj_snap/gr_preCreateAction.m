function gr_preCreateAction(c,gm,objHandle,varargin)%#ok








    if strcmp(c.ViewportType,'none')
        stretchRatio=1;
    else
        vpSize=c.RuntimeViewportSize;
        imSize=gr_getIntrinsicSize(c,gm,objHandle);
        stretchRatio=mean(vpSize./imSize);
    end

    if~isempty(c.RuntimePointerCoords)
        for i=1:size(c.RuntimePointerCoords,1)
            areaSpec=gm.addArea(round(c.RuntimePointerCoords{i,1}*stretchRatio),...
            c.RuntimePointerCoords{i,2});
            gm.addCallout(areaSpec,...
            c.RuntimePointerCoords{i,3});
        end
        c.RuntimePointerCoords={};
    end

