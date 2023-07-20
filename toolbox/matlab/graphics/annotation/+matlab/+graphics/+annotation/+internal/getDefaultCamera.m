function hLayer=getDefaultCamera(hContainer,layerName,peekflag)









    if~isvalid(hContainer)
        hLayer=[];
        return;
    end

    if~isa(hContainer,'matlab.ui.internal.mixin.CanvasHostMixin')
        error(message('MATLAB:scribe:getLayer:firstArgFigure'));
    end

    try
        layerName=hgcastvalue('matlab.graphics.chart.datatype.OverlayType',layerName);
    catch E
        error(message('MATLAB:scribe:getLayer:secondArgLayer'));
    end




    containerChildren=hgGetTrueChildren(hContainer);
    hViewer=[];
    hM=[];
    for i=1:length(containerChildren)
        if isa(containerChildren(i),'matlab.graphics.primitive.canvas.Canvas')
            hViewer=containerChildren(i);
            hM=hViewer.StackManager;
            break;
        end
    end
    if(nargin>=3&&strcmpi(peekflag,'-peek'))&&isempty(hM)
        hLayer=[];
        return;
    end

    if isempty(hM)
        if isempty(hViewer)

            hViewer=hContainer.getCanvas;
        end
        hM=matlab.graphics.shape.internal.ScribeStackManager.getInstance;
        hViewer.StackManager=hM;
    end


    hLayer=hM.getDefaultCamera(hViewer,layerName);
