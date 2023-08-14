function value=graphicsAndGuis(value)




    if~isempty(getenv('Decaf'))||~usejava('swing')
        value='off';
        return;
    end


    currentWarnings=eval('warning');


    warning('off');

    mlock;
    persistent webFigureRefreshSubscription;

    isActivated=~isempty(which('com.mathworks.matlabserver.jcp.GraphicsAndGuis'))&&com.mathworks.matlabserver.jcp.GraphicsAndGuis.isActivated;

    if strcmp(value,'on')==1&&~isActivated
        com.mathworks.matlabserver.connector.api.Connector.ensureServiceOn;
        rehash;

        mls.internal.feature('webGraphics','on');
        feature('enableHGUIJavaTesting',1);




        mls.internal.FigureUtils.enableCreatedListener();



        if isempty(webFigureRefreshSubscription)
            webFigureRefreshSubscription=message.subscribe('/embedded/figure/figureRefresh',@(varargin)(forceWebFigureRefresh()));
        end


        try
            if~isempty(which('cstprefs.tbxprefs'))
                h=cstprefs.tbxprefs;
                h.StartUpMsgBox.LTIviewer='off';
                h.StartUpMsgBox.SISOtool='off';
                h.PIDTunerPreferences.Version=2;
            end
        catch ignore
        end

        try
            if~isempty(which('controllibutils.CSTCustomSettings.setMOTWFlag'))
                controllibutils.CSTCustomSettings.setMOTWFlag(true);
            end
        catch ignore
        end

        try
            if~isempty(which('signal.internal.SPTCustomSettings.setDDGSupportFlag'))
                signal.internal.SPTCustomSettings.setDDGSupportFlag(false);
            end
        catch ignore
        end

        try
            if~isempty(which('phased.internal.PSTCustomSettings.setMOTWFlag'))
                phased.internal.PSTCustomSettings.setMOTWFlag(true);
            end
        catch ignore
        end

        try

            s=settings;
            if~isempty(s.findprop('matlab'))&&~isempty(s.matlab.findprop('imshow'))&&...
                ~isempty(s.matlab.imshow.findprop('AlwaysUseFitMagnification'))
                s.matlab.imshow.AlwaysUseFitMagnification.PersonalValue=true;
            end
        catch ignore
        end

        try

            s=settings;
            s.matlab.ui.figure.ShowInMATLABOnline.TemporaryValue=true;
        catch ignore
        end



        setenv("capabilities_avoidTiledLayout","true");


        javaMethodEDT('activate','com.mathworks.matlabserver.jcp.GraphicsAndGuis');

    elseif strcmp(value,'off')==1&&isActivated
        value='off';
        mls.internal.feature('webGraphics','off');

        javaMethodEDT('deactivate','com.mathworks.matlabserver.jcp.GraphicsAndGuis');

        feature('enableHGUIJavaTesting',0);
        mls.internal.FigureUtils.disableCreatedListener();
        if~isempty(webFigureRefreshSubscription)
            message.unsubscribe(webFigureRefreshSubscription);
            webFigureRefreshSubscription=[];
        end

        try

            if~isempty(which('cstprefs.tbxprefs'))
                h=cstprefs.tbxprefs;
                h.StartUpMsgBox.LTIviewer='on';
                h.StartUpMsgBox.SISOtool='on';
                h.PIDTunerPreferences.Version=2;
            end
        catch ignore
        end

        try
            if~isempty(which('controllibutils.CSTCustomSettings.setMOTWFlag'))
                controllibutils.CSTCustomSettings.setMOTWFlag(false);
            end
        catch ignore
        end

        try
            if~isempty(which('signal.internal.SPTCustomSettings.setDDGSupportFlag'))
                signal.internal.SPTCustomSettings.setDDGSupportFlag(true);
            end
        catch ignore
        end

        try
            if~isempty(which('phased.internal.PSTCustomSettings.setMOTWFlag'))
                phased.internal.PSTCustomSettings.setMOTWFlag(false);
            end
        catch ignore
        end

        try
            s=settings;
            if~isempty(s.findprop('matlab'))&&~isempty(s.matlab.findprop('imshow'))&&...
                ~isempty(s.matlab.imshow.findprop('AlwaysUseFitMagnification'))
                s.matlab.imshow.AlwaysUseFitMagnification.PersonalValue=false;
            end
        catch ignore
        end

        try

            s=settings;
            if(s.matlab.ui.figure.ShowInMATLABOnline.hasTemporaryValue())
                s.matlab.ui.figure.ShowInMATLABOnline.clearTemporaryValue();
            end
        catch ignore
        end

        setenv("capabilities_avoidTiledLayout","false");

    else

        if isActivated
            value='on';
        else
            value='off';
        end
    end


    eval('warning(currentWarnings);');


    function forceWebFigureRefresh()
        openFigs=get(groot,'Children');
        arrayfun(@(fig)mls.internal.figureCreated(fig),openFigs);
    end
end