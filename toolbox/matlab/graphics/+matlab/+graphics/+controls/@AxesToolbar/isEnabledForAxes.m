

function result=isEnabledForAxes(obj,ax,button)
    result=true;


    fig=ancestor(obj,'figure');
    if isempty(fig)
        return;
    end

    if isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)...
        &&~isstruct(fig.ModeManager)
        mgr=fig.ModeManager;

        if~isempty(mgr.CurrentMode)&&strcmpi(mgr.CurrentMode.Name,'Standard.EditPlot')
            result=false;
            return;
        end
    end

    if isempty(button)||isempty(button.Tag)||isempty(ax)
        return;
    end


    var=obj.getBehaviorName(button.Tag);


    if isempty(var)
        return;
    end


    if isa(ax,'matlab.graphics.layout.Layout')&&~strcmp(var,'Copy')
        return;
    end

    if strcmp(var,'Reset')


        li=ax.GetLayoutInformation();
        if li.is2D
            modes={'Pan','Zoom'};
        else
            modes={'Pan','Zoom','Rotate3d'};
        end

        resetEnabled=false;

        for i=1:length(modes)
            bh=hggetbehavior(ax,modes{i},'-peek');
            if~isempty(bh)
                resetEnabled=resetEnabled||bh.Enable;
            else

                resetEnabled=resetEnabled||true;
            end
        end

        result=result&&resetEnabled;
        return;
    end



    if strcmp(var,'Rotate3d')
        li=ax.GetLayoutInformation();
        if isprop(button,'StayEnabled')&&~button.StayEnabled
            button.StayEnabled=~li.is2D;
        end


        hint=ax.hasInteractionHint(var);
        if strcmpi(hint,'on')
            button.StayEnabled=true;
        end

        if isprop(ax,'SortMethod_I')&&strcmpi(ax.SortMethod_I,'depth')
            button.StayEnabled=true;
        end

        result=button.StayEnabled;
    end



    bh=hggetbehavior(ax,var,'-peek');
    if~isempty(bh)
        if~bh.Enable
            result=false;
        end
    end


    if strcmp(var,'Brush')
        var='DataBrushing';
    end


    if strcmp(var,'DataCursor')||strcmp(var,'DataBrushing')

        hint=ax.hasInteractionHint(var);
        if isprop(button,'StayEnabled')&&~button.StayEnabled
            button.StayEnabled=result&&~isempty(hint)&&strcmp(hint,'on');
        end

        result=isprop(button,'StayEnabled')&&button.StayEnabled;



        hFig=ancestor(ax,'figure');
        if strcmp(var,'DataBrushing')&&matlab.internal.editor.figure.FigureUtils.isEditorSnapshotFigure(hFig)||...
            result&&isdeployed&&...
            matlab.ui.internal.isUIFigure(hFig)
            result=false;
        end



        if result&&strcmp(var,'DataCursor')&&...
            matlab.ui.internal.isUIFigure(hFig)
            result=false;
        end
    end


    if strcmp(var,'Copy')
        result=matlab.graphics.internal.export.isClipboardSupported;
    end


    if strcmp(var,'Export')
        result=isempty(getappdata(ax,'graphicsPlotyyPeer'));
    end
