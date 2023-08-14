classdef WidgetFactory<handle

    properties
Configuration
    end

    methods
        function obj=WidgetFactory(config)
            obj.Configuration=config;
        end

        function mf0Widget=createMF0Widget(this,type,mf0Model)
            if~isfield(this.Configuration.WidgetTypes,type)
                fn=fieldnames(this.Configuration.WidgetTypes);
                error(message('dashboard:uidatamodel:UnknownType',...
                type,sprintf('[%s\b\b]',sprintf('"%s", ',fn{:}))));
            end
            mf0Widget=dashboard.ui.Widget(mf0Model);
            mf0Widget.Type=type;
        end

        function mlWiddget=createMLWidget(this,mf0Widget)
            constr=str2func(this.Configuration.WidgetTypes.(mf0Widget.Type));
            mlWiddget=constr(mf0Widget,this.Configuration);
        end
    end
end
