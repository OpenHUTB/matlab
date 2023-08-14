classdef NClassesAddedInfo<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=NClassesAddedInfo(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin);
        end

        function createDiagnostic(obj,varargin)
            inputs=varargin{1};
            requestedClasses=inputs{1};
            allClasses=inputs{2};
            if isa(requestedClasses,'classdiagram.app.core.domain.PackageElement')
                requestedClasses=arrayfun(@(c)string(c.getName),requestedClasses);
            elseif isa(requestedClasses,'char')
                requestedClasses=string(requestedClasses);
            end
            [existing,added]=obj.getSummary(requestedClasses,allClasses);
            obj.Message=strtrim(obj.getMsg(added,'Added')...
            +" "+obj.getMsg(existing,'Existing'));
        end
    end

    methods(Access=private)
        function[already,added]=getSummary(~,requestedClasses,all)
            idx=ismember(requestedClasses,all);
            already=requestedClasses(idx);
            added=requestedClasses(~idx);
        end

        function msg=getMsg(~,input,msgType)
            msg='';
            if isempty(input)||all(~strlength(input))
                return;
            end
            ret=numel(string(input));
            if ret==1
                msgObj=classdiagram.app.core.notifications.notifications.makeCDVMessage(...
                ['Class',msgType],string(input));
            else
                msgObj=classdiagram.app.core.notifications.notifications.makeCDVMessage(...
                ['NClasses',msgType],string(ret));
            end
            msg=msgObj.getString();
        end
    end
end
