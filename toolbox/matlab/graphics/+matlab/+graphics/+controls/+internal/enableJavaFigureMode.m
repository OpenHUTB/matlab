function enableJavaFigureMode(ax,mode,value)








    fig=ancestor(ax,'figure');
    switch mode
    case 'pan'
        matlab.graphics.controls.internal.setPanMode(fig,value)
    case 'zoom'
        matlab.graphics.controls.internal.zoominout(fig,value,char(matlab.graphics.controls.internal.ToolbarValidator.zoomin))
    case 'zoomout'
        matlab.graphics.controls.internal.zoominout(fig,value,char(matlab.graphics.controls.internal.ToolbarValidator.zoomout))
    case 'rotate'
        rotate3d(fig,value,'-orbit')
    case 'brush'
        brush(fig,char(value))
    end

end