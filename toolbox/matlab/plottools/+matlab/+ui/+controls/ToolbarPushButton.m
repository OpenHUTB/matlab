classdef(ConstructOnLoad)ToolbarPushButton<matlab.graphics.controls.AxesToolbarButton&...
    matlab.graphics.controls.internal.ToolTipMixin


    properties(NonCopyable)
        ButtonPushedFcn matlab.internal.datatype.matlab.graphics.datatype.Callback=[];
    end

    methods
        function obj=ToolbarPushButton(varargin)
            obj@matlab.graphics.controls.AxesToolbarButton(varargin{:});

            obj.Type='toolbarpushbutton';
        end
    end

    methods(Access=protected)
        function processActionEvent(obj,~,~)
            obj.processActionEvent@matlab.graphics.controls.AxesToolbarButton();

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
