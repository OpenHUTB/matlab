classdef ModeManager<handle




    properties
Figure
FigureID
Line
Mode
ZoomDirection
        CodeGenerator matlab.internal.editor.CodeGenerator

        UndoRedoManager matlab.internal.editor.figure.UndoRedoManager
DraggedDataTip
DraggedDataTipScribePeer
hasDataTips
    end

    methods(Access=private)


        function setZoomDirection(this,direction)
            this.ZoomDirection=direction;
        end
    end

    methods(Static)
        function[modeName,modeStateData]=getModeFromFigure(fig)


            modeName='';
            modeStateData=struct;
            if isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)
                modeObj=fig.ModeManager.CurrentMode;
                if isempty(modeObj)
                    return
                end
                modeName=fig.ModeManager.CurrentMode.Name;
                modeStateData=fig.ModeManager.CurrentMode.ModeStateData;
            else







                hasLayout=findobj(fig,'-isa','matlab.graphics.layout.Layout','-depth',1);
                if isempty(hasLayout)
                    ax=findobj(fig,'type','axes','-depth',1,'-function',@(ax)~strcmp(ax.InteractionContainer.CurrentMode,'none'));
                else
                    ax=findobj(fig,'type','axes','-function',@(ax)~strcmp(ax.InteractionContainer.CurrentMode,'none'));
                end

                if~isempty(ax)
                    webModeName=ax(1).InteractionContainer.CurrentMode;
                    switch webModeName
                    case{'pan'}
                        modeName='Exploration.Pan';
                    case{'rotate'}
                        modeName='Exploration.Rotate3d';
                    case{'zoom'}
                        modeName='Exploration.Zoom';
                        modeStateData=struct('Direction','in');
                    case 'datacursor'
                        modeName='Exploration.Datacursor';
                    end
                end
            end
        end
    end

    methods
        function this=ModeManager(figureId,line,mode,cg,undoRedoManager)
            this.FigureID=figureId;
            this.Line=line;
            this.Mode=mode;
            this.CodeGenerator=cg;
            this.UndoRedoManager=undoRedoManager;
        end

        function interactionCallback(this,clientEvent)
            import matlab.internal.editor.*
            import matlab.internal.editor.figure.FigureDataTransporter

            cleanupHandle=clearWebGraphicsRestriction;%#ok<NASGU>

            fig=this.Figure;
            if isempty(fig.ModeManager.CurrentMode)
                return
            end

            isDataCursorMode=false;

            isReset=false;


            ax=[];
            if isfield(clientEvent,'axesIndex')&&~isempty(clientEvent.axesIndex)

                ax=getAxesFromIndex(this.Figure,clientEvent.axesIndex+1);
            end


            figPos=getpixelposition(this.Figure);
            eventData.x=clientEvent.x*figPos(3);
            eventData.y=clientEvent.y*figPos(4);




            oldFigureUnits=fig.Units;
            fig.Units='pixels';



            if isempty(ax)

                ax=localHitTest(fig,eventData);
            end
            dataTips=[];
            if strcmp(fig.ModeManager.CurrentMode.Name,'Exploration.Datacursor')
                isDataCursorMode=true;
                dataTips=findall(ax,'-isa','matlab.graphics.shape.internal.PointDataTip');

                sv=hg2gcv(fig);

                drawnow update

                ySv=fig.Position(4)-eventData.y;
                if strcmp(clientEvent.type,'ModeWindowButtonMouseMove')&&~isempty(this.DraggedDataTip)
                    hitObj=this.DraggedDataTip;
                else
                    hitObj=sv.hittest(eventData.x,ySv);
                end


                if isempty(hitObj)
                    hitObj=fig;
                end



            else
                hitObj=ax;
            end




            fig.CurrentPoint=[eventData.x,eventData.y];
            fig.CurrentAxes=ancestor(hitObj,'matlab.graphics.axis.AbstractAxes');



            fig.ModeManager.CurrentMode.FigureState.CurrentAxes=fig.CurrentAxes;

            drawnow update
            origSelType=fig.SelectionType;



            prehandler=[];
            modeHandler=[];
            if strcmp(clientEvent.type,'WindowButtonMouseDown')||...
                strcmp(clientEvent.type,'WindowMouseDblClick')||...
                strcmp(clientEvent.type,'WindowMouseRightClick')

                if strcmp(clientEvent.type,'WindowMouseDblClick')&&~isDataCursorMode
                    fig.SelectionType='open';



                    if isa(ax,'matlab.graphics.axis.Axes')&&...
                        (strcmpi(ax.XLimMode,'manual')||strcmpi(ax.YLimMode,'manual')||...
                        strcmpi(ax.ZLimMode,'manual'))
                        isReset=true;
                    end
                end


                if strcmp(clientEvent.type,'WindowMouseRightClick')
                    if strcmp(clientEvent.Tag,'ResetView')||strcmp(clientEvent.Tag,'Reset')
                        fig.SelectionType='open';
                        isReset=true;
                    else
                        fig.SelectionType='alt';
                    end
                end

                if isDataCursorMode&&isa(hitObj,'matlab.graphics.shape.internal.ScribePeer')




                    this.DraggedDataTipScribePeer=hitObj;
                    for i=1:numel(dataTips)

                        if(hitObj==dataTips(i).TipHandle.ScribeHost.getScribePeer())||...
                            (hitObj==dataTips(i).LocatorHandle.ScribeHost.getScribePeer())
                            this.DraggedDataTip=dataTips(i);
                        end
                    end
                end

                modeHandler=fig.ModeManager.CurrentMode.WindowButtonDownFcn;
                syntheticMouseEvent=SyntheticMouseEvent(fig,hitObj,fig.CurrentPoint,'WindowMousePress');
            elseif strcmp(clientEvent.type,'ModeWindowButtonMouseMove')
                if isDataCursorMode&&~isempty(this.DraggedDataTipScribePeer)
                    if strcmp('GraphicsTip',this.DraggedDataTipScribePeer.Tag)
                        cursorPos=fig.CurrentPoint;
                        dataTipPixelPosition=this.DraggedDataTipScribePeer.PixelPosition(1:2);

                        if cursorPos(1)<=dataTipPixelPosition(1)&&...
                            cursorPos(2)<=dataTipPixelPosition(2)
                            this.DraggedDataTip.Orientation='bottomleft';
                        elseif cursorPos(1)<=dataTipPixelPosition(1)&&...
                            cursorPos(2)>dataTipPixelPosition(2)
                            this.DraggedDataTip.Orientation='topleft';
                        elseif cursorPos(1)>dataTipPixelPosition(1)&&...
                            cursorPos(2)>dataTipPixelPosition(2)
                            this.DraggedDataTip.Orientation='topright';
                        elseif cursorPos(1)>dataTipPixelPosition(1)&&...
                            cursorPos(2)<dataTipPixelPosition(2)
                            this.DraggedDataTip.Orientation='bottomright';
                        end
                    elseif strcmp('PointTipLocator',this.DraggedDataTipScribePeer.Tag)
                        this.DraggedDataTip.Position=matlab.graphics.chart.internal.convertViewerCoordsToDataSpaceCoords(ax,fig.CurrentPoint(:)')';
                    end
                end
                modeHandler=fig.ModeManager.CurrentMode.WindowButtonMotionFcn;
                syntheticMouseEvent=SyntheticMouseEvent(fig,hitObj,fig.CurrentPoint,'WindowMouseMove');
            elseif strcmp(clientEvent.type,'ModeWindowButtonMouseUp')
                if isDataCursorMode




                    this.fireFigureEvents(hitObj,[eventData.x,eventData.y],'WindowMouseRelease');
                    this.DraggedDataTip=[];
                    this.DraggedDataTipScribePeer=[];
                end
                modeHandler=fig.ModeManager.CurrentMode.WindowButtonUpFcn;
                syntheticMouseEvent=SyntheticMouseEvent(fig,hitObj,fig.CurrentPoint,'WindowMouseUp');
            elseif strcmp(clientEvent.type,'WindowButtonMouseWheel')



                prehandler=fig.ModeManager.CurrentMode.WindowButtonMotionFcn;
                modeHandler=fig.ModeManager.CurrentMode.WindowScrollWheelFcn;
                syntheticMouseEvent=SyntheticMouseWheelEvent(fig,clientEvent.wheelDelta,fig.CurrentPoint);
                syntheticMouseEvent.HitObject=ax;
            else
                return;
            end





            if strcmp(clientEvent.type,'WindowMouseRightClick')&&strcmp(fig.SelectionType,'alt')
                origView=ax.View;
                switch lower(clientEvent.Tag)
                case 'snaptoxy'
                    newView=[0,90];
                    localSetView(ax,origView,newView);
                case 'snaptoxz'
                    newView=[0,0];
                    localSetView(ax,origView,newView);
                case 'snaptoyz'
                    newView=[90,0];
                    localSetView(ax,origView,newView);
                case 'zoominout'
                    if strcmpi(fig.ModeManager.CurrentMode.ModeStateData.Direction,'in')


                        zoom(ax,2/3);
                    else


                        zoom(ax,3/2);
                    end
                case 'deletealldatatips'


                    matlab.internal.editor.ModeManager.removeDataCursor(uigetmodemanager(fig));
                    dataTips=[];
                    this.DraggedDataTip=[];
                    this.DraggedDataTipScribePeer=[];
                end
            else
                if~isempty(prehandler)
                    feval(prehandler,fig,syntheticMouseEvent);
                end

                if iscell(modeHandler)
                    feval(modeHandler{1},fig,syntheticMouseEvent,modeHandler{2:end});
                elseif~isempty(modeHandler)
                    feval(modeHandler,fig,syntheticMouseEvent);
                end
            end

            fig.SelectionType=origSelType;
            clearGeneratedCode=false;
            interactionType='';
            switch(this.Mode)
            case{'Exploration.Pan'}
                interactionType=matlab.internal.editor.figure.ActionID.PANZOOM;
            case{'Exploration.Rotate3d'}
                interactionType=matlab.internal.editor.figure.ActionID.ROTATE;
            case{'Exploration.Zoom'}
                interactionType=matlab.internal.editor.figure.ActionID.PANZOOM;
            case 'Exploration.Datacursor'
                dataTips=findall(ax,'-isa','matlab.graphics.shape.internal.PointDataTip');
                if matlab.graphics.datatip.DataTip.isValidParent(hitObj)||...
                    ~isempty(this.DraggedDataTip)||isempty(dataTips)
                    if isempty(dataTips)
                        interactionType=matlab.internal.editor.figure.ActionID.DATATIPS_REMOVED;
                    elseif isempty(this.DraggedDataTip)&&~this.hasDataTips
                        this.CodeGenerator.deregisterAction(ax,matlab.internal.editor.figure.ActionID.DATATIPS_REMOVED);
                        interactionType=matlab.internal.editor.figure.ActionID.DATATIP_ADDED;
                    else
                        this.CodeGenerator.deregisterAction(ax,matlab.internal.editor.figure.ActionID.DATATIPS_REMOVED);
                        interactionType=matlab.internal.editor.figure.ActionID.DATATIP_EDITED;
                    end
                end
            end

            if~isempty(this.CodeGenerator)
                if isReset
                    drawnow update;



                    this.CodeGenerator.registerAction(ax,matlab.internal.editor.figure.ActionID.RESET_LIMITS);
                    this.UndoRedoManager.registerUndoRedoAction(ax,matlab.internal.editor.figure.ActionID.RESET_LIMITS);
                elseif isDataCursorMode
                    this.CodeGenerator.registerAction(ax,interactionType);
                    if~isempty(this.DraggedDataTip)

                        this.CodeGenerator.registerAction(this.DraggedDataTip,interactionType);
                    else
                        currentDT=findall(dataTips,'CurrentTip','on');
                        if~isempty(currentDT)
                            this.CodeGenerator.registerAction(currentDT,interactionType);
                        end
                    end
                else


                    this.CodeGenerator.registerAction(ax,interactionType);
                    this.UndoRedoManager.registerUndoRedoAction(ax,interactionType);
                end

                [generatedCode,isFakeCode]=this.CodeGenerator.generateCode;

                if isempty(generatedCode)
                    clearGeneratedCode=true;
                end
            else
                generatedCode={};
            end


            fig.Units=oldFigureUnits;




drawnow






            if isempty(fig.ModeManager.CurrentMode)||isempty(fig.ModeManager.CurrentMode.Name)
                FigureDataTransporter.transportFigureDataForRendering(this.FigureID,this.Figure);
                return
            end

            if clearGeneratedCode
                transportFigureDataForReset(this.FigureID);
            elseif isReset||(strcmp(this.Mode,'Exploration.Zoom')&&~isempty(generatedCode))


                transportFigureDataForAtomicOperation(this.FigureID,this.Figure,generatedCode,isFakeCode);
            else
                transportFigureDataForInteraction(this.FigureID,this.Figure,generatedCode,isFakeCode);
            end
        end

        function setMode(this,modeObj)
            this.Mode=modeObj.mode;

            if~isempty(modeObj.direction)
                this.setZoomDirection(modeObj.direction);
            end
        end

        function setServerMode(this,modeName,modeStateData)


            this.Mode=modeName;
            if~isempty(modeStateData)&&isfield(modeStateData,'Direction')
                this.setZoomDirection(modeStateData.Direction);
            end
        end

        function setCodeGenerator(this,cg)
            this.CodeGenerator=cg;
        end


        function setModeOnPopOutFigure(this,fig)
            switch(this.Mode)
            case{'Exploration.Pan'}
                pan(fig,'on');
            case{'Exploration.Rotate3d'}


                rotate3d(fig,'ON');
            case{'Exploration.Zoom'}
                zoom(fig,[this.ZoomDirection,'mode']);
            case{'Exploration.Datacursor'}

                datacursormode(fig,'on');
            end
        end

        function setFigure(this,fig)
            cleanupHandles={clearWebGraphicsRestriction};

            import matlab.internal.editor.ModeManager;





            cachedMenuBarMode=fig.MenuBarMode;
            cachedToolBarMode=fig.ToolBarMode;
            set(fig,'MenuBarMode','manual','ToolBarMode','manual');
            cleanupHandles{end+1}=onCleanup(@()set(fig,'MenuBarMode',cachedMenuBarMode,'ToolBarMode',cachedToolBarMode));


            [currentFigureMode,modeStateData]=matlab.internal.editor.ModeManager.getModeFromFigure(fig);

            this.Figure=fig;

            if isempty(this.Mode)
                activateuimode(fig,'');


                set(fig,'Visible','off','VisibleMode','auto');
                return
            end






            if~isempty(this.CodeGenerator)
                this.CodeGenerator.setFigure(fig);
            end

            this.hasDataTips=~isempty(findall(fig,'-isa','matlab.graphics.shape.internal.PointDataTip'));


            if~strcmp(this.Mode,currentFigureMode)||...
                (strcmp(currentFigureMode,'Exploration.Zoom')&&...
                ~strcmp(this.ZoomDirection,modeStateData.Direction))



                switch(this.Mode)
                case{'Exploration.Pan'}
                    pan(fig,'on');



                    preloadModeClasses(fig)
                case{'Exploration.Rotate3d'}


                    rotate3d(fig,'ON');



                    preloadModeClasses(fig)
                case{'Exploration.Zoom'}
                    zoom(fig,[this.ZoomDirection,'mode']);
                case{'Exploration.Datacursor'}
                    datacursormode(fig,'on');



                    preloadModeClasses(fig)
                case ModeManager.getSpringLoadedModeNames
                    matlab.internal.editor.figure.DefaultSpringLoadedMode(fig,this.Mode,'on')
                end

            end
        end



        function setSerializedModeState(this,serializedModeState)
            if~isempty(serializedModeState)
                serializedModeState.deserialize(this.Figure,this.Mode);
            end
        end
    end

    methods(Access=private)
        function fireFigureEvents(this,hitObj,point,eventType)
            evd=matlab.internal.editor.DataTipSyntheticEventData;
            evd.Point=point;
            evd.HitObject=hitObj;
            this.Figure.notify(eventType,evd);
        end
    end

    methods(Static)
        function removeDataCursor(uiModeManager)

            if~isempty(uiModeManager.CurrentMode)&&strcmp(uiModeManager.CurrentMode.Name,'Exploration.Datacursor')
                uiModeManager.CurrentMode.ModeStateData.DataCursorTool.removeAllDataCursors();
            end
        end

        function modeStateData=getSpringLoadedModeData(mode,axesHandles)
            switch mode
            case 'placedGridMode'
                modeStateData=double(arrayfun(@(ax)~matlab.internal.editor.figure.ChartAccessor.hasGrid(ax),axesHandles));
            case 'placedXGridMode'
                modeStateData=double(arrayfun(@(ax)isa(ax,'matlab.graphics.axis.Axes')&&(strcmp(ax.XGrid,'off')||strcmp(ax.YGrid,'on')),axesHandles));
            case 'placedYGridMode'
                modeStateData=double(arrayfun(@(ax)isa(ax,'matlab.graphics.axis.Axes')&&(strcmp(ax.YGrid,'off')||strcmp(ax.XGrid,'on')),axesHandles));
            case 'placedLegendMode'
                modeStateData=double(arrayfun(@(ax)~matlab.internal.editor.figure.ChartAccessor.hasLegend(ax),axesHandles));
            case 'placedColorbarMode'
                modeStateData=double(arrayfun(@(ax)~matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax),axesHandles));
            otherwise
                modeStateData=[];
            end

        end

        function state=isSpringLoadedModeApplied(mode,hFig)
            axesHandles=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);
            switch mode
            case 'placedGridMode'
                state=all(arrayfun(@(ax)matlab.internal.editor.figure.ChartAccessor.hasGrid(ax),axesHandles));
            case 'placedXGridMode'
                state=all(arrayfun(@(ax)isa(ax,'matlab.graphics.axis.Axes')&&strcmp(ax.XGrid,'on')&&strcmp(ax.YGrid,'off'),axesHandles));
            case 'placedYGridMode'
                state=all(arrayfun(@(ax)isa(ax,'matlab.graphics.axis.Axes')&&strcmp(ax.YGrid,'on')&&strcmp(ax.XGrid,'off'),axesHandles));
            case 'placedLegendMode'
                state=all(arrayfun(@(ax)matlab.internal.editor.figure.ChartAccessor.hasLegend(ax),axesHandles));
            case 'placedColorbarMode'
                state=all(arrayfun(@(ax)matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax),axesHandles));
            otherwise
                state=false;
            end
        end

        function springLoadedModeNames=getSpringLoadedModeNames
            springLoadedModeNames={'placedLegendMode','placedColorbarMode','placedGridMode','placedXGridMode',...
            'placedYGridMode','placedTitleMode',...
            'placedXLabelMode','placedYLabelMode','placedLineMode',...
            'placedArrowMode','placedDoubleArrowMode','placedTextArrowMode'};

        end
    end
