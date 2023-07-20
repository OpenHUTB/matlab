classdef SimulateSection<fusion.internal.scenarioApp.toolstrip.Section
    properties(SetAccess=private)
GoToStartButton
ForwardButton
BackwardButton
RunButton
    end

    methods
        function this=SimulateSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);

            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;

            this.Title=msgString(this,'SimulateSectionTitle');
            this.Tag='simulate';

            goToStart=Button(msgString(this,'GoToStartButtonText'),...
            Icon(fullfile(this.IconDirectory,'GoToStart24.png')));
            goToStart.Description=msgString(this,'GoToStartButtonDescription');
            goToStart.Tag='gotostart';
            goToStart.ButtonPushedFcn=hApp.initCallback(@this.goToStartCallback);
            goToStart.Enabled=false;
            this.GoToStartButton=goToStart;

            forward=Button(msgString(this,'StepForwardButtonText'),...
            Icon(fullfile(this.IconDirectory,'StepForward24.png')));
            forward.Description=msgString(this,'StepForwardButtonDescription');
            forward.Tag='forward';
            forward.ButtonPushedFcn=hApp.initCallback(@this.forwardCallback);
            forward.Enabled=false;
            this.ForwardButton=forward;

            backward=Button(msgString(this,'StepBackButtonText'),...
            Icon(fullfile(this.IconDirectory,'StepBackward24.png')));
            backward.Description=msgString(this,'StepBackButtonDescription');
            backward.Tag='stepback';
            backward.ButtonPushedFcn=hApp.initCallback(@this.backwardCallback);
            backward.Enabled=false;
            this.BackwardButton=backward;

            run=Button(msgString(this,'RunButtonText'),Icon.RUN_24);
            run.Description=msgString(this,'RunButtonDescription');
            run.Tag='runscene';
            run.Enabled=false;
            run.ButtonPushedFcn=hApp.initCallback(@this.runSceneCallback);
            this.RunButton=run;



            add(addColumn(this),goToStart);
            add(addColumn(this),backward);
            add(addColumn(this),run);
            add(addColumn(this),forward);
        end

        function update(this)


            isPlayable=~isempty(this.Application.getCurrentPlatform);
            isStarted=isPlaybackStarted(this.Application);
            isRunning=isPlaybackRunning(this.Application);
            isComplete=isPlaybackComplete(this.Application);
            isPaused=isPlaybackPaused(this.Application);

            updateButtons(this,isPlayable,isStarted,isRunning,isComplete,isPaused);

        end

    end

    methods(Access=protected)
        function updateButtons(this,isPlayable,isStarted,isRunning,isComplete,isPaused)
            this.GoToStartButton.Enabled=isStarted;
            this.ForwardButton.Enabled=~isRunning&&isPlayable&&~(isStarted&&isComplete);
            this.BackwardButton.Enabled=~isRunning&&isStarted;
            this.RunButton.Enabled=isPlayable;
            if isRunning
                this.RunButton.Icon=matlab.ui.internal.toolstrip.Icon.PAUSE_MATLAB_24;
                this.RunButton.Description=msgString(this,'PauseButtonDescription');
                this.RunButton.Text=msgString(this,'PauseButtonText');
            elseif isPaused&&~isComplete
                this.RunButton.Icon=matlab.ui.internal.toolstrip.Icon.CONTINUE_MATLAB_24;
                this.RunButton.Description=msgString(this,'ContinueButtonDescription');
                this.RunButton.Text=msgString(this,'ContinueButtonText');
            else
                this.RunButton.Icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
                this.RunButton.Description=msgString(this,'RunButtonDescription');
                this.RunButton.Text=msgString(this,'RunButtonText');
            end
        end

        function goToStartCallback(this,~,~)
            goToStart(this.Application);
        end

        function forwardCallback(this,~,~)
            stepForward(this.Application);
        end

        function backwardCallback(this,~,~)
            stepBackward(this.Application);
        end

        function runSceneCallback(this,~,~)
            run(this.Application);
        end
    end
end