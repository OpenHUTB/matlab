function scribeax=findAnnotationPane(container)




    hCanvas=container.getCanvas();
    hM=hCanvas.StackManager;
    if isempty(hM)
        hM=matlab.graphics.shape.internal.ScribeStackManager.getInstance;
        hCanvas.StackManager=hM;
    end
    layer=getLayer(hM,hCanvas,'overlay');
    if~isempty(layer)
        scribeax=layer.Pane;
        scribeax.Serializable='on';
    end
