



classdef ViewSystemBrowser<simulinkcoder.internal.app.View
    methods
        function obj=ViewSystemBrowser(modelName)
            obj@simulinkcoder.internal.app.View(modelName);
        end

        function start(obj)
            start@simulinkcoder.internal.app.View(obj);
            if obj.DEBUG
                url=obj.DebugURL;
            else
                url=obj.URL;
            end
            web(url,'-browser');
        end
    end
end
