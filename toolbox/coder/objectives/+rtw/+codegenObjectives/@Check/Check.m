

classdef Check<handle
    properties(SetAccess=public)
        MAC=[];
        setting=[];
    end

    methods
        function check=Check(checkid,setting,objectiveName)
            check.MAC=[];
            check.setting=[];

            if nargin<3
                objectiveName='';
            end

            check.isCheckAllowed(checkid,objectiveName)

            check.MAC=checkid;

            if nargin==2
                check.setting=setting;
            end
        end
    end

    methods(Static=true)
        allowed=isCheckAllowed(check,objectiveName)
    end
end
