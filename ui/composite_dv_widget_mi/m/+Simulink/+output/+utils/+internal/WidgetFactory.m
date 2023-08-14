classdef WidgetFactory<handle


    methods(Static=true,Access=public)
        function WidgetHandle=createWidget(widgetData,position,Hint,moveOnResize,varargin)

            varargin=varargin{1};


            isModal=false;
            config=Simulink.output.DiagnosticWidget.getDefaultWidgetConfiguration();

            if(length(varargin)>=1)
                if isa(varargin{1},'logical')
                    isModal=varargin{1};
                else
                    config=varargin{1};
                end
            end

            if(length(varargin)==2)
                if isa(varargin{2},'logical')
                    isModal=varargin{2};
                else
                    config=varargin{2};
                end
            end


            if isequal(isModal,true)
                WidgetHandle=Simulink.output.utils.internal.ModalWidget(widgetData,position,Hint,config);
            else
                WidgetHandle=Simulink.output.utils.internal.TransientWidget(widgetData,position,Hint,config,moveOnResize);
            end

        end

    end

end