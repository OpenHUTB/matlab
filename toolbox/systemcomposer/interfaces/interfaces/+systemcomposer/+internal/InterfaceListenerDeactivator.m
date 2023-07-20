classdef InterfaceListenerDeactivator<handle



    properties
        ddFullName;
    end

    methods
        function obj=InterfaceListenerDeactivator(ddName)
            obj.ddFullName=ddName;
            Simulink.SystemArchitecture.internal.DictionaryRegistry.UpdateSLDDListenerStatus(obj.ddFullName,false)
        end

        function delete(obj)
            Simulink.SystemArchitecture.internal.DictionaryRegistry.UpdateSLDDListenerStatus(obj.ddFullName,true)
        end
    end
end

