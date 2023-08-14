classdef SaveOutputButton<simulink.internal.SLComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Started',...
'Stopped'...
        }
    end

    properties(Access=public)
        Icon='saveResults_24.png';
        Text=message('simulinkcompiler:simulink_components:SaveOutputButtonText').getString();



FontName
FontSize
FontWeight
FontAngle
FontColor
IconAlignment
HorizontalAlignment
VerticalAlignment
    end

    properties(Access={?slrealtime.ui.container.Menu,?simulink.internal.SLComponent})
        SaveButton matlab.ui.control.Button
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

PostStartedListener
PostStoppedListener
    end

    methods(Access=protected)
        function setup(obj)


            buttonWidth=90;
            buttonHeight=54;



            obj.Grid=uigridlayout(obj,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            obj.Grid.ColumnWidth={'1x'};
            obj.Grid.RowHeight={'1x'};



            obj.SaveButton=uibutton(obj.Grid,...
            'ButtonPushedFcn',@(o,e)obj.saveButtonPushed());
            obj.SaveButton.Layout.Row=1;
            obj.SaveButton.Layout.Column=1;
            obj.SaveButton.IconAlignment='top';
            obj.SaveButton.Text=obj.Text;
            obj.SaveButton.Icon=obj.Icon;



            obj.Position=[100,100,buttonWidth,buttonHeight];
            obj.FontName=obj.SaveButton.FontName;
            obj.FontSize=obj.SaveButton.FontSize;
            obj.FontWeight=obj.SaveButton.FontWeight;
            obj.FontAngle=obj.SaveButton.FontAngle;
            obj.FontColor=obj.SaveButton.FontColor;
            obj.IconAlignment=obj.SaveButton.IconAlignment;
            obj.HorizontalAlignment=obj.SaveButton.HorizontalAlignment;
            obj.VerticalAlignment=obj.SaveButton.VerticalAlignment;
            obj.BackgroundColor=obj.SaveButton.BackgroundColor;




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

            obj.SaveButton.FontName=obj.FontName;
            obj.SaveButton.FontSize=obj.FontSize;
            obj.SaveButton.FontWeight=obj.FontWeight;
            obj.SaveButton.FontAngle=obj.FontAngle;
            obj.SaveButton.FontColor=obj.FontColor;
            obj.SaveButton.IconAlignment=obj.IconAlignment;
            obj.SaveButton.HorizontalAlignment=obj.HorizontalAlignment;
            obj.SaveButton.VerticalAlignment=obj.VerticalAlignment;
            obj.SaveButton.BackgroundColor=obj.BackgroundColor;

            obj.SaveButton.Icon=obj.Icon;
            obj.SaveButton.Text=obj.Text;

            if obj.isDesignTime()

                obj.SaveButton.Enable='on';
                obj.SaveButton.Visible='on';
                obj.SaveButton.Tooltip=message('simulinkcompiler:simulink_components:SaveOutputButtonText').getString();

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
            if(tg.isTargetEmpty),return;end

            obj.PostStartedListener=listener(tg,'PostStarted',...
            @(src,evnt)disableButton(obj));

            obj.PostStoppedListener=listener(tg,'PostStopped',...
            @(src,evnt)enableButton(obj));
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(obj)
            obj.SaveButton.Enable='off';
            obj.SaveButton.Visible='on';
            obj.SaveButton.Tooltip=message('simulinkcompiler:simulink_components:InvalidTargetTooltip',...
            obj.GetTargetNameFcnH()).getString();
        end

        function enableControlForValidTarget(obj)
            obj.SaveButton.Enable='on';
            obj.SaveButton.Visible='on';
            obj.SaveButton.Tooltip=message('simulinkcompiler:simulink_components:SaveOutputButtonText').getString();

        end

        function updateGUI(obj,~)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty()
                obj.SaveButton.Enable='off';
                obj.SaveButton.Visible='on';
                return;
            end
            targetName=obj.GetTargetNameFcnH();

            if tg.isConnected()


                [isLoaded,loadedApp]=tg.isLoaded();
                isRunning=tg.isRunning();

                if isRunning

                    obj.SaveButton.Enable='off';
                    obj.SaveButton.Tooltip='';

                elseif isLoaded

                    if isempty(tg.SimulationOutput)
                        obj.SaveButton.Enable='off';
                    else
                        obj.SaveButton.Enable='on';
                    end

                    obj.SaveButton.Visible='on';
                    obj.SaveButton.Tooltip=message('simulinkcompiler:simulink_components:StartAppOnTarget',loadedApp,targetName).getString();

                else

                    obj.SaveButton.Enable='off';
                    obj.SaveButton.Visible='on';
                    obj.SaveButton.Tooltip=message('simulinkcompiler:simulink_components:SaveOutputButtonText').getString();

                end
            else

                obj.SaveButton.Enable='off';
                obj.SaveButton.Visible='on';
                obj.SaveButton.Tooltip=message('simulinkcompiler:simulink_components:SaveOutputButtonText').getString();


            end

            notify(obj,'GUIUpdated');
        end
    end

    methods(Access={?slrealtime.ui.container.Menu})
        function saveButtonPushed(obj)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty(),return;end

            try
                out=tg.SimulationOutput;

                if isempty(out)
                    obj.openProgressDlg(...
                    message('simulinkcompiler:simulink_components:OutputNotAvailable').getString(),...
                    message('simulinkcompiler:simulink_components:OutputNotAvailableDlgTitle').getString());
                else
                    [filename,pathname]=...
                    uiputfile({'*.mat','MAT-files (*.mat)'},...
                    message('simulinkcompiler:simulink_components:SaveOutputButtonText').getString(),'SimulationOutput.mat');

                    if~isequal(filename,0)&&~isequal(pathname,0)
                        obj.openProgressDlg(...
                        message('simulinkcompiler:simulink_components:SaveOutputInProgress').getString(),...
                        message('simulinkcompiler:simulink_components:SaveOutputInProgressDlgTitle').getString());
                        save(fullfile(pathname,filename),'out');
                        obj.closeProgressDlg();
                    else

                    end
                end

            catch ME
                obj.closeProgressDlg();
                obj.uialert(ME);
                return;
            end
        end
    end

    methods(Access=private)
        function enableButton(obj)
            obj.SaveButton.Enable='on';
        end

        function disableButton(obj)
            obj.SaveButton.Enable='off';
        end
    end
end
