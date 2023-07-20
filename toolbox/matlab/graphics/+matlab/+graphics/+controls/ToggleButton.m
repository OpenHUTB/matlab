classdef(ConstructOnLoad)ToggleButton<matlab.graphics.controls.AxesToolbarButton&...
    matlab.graphics.controls.internal.ToolTipMixin





    properties(NonCopyable)
        ValueChangedFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=[];
    end

    properties(Hidden)
        OnCallback;
        OffCallback;
    end

    properties(SetObservable,Dependent,AbortSet)
        Value matlab.lang.OnOffSwitchState
    end


    properties(Hidden,Dependent)
OnImage
OffImage
    end

    properties(Access=private)
        Value_I matlab.lang.OnOffSwitchState;
    end


    properties(Hidden,Dependent)
State
    end

    methods
        function obj=ToggleButton(varargin)
            obj@matlab.graphics.controls.AxesToolbarButton(varargin{:});

            obj.Value=false;
        end

        function set.OnImage(this,value)
            this.Image=value;
        end


        function value=get.OnImage(this)
            value=this.Image;
        end


        function set.OffImage(this,value)
            this.Image=value;
        end


        function value=get.OffImage(this)
            value=this.Image;
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

        function state=get.State(obj)
            state=obj.Value;
        end

        function set.State(obj,val)
            obj.Value=val;
        end

    end


    methods(Access=public)
        function toggle(obj)
            if obj.Value
                obj.doOff();
            else
                obj.doOn();
            end
        end
    end

    methods(Access=protected)
        function doOff(obj)
            obj.Value=false;

            if~isempty(obj.OffCallback)
                feval(@obj.OffCallback,obj);
            end
        end

        function doOn(obj)
            obj.Value=true;

            if~isempty(obj.OnCallback)
                feval(@obj.OnCallback,obj);
            end
        end

        function processActionEvent(obj,~,~)
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

            selChangeEvtData=matlab.graphics.controls.eventdata.SelectionChangedEventData(obj,obj.Parent.CurrentSelection);
            notify(obj.Parent,'SelectionChanged',selChangeEvtData);



            obj.Parent.CurrentSelection=obj;
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
