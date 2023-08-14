function figureCreated(fig)









    if feature('LiveEditorRunning')
        return;
    end

    persistent logger
    if isempty(logger)
        logger=connector.internal.Logger('connector::webgraphics');
    end


    matlab.graphics.internal.InteractionInfoPanel.hasBeenOpened(true);

    if~isvalid(fig)
        return;
    end

    isJavaFigure=~isempty(matlab.graphics.internal.getFigureJavaFrame(fig));
    if isJavaFigure


        addListenersToFigure(fig);
        return;
    end

    isLiveEditorFigure=~isempty(fig.Tag)&&strcmp(fig.Tag,'LiveEditorCachedFigure');
    if isLiveEditorFigure
        return;
    end


    isNotEmbeddedMorphableFigure=~isWebFigureType(fig,'EmbeddedMorphableFigure');
    if isNotEmbeddedMorphableFigure
        return;
    end

    isWebFigureUndocked=...
    ~isempty(fig.Tag)...
    ||~isempty(fig.Name)...
    ||strcmp(fig.NumberTitle,'off')...
    ||strcmp(fig.WindowStyle,'modal')...
    ||strcmp(fig.Resize,'off');


    allowUndockedWebFigures=strcmp(mls.internal.feature('webGraphicsPopup'),'on');

    if isWebFigureUndocked&&~allowUndockedWebFigures
        logger.info('Morphing to Java figure to match MO docking heuristic');
        tag=fig.Tag;
        matlab.ui.internal.prepareFigureFor(fig,mfilename('fullpath'));
        fig.Tag=tag;
        attemptShowFigureTools(fig);
        return;
    end



    if~isWebFigureUndocked
        addListenersToFigure(fig);
    end

    cb=@()publishEmbeddedFigurePacket(fig,isWebFigureUndocked);
    matlab.graphics.internal.drawnow.callback(cb);



    function publishEmbeddedFigurePacket(fig,isWebFigureUndocked)











        if~isvalid(fig)||~isWebFigureType(fig,'EmbeddedMorphableFigure')
            removeListenersFromFigure(fig)
            return;
        end



        if~isempty(matlab.graphics.internal.getFigureJavaFrame(fig))
            return;
        end
        channel=matlab.ui.internal.FigureServices.getUniqueChannelId(fig);
        if~isempty(channel)
            logger.info('Creating embedded figure with channel: %s',channel);
            efPacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(fig);
            efPacket.Docked=~isWebFigureUndocked;
            message.publish('/embedded/figure/figureCreated',efPacket);
        else
            logger.error('Could not create embedded figure for figure handle: %d',double(fig));
        end
    end



    function addListenersToFigure(fig)
        if~isprop(fig,"InternalWebGraphics_Data")
            listener=addlistener(fig,'ObjectChildAdded',...
            @(e,d)matlab.graphics.internal.drawnow.callback(@()morphAndUndockFigure(fig,d)));





            if strcmp(fig.ToolBar,'figure')&&strcmp(fig.ToolBarMode,'manual')
                forceUndock(fig);
            else
                listener(end+1)=addlistener(fig,findprop(fig,'ToolBar'),'PostSet',@(e,d)morphAndUndockFigure(fig,d));
            end





            if strcmp(fig.MenuBar,'figure')&&strcmp(fig.MenuBarMode,'manual')
                forceUndock(fig);
            else
                listener(end+1)=addlistener(fig,findprop(fig,'MenuBar'),'PostSet',@(e,d)morphAndUndockFigure(fig,d));
            end

            data.listener=listener;



            prop=addprop(fig,"InternalWebGraphics_Data");
            prop.Hidden=true;
            prop.Transient=true;
            fig.InternalWebGraphics_Data=data;
        end
    end

    function removeListenersFromFigure(fig)
        if isprop(fig,"InternalWebGraphics_Data")
            data=fig.InternalWebGraphics_Data;
            delete(data.listener);
        end
    end



    function morphAndUndockFigure(fig,evd)
        if~isvalid(fig)
            return;
        end





        if strcmpi(evd.EventName,'ObjectChildAdded')&&~isa(evd.Child,'matlab.ui.container.Menu')&&...
            ~isa(evd.Child,'matlab.ui.container.Toolbar')
            return;
        end


        if strcmpi(evd.EventName,'ObjectChildAdded')&&isa(evd.Child,'matlab.ui.container.Toolbar')
            if isprop(evd.Child,'Tag')&&...
                (strcmpi(evd.Child.Tag,'CameraToolBar')||strcmpi(evd.Child.Tag,'FigureToolBar'))
                return;
            end
        end


        removeListenersFromFigure(fig)

        isJavaFigure=~isempty(matlab.graphics.internal.getFigureJavaFrame(fig));
        if~isJavaFigure

            logger.info('Morphing to Java figure when adding/modifying a toolBar or menu');
            matlab.ui.internal.prepareFigureFor(fig,mfilename('fullpath'));
        end


        attemptShowFigureTools(fig);

        forceUndock(fig);
    end

    function forceUndock(fig)

        logger.info('Undocking figure when adding/modifying a toolBar or menu');
        mls.internal.forceMGGUndock(fig);
    end



    function attemptShowFigureTools(fig)


        if~strcmp(fig.MenuBarMode,'manual')&&strcmp(fig.MenuBar,'none')
            mode=get(fig,'MenuBarMode');
            set(fig,'MenuBar','figure');
            set(fig,'MenuBarMode',mode);
        end
        if~strcmp(fig.ToolBarMode,'manual')&&strcmp(fig.ToolBar,'none')
            mode=get(fig,'ToolBarMode');
            set(fig,'ToolBar','auto');
            set(fig,'ToolBarMode',mode);
        end
    end
end