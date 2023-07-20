function initialize(this)








    this.destructor=handle.listener(this,'ObjectBeingDestroyed',@(obj,event)this.cleanupFigure());


    this.fig=figure('Menubar','none',...
    'NumberTitle','Off',...
    'Units','Pixels',...
    'Visible','off',...
    'Tag','IMAQPreviewFigure');


    setappdata(this.fig,'IgnoreCloseAll',2);


    figSize=get(this.fig,'Position');
    figWidth=figSize(3);

    this.axis=axes('visible','on');
    set(this.axis,'Units','Pixels','XTick',[],'YTick',[]);


    this.prevPanelButtonPanel=handle(com.mathworks.toolbox.imaq.browser.PreviewButtonsPanel.getInstance());
    connect(this,this.prevPanelButtonPanel,'down');


    previewButtonPanelInstance=com.mathworks.toolbox.imaq.browser.PreviewButtonsPanel.getInstance();
    bkGndColor=previewButtonPanelInstance.getBackground();
    r=bkGndColor.getRed;
    g=bkGndColor.getGreen;
    b=bkGndColor.getBlue;
    if~ispc&&~ismac




        set(this.fig,'Color',[238/230,234/230,222/213].*[r/255,g/255,b/255]);
    else
        set(this.fig,'Color',[r/255,g/255,b/255]);
    end

    prefSize=javaMethodEDT('getPreferredSize',java(this.prevPanelButtonPanel));
    prefHeight=prefSize.getHeight();

    [~,this.prevPanelButtonPanelContainer]=matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(java(this.prevPanelButtonPanel),...
    [1,1,figWidth,prefHeight],this.fig);

    set(this.prevPanelButtonPanelContainer,'Units','Pixels');


    this.statLabel=uicontrol('style','text','String','');
    set(this.statLabel,'BackgroundColor',[r/255,g/255,b/255]);
    this.statLabel.Visible='off';

    this.timeLabel=uicontrol('style','text','String','',...
    'Units','Normalized',...
    'HorizontalAlignment','right',...
    'BackgroundColor',get(this.fig,'Color'));
    set(this.timeLabel,'BackgroundColor',[r/255,g/255,b/255]);

    this.frameRateLabel=uicontrol('style','text','String','',...
    'Units','Normalized',...
    'HorizontalAlignment','left',...
    'BackgroundColor',get(this.fig,'Color'));
    set(this.frameRateLabel,'BackgroundColor',[r/255,g/255,b/255]);

    this.hideRuntimeLabels();

    if ispc


        defaults=javaMethodEDT('getLookAndFeelDefaults','javax.swing.UIManager');
        defaultFont=defaults.getFont('Label.font');
        set(this.statLabel,'FontName',char(defaultFont.getFontName));
        set(this.timeLabel,'FontName',char(defaultFont.getFontName));
        set(this.frameRateLabel,'FontName',char(defaultFont.getFontName));
    end


    set(this.fig,'HandleVisibility','callback');

    this.previewing=false;
    this.clearWindow('iatbrowser.RootNode',iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.SelectFormat'));
end
