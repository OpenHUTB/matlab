function intersectionPoint=calculateIntersectionPoint(pointPixels,hitObject)








    hContainer=ancestor(hitObject,'matlab.ui.internal.mixin.CanvasHostMixin','node');
    if isscalar(hContainer)&&~isgraphics(hContainer,'figure')
        contPixelPos=getpixelposition(hContainer,true);
        if(isa(hContainer,'matlab.ui.container.Panel'))
            contPixelPos=contPixelPos+[matlab.ui.internal.getPanelMargins(hContainer),0,0];
        end
        pointPixels=pointPixels-contPixelPos(1:2);
    end


    if isscalar(hitObject)
        [hCamera,M1,hDataSpace,M2]=matlab.graphics.internal.getSpatialTransforms(hitObject);
        pointWorld=matlab.graphics.internal.transformViewerToWorld(hCamera,M1,hDataSpace,M2,pointPixels(:));
        intersectionPoint=matlab.graphics.internal.transformWorldToData(hDataSpace,M2,pointWorld)';
    else
        intersectionPoint=NaN(1,3);
    end

end
