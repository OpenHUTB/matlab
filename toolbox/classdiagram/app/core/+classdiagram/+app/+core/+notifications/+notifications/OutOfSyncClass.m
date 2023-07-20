classdef OutOfSyncClass<classdiagram.app.core.notifications.notifications.ElementNotification
    methods
        function obj=OutOfSyncClass(packageElements)
            uuids=arrayfun(@(e){e.getDiagramElementUUID},packageElements);
            classnames=arrayfun(@(e)string(e.getName),packageElements);
            obj=obj@classdiagram.app.core.notifications.notifications.ElementNotification(...
            uuids,classnames);
            obj.Severity=classdiagram.app.core.notifications.Severity.Warning;


            obj.UIMode=true;
        end

        function createDiagnostic(obj,classnames)
            if numel(classnames)==1
                obj.Message=classdiagram.app.core.notifications.notifications.makeCDVMessage(...
                'OutOfSyncClass',classnames);
            else
                obj.Message=message('classdiagram_editor:messages:OutOfSyncClass',...
                join(classnames,", "));
            end
        end

        function[map_path,topic_id]=getCSH(obj)
            map_path='';
            topic_id='';
        end

    end
end
