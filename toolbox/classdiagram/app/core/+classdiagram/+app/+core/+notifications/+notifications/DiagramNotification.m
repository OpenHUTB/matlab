classdef(Abstract)DiagramNotification<classdiagram.app.core.notifications.notifications.AbstractNotification
    properties(SetAccess=private)
        Modality(1,1)classdiagram.app.core.notifications.Modality...
        =classdiagram.app.core.notifications.Modality.MODELESS;
    end

    methods(Access=public)
        function obj=DiagramNotification(options)
            obj@classdiagram.app.core.notifications.notifications.AbstractNotification(options);
            obj.Target=struct("Diagram",classdiagram.app.core.notifications.Target.Diagram);
        end

        function[map_path,topic_id]=getCSH(~)
            map_path='';topic_id='';
        end
    end
end
