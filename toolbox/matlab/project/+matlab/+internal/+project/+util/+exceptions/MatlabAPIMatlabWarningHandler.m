
classdef MatlabAPIMatlabWarningHandler<...
    matlab.internal.project.util.exceptions.AutoConvertExceptionHandler

    properties(Access=protected)
        JavaClassName='com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIMatlabWarning';
    end

    methods(Access=protected)
        function handleMessageAndID(~,message,id,~)
            import matlab.internal.project.util.exceptions.Prefs;

            prevBackTrace=warning('query','backtrace');
            resetBactrace=onCleanup(@()warning('backtrace',prevBackTrace.state));
            if(Prefs.ShortenStacks)
                warning('backtrace','off');
            else
                warning('backtrace','on');
            end
            warning(id,'%s',message);
        end
    end

end
