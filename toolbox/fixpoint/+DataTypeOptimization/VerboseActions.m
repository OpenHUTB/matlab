classdef(Abstract)VerboseActions<handle









    properties
messageLogger
    end

    methods
        function this=VerboseActions(logger)

            this.messageLogger=logger;
        end

        function publish(this,message,type)

            this.messageLogger.publish(message,type);
        end
    end
end