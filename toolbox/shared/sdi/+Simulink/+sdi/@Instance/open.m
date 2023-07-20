function open(varargin)
    if Simulink.sdi.Instance.getSetGUIOpenningFlag()
        return;
    end


    persistent storage;
    if isempty(storage)
        storage=1;
        try
            if~Simulink.sdi.enableMultiAppMode
                locCloseIncompatiableApps();
            end


            bWasRunning=Simulink.sdi.Instance.isSDIRunning();
            gui=Simulink.sdi.Instance.getMainGUI(varargin{:});


            if~isempty(varargin)
                arg1=varargin{1};
                if isa(arg1,'Simulink.sdi.GUITabType')
                    gui.changeTab(arg1);
                end
            end

            if nargin>=5
                Simulink.sdi.cacheSTMComparison(...
                varargin{5});
                if bWasRunning
                    notify(Simulink.sdi.Instance.engine,...
                    'compareRunsEvent',...
                    Simulink.sdi.internal.SDIEvent('compareRunsEvent',...
                    {varargin{3},varargin{4},varargin{5}}));
                end
            end


            if bWasRunning
                gui.bringToFront();
            end


            eng=Simulink.sdi.Instance.engine();
            enableDisablePCTTimer(eng);
        catch me
            msg=message('SDI:sdi:SDILoadFailure',me.message);
            error(msg);
        end
        storage=[];
    end
end

function locCloseIncompatiableApps()



    try
        eval('signal.analyzer.Instance.close');
    catch me %#ok<NASGU>

    end
end