end

function container=setPaintDisabled(javaFrame,disable)

    container=javaObjectEDT(javaFrame.getFigurePanelContainer());
    container.setPaintDisabled(disable)

end


function currentAxes=localHitTest(fig,eventData)

    currentAxes=[];
    ax=getAllAxes(fig);


    if isempty(ax)
        return
    end
    currentAxes=ax(1);
    for k=1:length(ax)
        axesPos=getpixelposition(ax(k));
        if eventData.y<=axesPos(2)+axesPos(4)&&eventData.y>axesPos(2)&&...
            eventData.x<=axesPos(1)+axesPos(3)&&eventData.x>axesPos(1)
            currentAxes=ax(k);
            return
        end
    end

end

function ax=getAllAxes(fig)
    uipanels=findall(fig,'-isa','matlab.ui.container.internal.UIContainer','-depth',1);
    hasLayout=findall(fig,'-isa','matlab.graphics.layout.Layout','-depth',1);

    if isempty(uipanels)&&isempty(hasLayout)
        ax=findall(fig,'-isa','matlab.graphics.axis.AbstractAxes','-depth',1,'Visible','on');
    else
        ax=findall(fig,'-isa','matlab.graphics.axis.AbstractAxes','Visible','on');
    end

end

function ax=getAxesFromIndex(fig,index)
    allAxes=getAllAxes(fig);
    ax=[];
    if length(allAxes)>=index
        ax=allAxes(index);
    end

