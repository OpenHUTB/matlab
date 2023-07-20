function value=webGraphics(value)







    mlock;
    persistent webGraphicsOn;
    persistent origDefaultMenubar;
    persistent origDefaultToolbar;
    if isempty(webGraphicsOn)
        webGraphicsOn=false;
    end
    if isempty(origDefaultMenubar)||isempty(origDefaultToolbar)
        origDefaultMenubar=get(groot,'DefaultFigureMenubar');
        origDefaultToolbar=get(groot,'DefaultFigureToolbar');
    end


    useWebGraphics=~isequal(...
    getenv("capabilities_avoidWebGraphics"),...
    "true");

    if(strcmp(value,'on')==1)&&~webGraphicsOn&&useWebGraphics
        set(groot,'DefaultFigureMenubar','none');
        set(groot,'DefaultFigureToolbar','auto');

        matlab.ui.internal.EmbeddedWebFigureStateManager.setEnabled(true);
        webGraphicsOn=true;


        matlab.graphics.internal.toolstrip.FigureToolstripManager.start;
    elseif strcmp(value,'off')==1
        set(groot,'DefaultFigureMenubar',origDefaultMenubar);
        set(groot,'DefaultFigureToolbar',origDefaultToolbar);

        matlab.ui.internal.EmbeddedWebFigureStateManager.setEnabled(false);
        webGraphicsOn=false;
        matlab.graphics.internal.toolstrip.FigureToolstripManager.stop;
    else

        if webGraphicsOn
            value='on';
        else
            value='off';
        end
    end
end