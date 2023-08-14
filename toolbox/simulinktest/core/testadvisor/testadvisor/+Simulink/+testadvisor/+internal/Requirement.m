classdef Requirement
    properties
        % the requirement object from simulink (slreq.Requirement)
        req_entity
        % the requirement Id
        Id
        % the requirement name
        Name
        % the path of the parent of the requirement
        parent_path
        % the path of the file containing the requirement
        parent_file
    end

    methods

        % Requirement contructor
        % Input(Name): the requirement name
        % Input(Id): the reuirement id
        % Input(parent_file): the parent file
        % Input(parent_path): the parent path
        % Output(obj): self
        function obj = Requirement(Name, Id, parent_file, parent_path)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
            else
                obj.Name = char(Name);
                obj.Id = char(Id);
                obj.parent_file = char(parent_file);
                obj.parent_path = char(parent_path);
                obj = obj.get_entity();
             end
        end
    end
    methods(Static, Access='public')

        % get parent filename
        % Input(req): the requirement
        % Output(filename): the parent filename
        function filename = get_parent_filename(req)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
            else
                if strcmp(class(req.parent), Simulink.testadvisor.internal.TestAdvisorUtils.REQSET_CLASS)
                    filename = req.parent.Filename;
                else
                    filename = Simulink.testadvisor.internal.Requirement.get_parent_filename(req.parent);
                end
             end
        end

        % make an id for a given requirement
        % Input(req): the requirement
        % Output(id): an id for the requirement
        function id = make_id(req)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
             else
                filename = char(Simulink.testadvisor.internal.Requirement.get_parent_filename(req));
                sid = num2str(req.SID);
                id = Simulink.testadvisor.internal.Requirement.make_id_raw(filename, sid);
             end
        end

        % helper function for make_id(), takes the filename and SID and
        %   concatinates them to form an ID. Every requirement in a file
        %   has a unique SID.
        % Input(filename): the filename of the requirement
        % Input(sid): the SID of the requirement
        % Output(id): an id for the requirement
        function id = make_id_raw(filename, sid)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
             else
                id = strcat(filename, '::', sid);
             end
        end
    end
    methods(Access='private')

        % get the slreq.Requirement assosiated with this requirement object
        % Input(obj): self
        % Output(obj): self
        function obj = get_entity(obj)
            obj.req_entity = 'none';
            rs = slreq.load(char(obj.parent_file));
            all_reqs = find(rs, 'Type', 'Requirement');
            for i=1:numel(all_reqs)
                req = all_reqs(i);
                current_id = Simulink.testadvisor.internal.Requirement.make_id(req);
                if strcmp(current_id, obj.Id)
                    fprintf('Discovered a req with Id %s, (SID is %d)\n', ...
                        req.Id, req.SID);
                    obj.req_entity = req;
                end
            end
            if strcmp(class(obj.req_entity), 'char')
                fprintf('Something went VERY wrong.\n');
            end
        end

    end
end
