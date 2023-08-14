
classdef ScopedWarningsSuppressor<handle






    properties(Access=private)
        oldWarnSetting;
        oldWarnMessage;
    end

    methods

        function obj=ScopedWarningsSuppressor()
            obj.oldWarnSetting=warning('off','all');
            obj.oldWarnMessage=lastwarn;
        end


        function delete(obj)
            warning(obj.oldWarnSetting);
            lastwarn(obj.oldWarnMessage);
        end
    end
end

