classdef Dependency
    properties
        % the dependency type
        type
        % the id of the source
        source_id
        % the id of the destination
        dest_id
        % the dependency id
        Id
        % the trigger type
        trigger
    end

    properties(Constant, Access='private')
        % seperator for ids, use this to make the final dependency id
        ID_SEPERATOR = '>>>'
    end

    methods(Static, Access='public')

        % make an id
        % Input(source_id): the id of the source
        % Input(dest_id): the id of the destination
        % Output(id): the id of the dependency
        function id = make_id(source_id, dest_id)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
             else
                id = strcat(source_id, Simulink.testadvisor.internal.Dependency.ID_SEPERATOR, dest_id);
             end
        end
    end

    methods
        
        % Dependency constructor
        % Input(type): the dependency ytpe
        % Input(source_id): the source id
        % Input(dest_id): the destination id
        % Input(trigger): the trigger type
        % Output(obj): self
        function obj = Dependency(type, source_id, dest_id, trigger)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
            else
                obj.type = char(type);
                obj.source_id = char(source_id);
                obj.dest_id = char(dest_id);
                obj.trigger = trigger;
                obj.Id = Simulink.testadvisor.internal.Dependency.make_id(obj.source_id, obj.dest_id);
             end
        end
    end
end
