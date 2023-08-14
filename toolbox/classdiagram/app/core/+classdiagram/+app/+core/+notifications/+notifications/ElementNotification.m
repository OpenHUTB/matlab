classdef(Abstract)ElementNotification<classdiagram.app.core.notifications.notifications.AbstractNotification

    methods(Access=public)
        function obj=ElementNotification(elements,options)
            obj@classdiagram.app.core.notifications.notifications.AbstractNotification(options)
            if isa(elements,'cell')
                elements=[elements{:}];
            end
            if isa(elements(1),'diagram.infrastructure.Element')
                elements=[elements.uuid];
            end
            obj.Target=struct('uuids',elements);
            obj.Transient=false;
        end

        function[map_path,topic_id]=getCSH(~)
            map_path='';topic_id='';
        end
    end
end
