function position=doGetDisplayAnchorPoint(hObj,index,~)







    position=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getDisplayAnchorPoint(hObj,index,0);
    if~strcmp(hObj.Is3D,'on')
        position.Is2D=true;
    end
