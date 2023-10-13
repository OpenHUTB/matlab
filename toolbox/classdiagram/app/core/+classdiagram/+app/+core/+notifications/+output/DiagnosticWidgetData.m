classdef DiagnosticWidgetData
    properties
        Diagnostic = '';
        Message = '';
        Severity = classdiagram.app.core.notifications.Severity.Error;
        Category = '';
        HelpFcn = '';
        SuppressFcn = '';
        Notification;
    end

    methods
        function obj = DiagnosticWidgetData( notification )
            arguments
                notification classdiagram.app.core.notifications.notifications.AbstractNotification;
            end

            obj.Notification = notification;
            obj.Message = notification.DisplayMessage;
            obj.Severity = notification.Severity;
            obj.Category = obj.FormatErrorId( notification.Category );

            obj.HelpFcn = @(  )helpWDFNotification( notification.help );
            obj.SuppressFcn = @(  )supressWDFNotification( notification.suppressFcn );

            function output = isFcnHandle( input )
                output = isa( input, 'function_handle' );
            end
        end

        function err = FormatErrorId( obj, errorId )
            arr = split( errorId, ':' );
            err = arr( end  );
        end

        function helpWDFNotification( helpFcn )
            helpFcn(  );
        end

        function ignoreWDFNotification( suppressFcn )
            suppressFcn(  );
        end
    end
end


