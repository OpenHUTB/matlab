classdef SimulateSection<matlab.ui.internal.toolstrip.Section

    properties
        Repeat=false;
    end


    properties(SetAccess=protected, Hidden)
        Application
        RunButton
        StepButton
        StepBackButton
        ResetButton
        RepeatCheck
    end


    properties(Access=protected)
        ResetEnabled=false;
        NumRoadsChangedListener;
        NumActorsChangedListener;
        StateChangedListener
        SampleChangedListener
        ActorPropertyChangedListener;
    end

    methods
        function this=SimulateSection(hApplication)
            this.Application=hApplication;

            import matlab.ui.internal.toolstrip.*;
            this.Title=getString(message('Spcuilib:application:SimulateSectionTitle'));
            this.Tag='simulate';

            pathToIcon=hApplication.getPathToIcons;

            reset=Button(getString(message('driving:scenarioApp:GoToStartText')),...
                Icon(fullfile(pathToIcon,'GoToStart24.png')));
            reset.Description=getString(message('driving:scenarioApp:ResetDescription'));
            reset.Tag='reset';
            reset.ButtonPushedFcn=hApplication.initCallback(@this.resetCallback);
            reset.Enabled=false;
            sharedIcons=fullfile(toolboxdir('shared'),'spcuilib','applications','+matlabshared','+application');
            stepbackward=Button(getString(message('driving:scenarioApp:StepBackwardText')),...
                Icon(fullfile(sharedIcons,'StepBackward24.png')));
            stepbackward.Description=getString(message('driving:scenarioApp:StepBackwardDescription'));
            stepbackward.Tag='stepbackward';
            stepbackward.ButtonPushedFcn=hApplication.initCallback(@this.stepBackwardCallback);

            play=Button(getString(message('driving:scenarioApp:RunText')),Icon.RUN_24);
            play.Description=getString(message('driving:scenarioApp:RunDescription'));
            play.Tag='play';
            play.ButtonPushedFcn=hApplication.initCallback(@this.playCallback);

            stepforward=Button(getString(message('driving:scenarioApp:StepForwardText')),...
                Icon(fullfile(sharedIcons,'StepForward24.png')));
            stepforward.Description=getString(message('driving:scenarioApp:StepForwardDescription'));
            stepforward.Tag='stepforward';
            stepforward.ButtonPushedFcn=hApplication.initCallback(@this.stepForwardCallback);

            settings=Button(getString(message('driving:scenarioApp:SimulateSettingsText')),Icon.SETTINGS_16);
            settings.Description=getString(message('driving:scenarioApp:SimulateSettingsDescription'));
            settings.ButtonPushedFcn=hApplication.initCallback(@this.settingsCallback);
            settings.Tag='settings';

            repeat=CheckBox(getString(message('driving:scenarioApp:RepeatLabel')));
            repeat.Tag='repeat';
            repeat.Description=getString(message('driving:scenarioApp:RepeatDescription'));
            repeat.ValueChangedFcn=@this.repeatCallback;

            add(addColumn(this),reset);
            add(addColumn(this),stepbackward);
            add(addColumn(this,'Width',69,...
                'HorizontalAlignment','center'),play);
            add(addColumn(this),stepforward);

            column=addColumn(this);
            add(column,settings);
            add(column,repeat);
            add(column,EmptyControl);

            this.StepBackButton=stepbackward;
            this.RunButton=play;
            this.StepButton=stepforward;
            this.ResetButton=reset;
            this.RepeatCheck=repeat;
        end

        function attach(this)
            hApplication=this.Application;
            simulator=hApplication.Simulator;
            this.StateChangedListener=addStateChangedListener(simulator,@this.onStateChanged);
            this.SampleChangedListener=addSampleChangedListener(simulator,@this.onSampleChanged);
            this.NumRoadsChangedListener=event.listener(hApplication,'NumRoadsChanged',@this.onNumRoadsChanged);
            this.NumActorsChangedListener=event.listener(hApplication,'NumActorsChanged',@this.onNumActorsChanged);
            this.ActorPropertyChangedListener=event.listener(hApplication,'ActorPropertyChanged',@this.onActorPropertyChanged);
            update(this);
        end

        function detach(this)
            this.StateChangedListener=[];
            this.SampleChangedListener=[];
            this.NumRoadsChangedListener=[];
            this.NumActorsChangedListener=[];
            this.ActorPropertyChangedListener=[];
        end

        function update(this)
            updateButtons(this);
        end
    end

    methods(Access=protected)

        function settingsCallback(this,~,~)
            openSimulationSettings(this.Application);
        end

        function playCallback(this,~,~)


            hApplication=this.Application;
            hScenarioView=hApplication.ScenarioView;
            if hScenarioView.isInteracting
                hScenarioView.exitInteractionMode;
            end
            sensorCanvas=hApplication.SensorCanvas;
            if~isempty(sensorCanvas)
                sensorCanvas.InteractionMode='move';
            end
            player=hApplication.Simulator.Player;
            if player.IsPlaying
                pause(player);
            else

                focusOnComponent(hApplication.ScenarioView);
                drawnow
                play(player);
            end
        end

        function stepBackwardCallback(this,~,~)
            stepBackward(this.Application.Simulator);
        end

        function stepForwardCallback(this,~,~)
            stepForward(this.Application.Simulator);
        end

        function resetCallback(this,~,~)
            reset(this.Application.Simulator);
        end

        function repeatCallback(this,hcbo,~)
            this.Application.Simulator.Player.Repeat=hcbo.Selected;
        end

        function onNumRoadsChanged(this,~,~)
            updateButtons(this);
        end

        function onNumActorsChanged(this,~,~)
            updateButtons(this);
        end

        function onStateChanged(this,~,~)
            updateButtons(this);
        end

        function onActorPropertyChanged(this,~,ev)
            if any(strcmp(ev.Property,'Waypoints'))
                updateButtons(this);
            end
        end

        function onSampleChanged(this,~,~)
            newEnable=getCurrentSample(this.Application.Simulator)>1;
            if newEnable~=this.ResetEnabled
                this.StepBackButton.Enabled=newEnable;
                this.ResetButton.Enabled=newEnable;
                this.ResetEnabled=newEnable;
            end
        end

        function updateButtons(this)
            app=this.Application;
            simulator=app.Simulator;
            player=simulator.Player;
            scenarioView=app.ScenarioView;
            isInteracting=false;
            if~isempty(scenarioView)&&isvalid(scenarioView)
                isInteracting=scenarioView.isInteracting;
            end
            play=this.RunButton;
            sample=player.CurrentSample;


            if player.IsPlaying
                play.Icon=matlab.ui.internal.toolstrip.Icon.PAUSE_MATLAB_24;
                play.Text=getString(message('driving:scenarioApp:PauseText'));
                play.Description=getString(message('driving:scenarioApp:PauseDescription'));
            elseif player.IsPaused&&sample~=1
                play.Icon=matlab.ui.internal.toolstrip.Icon.CONTINUE_MATLAB_24;
                play.Text=getString(message('driving:scenarioApp:ContinueText'));
                play.Description=getString(message('driving:scenarioApp:ContinueDescription'));
            else
                play.Icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
                play.Text=getString(message('driving:scenarioApp:RunText'));
                play.Description=getString(message('driving:scenarioApp:RunDescription'));
            end


            isPlayEnabled=canRun(simulator);

            numSamples=player.NumSamples;
            isStepEnabled=isPlayEnabled;
            if isPlayEnabled
                if~this.Repeat&&~isnan(numSamples)
                    isStepEnabled=sample<numSamples;
                end
            end

            this.StepButton.Enabled=isStepEnabled&&~isInteracting;
            this.StepBackButton.Enabled=(player.IsPlaying||sample>1)&&...
                ~isInteracting;
            play.Enabled=isPlayEnabled&&~isInteracting;
            this.RepeatCheck.Enabled=isPlayEnabled;
        end
    end
end


