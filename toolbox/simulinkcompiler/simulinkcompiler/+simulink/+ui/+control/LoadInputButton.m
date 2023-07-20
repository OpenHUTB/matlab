classdef LoadInputButton<simulink.internal.SLComponent




    properties
        InputLoadedFcn=@(src,event){}
    end

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

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout
        InputButton matlab.ui.control.Button
PostStartedListener
PostStoppedListener
    end

    methods(Access=private)
        function isValid=validateInput(var)
            isValid=isa(var,'timeseries')||...
            isa(var,'Simulink.SimulationData.Dataset')||...
            is(var,'struct');
        end
    end

    properties(Access=public)
        Icon='loadInput_24.png';
        Text=message('simulinkcompiler:simulink_components:LoadInputButtonText').getString();



FontName
FontSize
FontWeight
FontAngle
FontColor
IconAlignment
HorizontalAlignment
VerticalAlignment
        Enable='on'
    end


    methods(Access=protected)

        function setup(obj)
            buttonWidth=90;
            buttonHeight=54;

            obj.Grid=uigridlayout(obj,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            obj.Grid.ColumnWidth={'1x'};
            obj.Grid.RowHeight={'1x'};


            obj.InputButton=uibutton(obj.Grid,...
            'ButtonPushedFcn',@(o,e)obj.ButtonPushed());
            obj.InputButton.Layout.Row=1;
            obj.InputButton.Layout.Column=1;
            obj.InputButton.IconAlignment='top';
            obj.InputButton.Text=obj.Text;
            obj.InputButton.Icon=obj.Icon;
            obj.InputButton.Enable=obj.Enable;



            obj.Position=[100,100,buttonWidth,buttonHeight];
            obj.FontName=obj.InputButton.FontName;
            obj.FontSize=obj.InputButton.FontSize;
            obj.FontWeight=obj.InputButton.FontWeight;
            obj.FontAngle=obj.InputButton.FontAngle;
            obj.FontColor=obj.InputButton.FontColor;
            obj.IconAlignment=obj.InputButton.IconAlignment;
            obj.HorizontalAlignment=obj.InputButton.HorizontalAlignment;
            obj.VerticalAlignment=obj.InputButton.VerticalAlignment;
            obj.BackgroundColor=obj.InputButton.BackgroundColor;

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

            obj.InputButton.FontName=obj.FontName;
            obj.InputButton.FontSize=obj.FontSize;
            obj.InputButton.FontWeight=obj.FontWeight;
            obj.InputButton.FontAngle=obj.FontAngle;
            obj.InputButton.FontColor=obj.FontColor;
            obj.InputButton.IconAlignment=obj.IconAlignment;
            obj.InputButton.HorizontalAlignment=obj.HorizontalAlignment;
            obj.InputButton.VerticalAlignment=obj.VerticalAlignment;
            obj.InputButton.BackgroundColor=obj.BackgroundColor;
            obj.InputButton.Enable=obj.Enable;

            obj.InputButton.Icon=obj.Icon;
            obj.InputButton.Text=obj.Text;

            drawnow limitrate;

            if obj.isDesignTime()

                obj.InputButton.Enable=obj.Enable;
                obj.InputButton.Visible='on';
                obj.InputButton.Tooltip='';
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
            @(src,evnt)disableButton(obj));

            obj.PostStoppedListener=listener(tg,'PostStopped',...
            @(src,evnt)restoreButtonState(obj));
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(obj)
            obj.InputButton.Enable='off';
            obj.InputButton.Visible='on';
            obj.InputButton.Tooltip=message('simulinkcompiler:simulink_components:InvalidTargetTooltip',...
            obj.GetTargetNameFcnH()).getString();
        end

        function enableControlForValidTarget(obj)
            obj.InputButton.Enable='on';
            obj.InputButton.Visible='on';
            obj.InputButton.Tooltip=message('simulinkcompiler:simulink_components:LoadInputButtonText').getString();

        end

        function updateGUI(obj,~)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty()
                obj.InputButton.Enable='off';
                obj.InputButton.Visible='on';
                return;
            end

            if tg.isConnected()


                isLoaded=tg.isLoaded();
                isRunning=tg.isRunning();

                if isRunning

                    obj.InputButton.Enable='off';
                    obj.InputButton.Tooltip=message('simulinkcompiler:simulink_components:LoadInputButtonText').getString();


                elseif isLoaded

                    obj.InputButton.Enable=obj.Enable;
                    obj.InputButton.Visible='on';

                else

                    obj.InputButton.Enable='off';
                    obj.InputButton.Visible='on';
                    obj.InputButton.Tooltip=message('simulinkcompiler:simulink_components:LoadInputButtonText').getString();


                end
            else

                obj.InputButton.Enable='off';
                obj.InputButton.Visible='on';
                obj.InputButton.Tooltip=message('simulinkcompiler:simulink_components:LoadInputButtonText').getString();


            end

            notify(obj,'GUIUpdated');
        end
    end

    methods(Access=private)
        function ButtonPushed(obj)
            tg=obj.tgGetTargetObject();
            if tg.isTargetEmpty()
                return;
            end


            simIn=tg.SimulationInput;


            [file,path]=uigetfile('*.mat');
            if isequal(file,0)

                filepath='';
            else

                filepath=fullfile(path,file);
            end

            if~isempty(filepath)

                matfileObj=matfile(filepath);
                varlist=who(matfileObj);

                for index=1:numel(varlist)

                    try
                        simIn=simIn.setExternalInput(matfileObj.(varlist{index}));
                        simulink.compiler.internal.validateExternalInput(simIn);
                        tg.SimulationInput=simIn;

                        if isa(obj.InputLoadedFcn,"function_handle")

                            obj.InputLoadedFcn(obj,[]);
                            drawnow limitrate;
                        end
                    catch ME
                        obj.uialert(ME);
                    end
                end
            end
        end
    end

    methods(Access=private)
        function restoreButtonState(obj)
            obj.InputButton.Enable=obj.Enable;
        end

        function disableButton(obj)
            obj.InputButton.Enable='off';
        end
    end
end

