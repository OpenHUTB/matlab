classdef propertyInspector<handle





    properties(Access=private)
InspectorHandle
    end

    methods(Static,Access=public)

        function result=getInstance
            persistent instance;
            if isempty(instance)
                instance=imaq.propertyInspector;
            end
            result=instance;
        end
    end

    methods(Access=public)
        function inspectorHandle=show(obj,videosourceToInspect)

            if~isempty(obj.InspectorHandle)
                obj.InspectorHandle.dispose();
            end
            obj.InspectorHandle=imaqgate('privatePropertyInspector',videosourceToInspect);
            inspectorHandle=obj.InspectorHandle;
        end
    end

end

