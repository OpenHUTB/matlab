classdef(ConstructOnLoad)PushButton<matlab.graphics.controls.AxesToolbarButton&...
    matlab.graphics.controls.internal.ToolTipMixin





    properties(NonCopyable)
        ButtonPushedFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=[];
    end

    properties(Dependent,Hidden)
        ClickedCallback;
    end

    methods
        function obj=PushButton(varargin)
            obj@matlab.graphics.controls.AxesToolbarButton(varargin{:});
        end



        function set.ClickedCallback(obj,val)
            obj.ButtonPushedFcn=val;
        end
    end

    methods(Access=protected)
        function processActionEvent(obj,~,~)
            if~isempty(obj.ButtonPushedFcn)
                eventData=matlab.graphics.controls.eventdata.ButtonPushedEventData(obj);
                try


                    hgfeval(obj.ButtonPushedFcn,obj,eventData);
                catch ex

                    warnState=warning('off','backtrace');
                    warning(message('MATLAB:graphics:axestoolbar:ErrorWhileEvaluating',ex.message,'ButtonPushedFcn'));
                    warning(warnState);
                end
            end
        end

        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Tooltip','Icon','ButtonPushedFcn'});
        end


        function label=getDescriptiveLabelForDisplay(obj)




            tooltipString=matlab.graphics.internal.convertStringToCharArgs(obj.Tooltip);
            label=tooltipString;
        end
    end
end
