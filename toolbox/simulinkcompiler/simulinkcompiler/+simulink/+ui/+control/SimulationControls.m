classdef SimulationControls<simulink.internal.SLComponent







    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Started',...
        'Paused',...
        'Resumed',...
'Stopped'...
        }
    end

    properties
        StartText=message('simulinkcompiler:simulink_components:SimulationControlsRunText').getString()
        PauseText=message('simulinkcompiler:simulink_components:SimulationControlsPauseText').getString()
        ContinueText=message('simulinkcompiler:simulink_components:SimulationControlsContinueText').getString()

        StopText=message('simulinkcompiler:simulink_components:SimulationControlsStopText').getString()


        StartIcon='play_24.png'
        PauseIcon='pause_24.png'
        ContinueIcon='continue_24.png'
        StopIcon='stop_24.png'



FontName
FontSize
FontWeight
FontAngle
FontColor
IconAlignment
HorizontalAlignment
VerticalAlignment
Tooltip
    end

    properties(Access=private)



        Grid matlab.ui.container.GridLayout
        SPCButton matlab.ui.control.Button
        StopButton matlab.ui.control.Button
    end

    properties(Access=private,Transient,NonCopyable)
PostStartedListener
PostStoppedListener
    end

    methods(Access=protected)
        function setup(obj)

            obj.Grid=uigridlayout(obj,[1,2],...
            'ColumnWidth',{'1x','1x'},...
            'RowHeight',{'fit'},...
            'ColumnSpacing',2,...
            'Padding',2);


            obj.SPCButton=uibutton(obj.Grid,...
            'Text',obj.StartText,...
            'Icon',obj.StartIcon,...
            'Tooltip',message('simulinkcompiler:simulink_components:SimulationControlsTooltip').getString(),...
            'ButtonPushedFcn',@(o,e)obj.startPauseContinueButtonPushed());


            obj.StopButton=uibutton(obj.Grid,...
            'Text',obj.StopText,...
            'Icon',obj.StopIcon,...
            'Tooltip',message('simulinkcompiler:simulink_components:SimulationControlsTooltip').getString(),...
            'Enable','off',...
            'ButtonPushedFcn',@(o,e)obj.stopButtonPushed());

            obj.Position=[100,100,150,26];



            obj.FontName=obj.SPCButton.FontName;
            obj.FontSize=obj.SPCButton.FontSize;
            obj.FontWeight=obj.SPCButton.FontWeight;
            obj.FontAngle=obj.SPCButton.FontAngle;
            obj.FontColor=obj.SPCButton.FontColor;
            obj.IconAlignment=obj.SPCButton.IconAlignment;
            obj.HorizontalAlignment=obj.SPCButton.HorizontalAlignment;
            obj.VerticalAlignment=obj.SPCButton.VerticalAlignment;
            obj.Tooltip=obj.SPCButton.Tooltip;




            obj.tgListenerCreate=@obj.createListeners;
            obj.tgListenerDestroy=@obj.destroyListeners;
        end

        function update(obj)

            if obj.firstUpdate
                obj.firstUpdate=false;



                if isempty(obj.GetTargetNameFcnH)
                    obj.initTarget([]);
                end
            end

            obj.SPCButton.FontName=obj.FontName;
            obj.SPCButton.FontSize=obj.FontSize;
            obj.SPCButton.FontWeight=obj.FontWeight;
            obj.SPCButton.FontAngle=obj.FontAngle;
            obj.SPCButton.FontColor=obj.FontColor;
            obj.SPCButton.IconAlignment=obj.IconAlignment;
            obj.SPCButton.HorizontalAlignment=obj.HorizontalAlignment;
            obj.SPCButton.VerticalAlignment=obj.VerticalAlignment;
            obj.SPCButton.BackgroundColor=obj.BackgroundColor;

            obj.SPCButton.Icon=obj.StartIcon;
            obj.SPCButton.Text=obj.StartText;

            obj.StopButton.FontName=obj.FontName;
            obj.StopButton.FontSize=obj.FontSize;
            obj.StopButton.FontWeight=obj.FontWeight;
            obj.StopButton.FontAngle=obj.FontAngle;
            obj.StopButton.FontColor=obj.FontColor;
            obj.StopButton.IconAlignment=obj.IconAlignment;
            obj.StopButton.HorizontalAlignment=obj.HorizontalAlignment;
            obj.StopButton.VerticalAlignment=obj.VerticalAlignment;
            obj.StopButton.BackgroundColor=obj.BackgroundColor;
            obj.StopButton.Icon=obj.StopIcon;
            obj.StopButton.Text=obj.StopText;



            if obj.isDesignTime()

                obj.SPCButton.Enable='on';
                obj.SPCButton.Visible='on';
                obj.SPCButton.Tooltip='';
                obj.StopButton.Enable='off';
                obj.StopButton.Visible='off';
                obj.StopButton.Tooltip='';
            else
                obj.verifyTargetIsInitialised();

                obj.updateGUI([]);
            end
        end
    end

    methods(Access=private)
        function destroyListeners(obj)
            delete(obj.PostStartedListener);
            obj.PostStartedListener=[];

            delete(obj.PostStoppedListener);
            obj.PostStoppedListener=[];
        end

        function createListeners(obj)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            obj.PostStartedListener=listener(tg,'PostStarted',...
            @(src,evnt)closeProgressDlg(obj));

            obj.PostStoppedListener=listener(tg,'PostStopped',...
            @(src,evnt)closeProgressDlg(obj));
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(obj)
            obj.SPCButton.Enable='off';
            obj.SPCButton.Visible='on';
            obj.SPCButton.Tooltip=...
            message('simulinkcompiler:simulink_components:InvalidTargetTooltip',...
            obj.GetTargetNameFcnH()).getString();
            obj.StopButton.Enable='off';
            obj.StopButton.Visible='on';
        end

        function enableControlForValidTarget(obj)
            obj.SPCButton.Enable='on';
            obj.SPCButton.Tooltip='Control a Simulink simulation';
            obj.StopButton.Enable='off';
            obj.StopButton.Visible='on';
        end

        function updateGUI(obj,~)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty()
                obj.SPCButton.Enable='off';
                obj.SPCButton.Visible='on';
                obj.StopButton.Enable='off';
                obj.StopButton.Visible='on';
                return;
            end

            if tg.isConnected()


                isLoaded=tg.isLoaded();
                isRunning=tg.isRunning();

                if isRunning

                    obj.activatePause();

                elseif tg.isPaused()
                    obj.activateContinue();

                elseif isLoaded

                    obj.activateStart();

                else

                    obj.SPCButton.Enable='off';
                    obj.SPCButton.Visible='on';
                    obj.SPCButton.Tooltip='';
                    obj.StopButton.Enable='off';
                    obj.StopButton.Visible='on';
                    obj.StopButton.Tooltip='';
                end
            else

                obj.SPCButton.Enable='off';
                obj.SPCButton.Visible='on';
                obj.SPCButton.Tooltip='';
                obj.StopButton.Enable='off';
                obj.StopButton.Visible='on';
                obj.StopButton.Tooltip='';
            end

            notify(obj,'GUIUpdated');

            drawnow limitrate;
        end
    end

    methods(Access=private)
        function startPauseContinueButtonPushed(obj)
            import simulink.compiler.getSimulationStatus
            import slsim.SimulationStatus

            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            [~,loadedApp]=tg.isLoaded();
            targetName=obj.GetTargetNameFcnH();

            if tg.isInactive()
                obj.openProgressDlg(...
                message('simulinkcompiler:simulink_components:Starting').getString(),...
                message('simulinkcompiler:simulink_components:StartingApp',...
                loadedApp,targetName).getString());

                args={};
                try
                    tg.start(args{:});
                catch ME
                    obj.closeProgressDlg();
                    obj.uialert(ME);
                    return;
                end
            elseif tg.isRunning()
                tg.pause();

            elseif tg.isPaused()
                tg.resume();
            end

            drawnow limitrate;
        end

        function stopButtonPushed(obj)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty()||...
                tg.isStopped||...
                tg.isInactive
                return;
            end

            targetName=obj.GetTargetNameFcnH();

            [~,runningApp]=tg.isRunning();
            obj.openProgressDlg(...
            message('simulinkcompiler:simulink_components:Stopping').getString(),...
            message('simulinkcompiler:simulink_components:StoppingApp',...
            runningApp,targetName).getString());

            try
                tg.stop();
            catch ME
                obj.closeProgressDlg();
                obj.uialert(ME);
            end

            drawnow limitrate;
        end
    end

    methods(Access=private)
        function activateStart(obj)
            obj.SPCButton.Enable=true;
            obj.SPCButton.Icon=obj.StartIcon;
            obj.SPCButton.Text=obj.StartText;
            obj.StopButton.Enable=false;
            drawnow limitrate;
        end

        function activatePause(obj)
            obj.SPCButton.Enable=true;
            obj.SPCButton.Icon=obj.PauseIcon;
            obj.SPCButton.Text=obj.PauseText;
            obj.StopButton.Enable=true;
            drawnow limitrate;
        end

        function activateContinue(obj)
            obj.SPCButton.Enable=true;
            obj.SPCButton.Icon=obj.ContinueIcon;
            obj.SPCButton.Text=obj.ContinueText;
            obj.StopButton.Enable=true;
            drawnow limitrate;
        end

    end
end
