classdef NClassesRemovedInfo<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=NClassesRemovedInfo(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin);
        end

        function createDiagnostic(obj,varargin)
            requestedClasses=varargin{:}{1};
            if isa(requestedClasses,'classdiagram.app.core.domain.PackageElement')
                requestedClasses=arrayfun(@(c)string(c.getName),requestedClasses);
            elseif isa(requestedClasses,'char')
                requestedClasses=string(requestedClasses);
            end
            obj.Message=obj.getMsg(requestedClasses,'Removed');
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
            msg=msgObj;
        end
    end
end
