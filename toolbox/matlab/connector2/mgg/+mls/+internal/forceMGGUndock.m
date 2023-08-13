function forceMGGUndock(fig)

    if strcmp(mls.internal.feature('graphicsAndGuis'),'off')
        return;
    end

    [frame,frameProxy]=getFigureJavaFrame(fig);
    if~isempty(frameProxy)

        frameProxy.setForceMGGUndocked(true);
    end

    try
        if~isempty(frame)&&isa(frame,'com.mathworks.hg.peer.FigureFrameProxy$FigureFrame')

            handler=com.mathworks.matlabserver.jcp.handlers.RootHandler.getHandlerByComponent(frame);
            if~isempty(handler)
                peerNode=handler.getPeerNode();
                peerNode.setProperty('docked',false);
            end
        end
    catch

    end
end

function[frame,frameProxy]=getFigureJavaFrame(fig)
    frame=[];
    frameProxy=[];


    sw=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    figureJavaHandle=matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(fig);
    warning(sw);

    if isempty(figureJavaHandle)
        return;
    end

    frameProxy=figureJavaHandle.fHG2Client.getFrameProxy();

    c=figureJavaHandle.getAxisComponent;
    while~(isempty(c)||...
        isa(c,'com.mathworks.hg.peer.FigureFrameProxy$FigureFrame'))
        c=c.getParent;
    end
    frame=c;
end
