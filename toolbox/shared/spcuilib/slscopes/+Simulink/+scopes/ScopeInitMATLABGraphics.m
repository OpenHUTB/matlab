function ScopeInitMATLABGraphics(forceEnd)





    if~usejava('jvm')
        return;
    end

    import matlab.internal.lang.capability.Capability;
    persistent hfig haxis hpanel huicontrol huicontainer count;

    if nargin>0&&forceEnd
        if~isempty(hfig)&&ishghandle(hfig)
            delete(hfig);
        end
    elseif isempty(hfig)
        hfig=matlab.ui.Figure('Visible','off',...
        'Tag','ScopePreInitFigure',...
        'Name','ScopePreInitFigure',...
        'HandleVisibility','off');
        setappdata(hfig,'IgnoreCloseAll',2);
    elseif isempty(haxis)&&ishghandle(hfig)
        haxis=gca(hfig);
    elseif isempty(hpanel)&&ishghandle(hfig)
        hpanel=uipanel('Parent',hfig);
    elseif isempty(huicontrol)&&~isempty(hfig)&&ishghandle(hfig)
        huicontrol=uicontrol('Parent',hfig);
    elseif isempty(huicontainer)&&~isempty(hfig)&&ishghandle(hfig)
        huicontainer=uicontainer('Parent',hfig);
    elseif isempty(count)&&~isempty(haxis)&&ishghandle(haxis)
        haxis.TightInset;
        count=1;
    elseif ishghandle(hfig)
        if ishghandle(haxis)
            haxis.LooseInset;
        end

        matlab.graphics.animation.ScopeLineAnimator('Parent',haxis);
        matlab.graphics.animation.ScopeStairAnimator('Parent',haxis);
        matlab.graphics.animation.ScopeStemAnimator('Parent',haxis);
        delete(hfig);
        matlabshared.scopes.UnifiedScope.useWaitbar(false);
        ~Capability.isSupported(Capability.LocalClient);
    end


