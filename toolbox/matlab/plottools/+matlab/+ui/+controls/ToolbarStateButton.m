classdef(ConstructOnLoad)ToolbarStateButton<matlab.graphics.controls.AxesToolbarButton&...
    matlab.graphics.controls.internal.ToolTipMixin


    properties(NonCopyable)
        ValueChangedFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=[];
    end

    properties(SetObservable,Dependent,AbortSet)
        Value matlab.lang.OnOffSwitchState
    end

    properties(Access=private)
        Value_I matlab.lang.OnOffSwitchState;
    end

    methods
        function obj=ToolbarStateButton(varargin)
            obj@matlab.graphics.controls.AxesToolbarButton(varargin{:});

            obj.Value=false;

            obj.Type='toolbarstatebutton';
        end

        function Value=get.Value(obj)
            Value=obj.Value_I;
        end

        function set.Value(obj,Value)
            obj.Value_I=Value;

            if Value
                obj.Button.Content.ImageSource.Selected=true;
            else
                obj.Button.Content.ImageSource.Selected=false;
            end
        end
    end


    methods(Access={?qehgtools.internal.testers.QEHGAxesToggleButtonTester,?tToggleButton,?tAxesToolbar})
        function toggle(obj)
            if obj.Value
                obj.Value=false;
            else
                obj.Value=true;
            end
        end
    end

    methods(Access=protected)
        function processActionEvent(obj,~,~)
            obj.processActionEvent@matlab.graphics.controls.AxesToolbarButton();

            obj.toggle();

            if~isempty(obj.ValueChangedFcn)
                eventData=matlab.graphics.controls.eventdata.ValueChangedEventData(obj);
                try


                    hgfeval(obj.ValueChangedFcn,obj,eventData);
                catch ex

                    warnState=warning('off','backtrace');
                    warning(message('MATLAB:graphics:axestoolbar:ErrorWhileEvaluating',ex.message,'ValueChangedFcn'));
                    warning(warnState);
                end
            end



            if~isempty(obj)&&isvalid(obj)

                selChangeEvtData=matlab.graphics.controls.eventdata.SelectionChangedEventData(obj,obj.Parent.CurrentSelection);
                notify(obj.Parent,'SelectionChanged',selChangeEvtData);



                obj.Parent.CurrentSelection=obj;
            end
        end

        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Tooltip','Icon','ValueChangedFcn'});
        end


        function label=getDescriptiveLabelForDisplay(obj)




            tooltipString=matlab.graphics.internal.convertStringToCharArgs(obj.Tooltip);
            label=tooltipString;
        end
    end
end
