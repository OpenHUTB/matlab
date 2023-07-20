
classdef Preferences

    properties(Dependent=true)
LogMessages
LogErrors
LogFolder
    end

    properties(GetAccess=private,SetAccess=private)
        Pref=com.mathworks.toolbox.slproject.project.prefs.global.log.ProjectLoggingPreference;
    end

    methods

        function value=get.LogMessages(obj)
            value=obj.Pref.areMessagesLogged();
        end

        function obj=set.LogMessages(obj,value)
            obj.Pref.setLogMessages(value);
        end

        function value=get.LogErrors(obj)

            value=obj.Pref.areErrorsLogged();
        end

        function obj=set.LogErrors(obj,value)

            obj.Pref.setLogErrors(value);
        end

        function value=get.LogFolder(obj)
            value=char(obj.Pref.getLogFolder());
        end

        function obj=set.LogFolder(obj,value)
            if(isempty(value))
                file=[];
            else
                file=java.io.File(value);
            end
            obj.Pref.setLogFolder(file);
        end

    end
end

