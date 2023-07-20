function UD=sl_command(UD,method)




    if isempty(UD.simulink)
        return;
    end

    modelH=UD.simulink.modelH;
    blockH=UD.simulink.subsysH;




    set(UD.dialog,'userdata',UD);

    switch(method)
    case 'start'
        switch get_param(modelH,'simulationStatus')
        case{'stopped','terminating','compiled'},
            set_param(modelH,'SimulationCommand','Start');
        case 'paused',
            set_param(modelH,'SimulationCommand','Continue');
            set(UD.toolbar.start,'Enable','off');
            set(UD.toolbar.pause,'Enable','on');
        otherwise,
            return;
        end

    case 'stop'
        switch get_param(modelH,'simulationStatus')
        case{'stopped','terminating'},

        otherwise,
            set_param(modelH,'SimulationCommand','Stop');
            set(UD.toolbar.start,'Enable','on');
            if strcmp(get_param(bdroot(gcbh),'InitializeInteractiveRuns'),'off')

                set(UD.toolbar.playall,'Enable','on');
            end
        end

    case 'pause'
        if~strcmpi(get_param(modelH,'SimulationStatus'),'Running'),return;end;
        set_param(modelH,'SimulationCommand','pause');
        set(UD.toolbar.pause,'Enable','off');
        set(UD.toolbar.start,'Enable','on');

    case 'save'
        try
            harnessOwner=Simulink.harness.internal.getHarnessOwnerBD(modelH);
            if~isempty(harnessOwner)&&~Simulink.harness.internal.isSavedIndependently(harnessOwner);
                modelH=get_param(harnessOwner,'Handle');
            end
            save_system(modelH);
        catch saveException
            errordlg(saveException.message);
        end

    case 'open'
        parent=get_param(blockH,'Parent');
        open_system(parent,'force');
        set_param(blockH,'Selected','On');

    otherwise,
        error(message('sigbldr_blk:sl_command:unknownMethod'));
    end



    UD=get(UD.dialog,'userdata');