end


function transportFigureDataForInteraction(figureId,~,generatedCode,isFakeCode)


    import matlab.internal.editor.figure.FigureDataTransporter

    figureData=matlab.internal.editor.figure.FigureData;
    figureData.setCode(generatedCode);
    figureData.setFakeCode(isFakeCode);

    FigureDataTransporter.transportFigureData(figureId,figureData);
end

function transportFigureDataForAtomicOperation(figureId,~,generatedCode,isFakeCode)

    import matlab.internal.editor.figure.FigureDataTransporter

    figureData=matlab.internal.editor.figure.FigureData;
    figureData.setCode(generatedCode);

    figureData.setFakeCode(isFakeCode);
















    figureData.showCode;

    FigureDataTransporter.transportFigureData(figureId,figureData);
end

function transportFigureDataForReset(figureId)

    import matlab.internal.editor.figure.FigureDataTransporter

    figureData=matlab.internal.editor.figure.FigureData;
    figureData.clearCode;

    FigureDataTransporter.transportFigureData(figureId,figureData);
end

function preloadModeClasses(fig)







    ax=getAllAxes(fig);
    if~isempty(ax)
        matlab.graphics.interaction.internal.isAxesHit(ax(1),ax(1).Camera.Viewport.RefFrame,[1,1],[1,1]);
    end

end

function cleanupHandle=clearWebGraphicsRestriction
    webGraphicsRestriction=feature('WebGraphicsRestriction');
    if webGraphicsRestriction
        feature('WebGraphicsRestriction',false);
        cleanupHandle=onCleanup(@()feature('WebGraphicsRestriction',true));
    else
        cleanupHandle=[];
    end
end





function localSetView(hAxes,origView,newView)
    view(hAxes,newView);

    localCreateUndo(hAxes,origView,newView);
end



function localCreateUndo(hAxes,origView,newView)


    hFig=ancestor(hAxes,'figure');


    proxyVal=plotedit({'getProxyValueFromHandle',hAxes});

    cmd.Function=@localDoUndo;
    cmd.Varargin={hFig,proxyVal,newView};
    cmd.Name='Rotate';
    cmd.InverseFunction=@localDoUndo;
    cmd.InverseVarargin={hFig,proxyVal,origView};
    uiundo(hFig,'function',cmd);
end



function localDoUndo(hFig,proxyVal,newView)

    hAxes=plotedit({'getHandleFromProxyValue',hFig,proxyVal});
    if ishghandle(hAxes)
        view(hAxes,newView);
    end
end
