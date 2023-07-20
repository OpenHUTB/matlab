classdef Component
    properties
        % the handle for the component
        handle
        % the name of the component
        name
    end
    methods
        
        % Component constructor
        % Input(handle): the handle to the component
        % Output(obj): self
        function obj = Component(handle)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
             else
                obj.handle = handle;
                obj.name = getfullname(handle);
             end
        end
    end
end
