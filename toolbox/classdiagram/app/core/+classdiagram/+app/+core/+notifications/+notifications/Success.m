classdef Success<classdiagram.app.core.notifications.notifications.AbstractNotification
    properties(SetAccess=private)
        Modality(1,1)classdiagram.app.core.notifications.Modality...
        =classdiagram.app.core.notifications.Modality.MODELESS;
    end

    methods(Access=public)
        function obj=Success()
            obj@classdiagram.app.core.notifications.notifications.AbstractNotification({});
            obj.Severity=classdiagram.app.core.notifications.Severity.Success;
            obj.Target=struct("Diagram",classdiagram.app.core.notifications.Target.Diagram);
        end

        function createDiagnostic(obj,~)
            obj.Message='Success';
        end

        function[map_path,topic_id]=getCSH(~)
            map_path='';topic_id='';
        end

    end
end
