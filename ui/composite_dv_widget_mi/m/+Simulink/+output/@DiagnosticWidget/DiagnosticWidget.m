classdef DiagnosticWidget<handle

    properties(Access=private)
        WidgetHandle=[];
        Hint=[0,0,0,1];
    end

    methods(Access=public)
        function this=DiagnosticWidget(widgetData,positionSpec,varargin)


            [position,moveOnResize]=Simulink.output.utils.internal.getPositionForSpec(positionSpec);
            this.WidgetHandle=Simulink.output.utils.internal.WidgetFactory.createWidget(widgetData,position,this.Hint,moveOnResize,varargin);
        end

        function show(this)
            this.WidgetHandle.show();
        end

        function setCloseCallback(this,fh)
            this.WidgetHandle.setClientCloseCallback(fh);
        end
    end

    methods(Hidden)

        function closeCallback(this)
            this.WidgetHandle.closeCallback();
        end
    end

    methods(Static)
        function config=getDefaultWidgetConfiguration()
            config=struct('Suppression',...
            struct('ClientHandlesJustification',false,...
            'isJustificationMandatory',true));
        end
    end
end