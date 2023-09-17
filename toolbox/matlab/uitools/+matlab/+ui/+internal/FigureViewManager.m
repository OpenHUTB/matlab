function ret=FigureViewManager(fig)

    figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>

    ret=fig;
    if isempty(fig)
        return;
    end


    cachedPosition=[];
    if strcmp(fig.Resize,"off")
        cachedPosition=fig.Position;
    end


    figureVisibleCache=fig.Visible;
    figureVisibleModeCache=fig.VisibleMode;
    fig.Visible_I='off';
    currentAxesCache=fig.CurrentAxes;

    axesAndCharts=matlab.ui.internal.getAllCharts(fig);

    [SerializedSubplotLocations,SerializedSpanSubplotLocations,SerializedSubplotTitle]...
    =matlab.ui.internal.saveSubplotLayout(fig,axesAndCharts);
    matlab.graphics.interaction.internal.disableAllWebAxesModes(fig);


    set(axesAndCharts,'Parent',[]);

    child=findall(fig,'-depth',1,{'-isa','matlab.graphics.shape.internal.AnnotationPane',...
    '-or','type','legend',...
    '-or','type','colorbar'});


    set(child,'Parent',[]);
    channel='';
    if~isprop(fig,'LiveEditorRunTimeFigure')&&matlab.ui.internal.desktop.isMOTW
        channel=matlab.ui.internal.FigureServices.getUniqueChannelId(fig);
        cachedTag=fig.Tag;
        cleanupTag=onCleanup(@()set(fig,'Tag',cachedTag));


        fig.Tag=strcat(cachedTag,channel);
    end


    oldcanvas=findobjinternal(fig,'-isa','matlab.graphics.primitive.canvas.HTMLCanvas');

    allch=allchild(fig);
    set(allch,'Parent',[]);

    internalComponentChildren=findobjinternal(fig,{'-isa','matlab.ui.control.UIControl',...
    '-or','-isa','matlab.ui.container.ContextMenu'});
    set(internalComponentChildren,'Parent',[]);

    delete(oldcanvas);
    warnStructOnObject=warning('off','MATLAB:StructOnObject');
    warnObj=matlab.ui.internal.JavaMigrationTools.suppressJavaFrameWarning();%#ok<NASGU>
    s=struct(fig);
    controller=s.Controller;
    warning(warnStructOnObject);
    morphFigureToJava(fig);
    if~isempty(channel)
        message.publish('/embedded/figure/figureMorphed',struct('channel',channel));
    end
    delete(controller);


    set([flip(allch);flip(axesAndCharts);flip(child);flip(internalComponentChildren)],'Parent',fig);



    fig.CurrentAxes=currentAxesCache;


    matlab.ui.internal.restoreSubplotLayout...
    (SerializedSubplotLocations,SerializedSpanSubplotLocations,...
    SerializedSubplotTitle,axesAndCharts,fig);


    set(fig,'Visible',figureVisibleCache,'VisibleMode',figureVisibleModeCache);

    if~isempty(cachedPosition)

        fig.Position_I=[0,0,cachedPosition(3:4)];
        fig.Position_I=cachedPosition;
    end
end
