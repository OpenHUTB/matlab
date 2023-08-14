classdef ImpactAnalysis
     properties(Access='public')
        % a list of names of the tunable parameter constant blockss
        tunable_list
        % the name of the system being tested
        name
     end
    methods(Access='public')

        % ImpactAnalysis constructor
        % Input(name): the name of the system being tested
        % Output(obj): self
        function obj = ImpactAnalysis(name)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
             else
               obj.name = name;
               obj.tunable_list = {};
             end
        end

        % do the ImpactAnalysis
        % Input(obj): self
        % Input(tests): a list of the tests to run
        % Output(Nothing): Nothing
        function do_analysis(obj, tests)
            system_name = sprintf('%s_impact_analysis', obj.name);
            subsystem_name = sprintf('%s/%s', system_name, obj.name);
            new_system(system_name);
            open_system(system_name);
            add_block('built-in/Subsystem', subsystem_name);
            % FIXME: this causes a build (pcoding) error...
            % Simulink.BlockDiagram.copyContentsToSubsystem(obj.name, subsystem_name);
            components = Simulink.testadvisor.internal.TestAdvisorUtils.update_components(subsystem_name);
            keys = components.keys;
            for i=1:numel(keys)
                component = components(keys{i});
                ph = get_param(component.handle, 'PortHandles');
                obj = obj.make_new_subsystem(ph, component.name, i);
            end

            keys = tests.keys;
            for i=1:numel(keys)
                key = keys{i};
                % TODO: run tests and collect results!
                test = tests(key);
            end
            close_system(system_name, 0);
        end

        % create a new subsytem for every line in the block diagram, this
        %   was still under very active development and most likely has
        %   some serious bugs
        % Input(obj): self
        % Input(ph): the handle of the port
        % Input(name): the name of the model
        % Input(num): which line we are currently on (for naming)
        % Output(obj): self
        function obj = make_new_subsystem(obj, ph, name, num)
            for i=1:numel(ph)
                if ph(i).Outport
                    ophandle = ph(i).Outport;
                    lines_to_delete = get_param(ophandle, 'Line');
                    for j=1:numel(lines_to_delete)
                        line_to_delete = lines_to_delete(j);
                        if iscell(line_to_delete)
                            line_to_delete = lines_to_delete{j};
                        end
                        % if there is no line dont do anything.
                        if line_to_delete ~= - 1
                            dstport = get_param(line_to_delete, 'Dstporthandle');
                            port_num = get_param(dstport, 'PortNumber');
                            if isa(port_num, 'double')

                                parent_name = get_param(dstport, 'Parent');
                                dst_block = getSimulinkBlockHandle(parent_name);
                                dst_porthandels = get_param(dst_block, 'PortConnectivity');
                                src_positions = get_param(ophandle, 'Position');

                                src_position = src_positions(j);
                                if iscell(src_position)
                                    src_position = src_positions{j};
                                else
                                    src_position = src_positions;
                                end

                                the_handle = dst_porthandels(port_num);
                                % FIXME: this is a dumb temp fix for this
                                % corner case, absolutly not to be used
                                tmp_name = strrep(name, '//', '[DOUBLESLASH]');
                                tmp_lst = split(tmp_name, '/');
                                tmp_lst(end) = [];
                                base_name = join(tmp_lst, '/');
                                base_name = strrep(base_name, '[DOUBLESLASH]', '//');

                                % make names
                                switch_name = sprintf('%s/TmpSwitch%d_%d_%d', base_name{1}, i, num, j);
                                ground_name = sprintf('%s/TmpGround%d_%d_%d', base_name{1}, i, num, j);
                                constant_name = sprintf('%s/TmpConstant%d_%d_%d', base_name{1}, i, num, j);

                                obj.tunable_list(end+1) = {constant_name};

                                add_block('simulink/Commonly Used Blocks/Switch', switch_name);
                                add_block('simulink/Commonly Used Blocks/Ground', ground_name);
                                add_block('simulink/Commonly Used Blocks/Constant', constant_name);

                                % set correct params
                                set_param(constant_name, 'Value', '0');

                                constant_port = get_param(constant_name,'PortConnectivity');
                                ground_port = get_param(ground_name,'PortConnectivity');
                                switch_ports = get_param(switch_name,'PortConnectivity');

                                % add new lines
                                delete_line(line_to_delete);
                                add_line(base_name{1}, [src_position; switch_ports(1).Position]);
                                add_line(base_name{1}, [constant_port(1).Position; switch_ports(2).Position]);
                                add_line(base_name{1}, [ground_port(1).Position; switch_ports(3).Position]);
                                add_line(base_name{1}, [switch_ports(4).Position; the_handle.Position]);
                            end
                        end
                    end
                end
            end
        end
    end
end
