classdef WDFNotificationsErrorHandler<diagram.editor.command.ErrorHandler


    properties(Access=private)
        App;
        Notifier;
    end

    methods

        function obj=WDFNotificationsErrorHandler(app,notifier)
            obj=obj@diagram.editor.command.ErrorHandler;
            obj.App=app;
            obj.Notifier=notifier;
        end



        function issueError(obj,id,msg,request)
            origin=request.actionOrigin;
            if origin==diagram.editor.command.ActionOrigin.Server
                error(id,msg);
            else
                obj.Notifier.processNotification(...
                classdiagram.app.core.notifications.notifications.WDFCommandNotification(...
                id,msg));
            end
        end

    end
end