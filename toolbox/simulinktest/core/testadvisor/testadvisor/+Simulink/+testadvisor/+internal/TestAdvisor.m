classdef TestAdvisor
    % TODO: IMPORTANT --- this file is too long NEED to delegate things to
    % other files
    properties(Access='public')
        % pretty name
        name
        % universal unique id
        uuid
        % model path
        % TODO: add this.
        model_path
        % Paths where tests live, a list of files and directories
        test_paths
        % Paths where requirements live, a list of files and directories
        req_paths
        % simulink tests
        sltests
        % requirements
        reqs
        % system
        components
        % dependencies
        deps
        % block diagram
        bd
    end

    properties(Access='private')
        discovered_sltest_files
        discovered_sltests
        discovered_req_sets
        discovered_reqs
        test_harnesses
    end

    properties(Constant, Access='private')
        % For canned example, remove
        CHANGED_COMPS = [string('untitled/Multiply')];
    end

    properties(Constant, Access='private')
        % these are constants that eventually should go into
        % /matlab/resources/sltest/en/testadvisor.xml
        TEST_FILE_CLASS = 'sltest.testmanager.TestFile'
        TEST_SUITE_CLASS = 'sltest.testmanager.TestSuite'
        TEST_CASE_CLASS = 'sltest.testmanager.TestCase'
        TA_REQ_CLASS = 'Simulink.testadvisor.internal.Requirement'
        CURRENT_TEST_HEADER = 'Current Tests'
        CURRENT_REQ_HEADER = 'Current Reqs'
        DISCOVERED_TEST_HEADER = 'Discovered Tests'
        DISCOVERED_REQ_HEADER = 'Discovered Reqs'
        TEST_PATHS_HEADER = 'Test Path'
        REQ_PATHS_HEADER = 'Requirement Path'
        CURRENT_COMPONENTS_HEADER = 'Components'
        DEP_HEADER = 'Dependencies'
        TEST_CASE = 'TestCase'
        TEST_SUITE = 'TestSuite'
        PATH_QUESTION_STR = 'Which path [1,2...n]? '
        COMP_QUESTION_STR = 'Which component [1,2...n]? '
        TEST_QUESTION_STR = 'Which test [1,2...n]? '
        CONTINUE_QUESTION_STR = 'Continue Y/N [Y]:'
        FAILED = sltest.testmanager.TestResultOutcomes.Failed
        PASSED = sltest.testmanager.TestResultOutcomes.Passed
        DISCOVERED_TESTS_CHOICE = '1'
        CURRENT_TESTS_CHOICE = '2'
        DISCOVERED_REQS_CHOICE = '3'
        CURRENT_REQS_CHOICE = '4'
        COMPONENT_CHOICE = '5'
        REQTOTEST = 'ReqToTest'
        TESTTOTEST = 'TestToTest'
        % QUESTION: Are these three needed?
        % REQTOREQ = 'ReqToReq'
        % COMPTOREQ = 'CompToReq'
        % COMPTOCOMP = 'CompToComp'
        COMPTOTEST = 'CompToTest'
        TESTMNGRLINK = 'linktype_rmi_testmgr';
    end

    methods(Static, Access='private')

        % Id function for tests
        % Input(test): the test
        % Output(id): the test id
        function id = test_id_func(test)
            id = test.TestPath;
        end

        % Id function for requirements
        % Input(test): the requirement
        % Output(id): the requirement id
        function id = req_id_func(req)
            id = req.Id;
        end

        % Id function for dependencies
        % Input(test): the dependency
        % Output(id): the dependency id
        function id = dep_id_func(dep)
            id = dep.Id;
        end

        % Id function for components
        % Input(test): the component
        % Output(id): the component id
        function id = component_id_func(comp)
            % FIXME: this is goofy, should do better
            id = comp.name;
        end

        % function to choose a dependency type
        % Input(msg_str): the msg to print (from where/to where)
        % Output(choice): the user's choice
        function choice = dep_categories(msg_str)
            fprintf('1. Discovered Tests\n');
            fprintf('2. Current Tests\n')
            fprintf('3. Discovered Requirements\n')
            fprintf('4. Current Requirements\n')
            fprintf('5. Component\n')
            prompt = input(msg_str);
            if prompt >= 1 && prompt <= 5
                choice = num2str(prompt);
            else
                fprintf('Invalid Choice...')
                choice = '-1';
            end
        end
    end

    methods(Access='public')
        % TestAdvisor constructor
        % Input(name): the model name
        % Input(model_path): the model path
        % Input(uuid): the uuid for the TA (Not currently used)
        % Input(test_paths_arg): the test paths
        % Input(req_paths_arg): the requirement paths
        % Input(sltests_arg): a list of tetss
        % Input(reqs_arg): a list of requirements
        % Input(deps_arg): a list of dependencies
        % Output(obj): the TestAdvisor object
        function obj = TestAdvisor(name, model_path, uuid, test_paths_arg, ...
                req_paths_arg, ...
                sltests_arg, reqs_arg, deps_arg)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
            else
                obj.uuid = string(uuid);
                obj.name = string(name);
                obj.model_path = string(model_path);

                % get block handles
                obj.components =  ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.update_components(obj.name);

                % load system
                fprintf('Loading System...');
                if ~bdIsLoaded(name)
                    open_system(model_path);
                end
                fprintf('Done.\n');

                obj.test_paths = test_paths_arg;
                obj.req_paths = req_paths_arg;

                % initialize lists
                obj.discovered_sltest_files = {};
                obj.discovered_req_sets = {};
                obj.test_harnesses = {};

                % initialize maps
                obj.deps = ...
                    containers.Map('KeyType','char','ValueType','any');
                obj.sltests = ...
                    containers.Map('KeyType','char','ValueType','any');
                obj.discovered_sltests = ...
                    containers.Map('KeyType','char','ValueType','any');
                obj.reqs = ...
                    containers.Map('KeyType','char','ValueType','any');
                obj.discovered_reqs = ...
                    containers.Map('KeyType','char','ValueType','any');

                % init sltest Map
                for i=1:numel(sltests_arg)
                    current_test = sltests_arg{i};
                    obj.sltests(char(current_test.TestPath)) = current_test;
                end

                % init req map
                for i=1:numel(reqs_arg)
                    current_req = reqs_arg{i};
                    obj.reqs(char(current_req.Id)) = current_req;
                end

                % init dep_map
                for i=1:numel(deps_arg)
                    current_dep = deps_arg{i};
                    obj.deps(current_dep.Id) = current_dep;
                end

                % 'discover' requirements and tests
                obj = obj.parse_test_paths();
                obj = obj.parse_req_paths();
                obj = obj.get_test_harnesses();
            end
        end

        % Perform Impact Analysis (see ImpactAnalysis.m)
        % Input(obj): self
        % Output(obj): self
        function obj = perform_impact_analysis(obj)
            all_tests = ...
                containers.Map('KeyType','char','ValueType','any');
            keys = obj.sltests.keys;
            for i=1:numel(keys)
                key = keys{i};
                all_tests(key) = obj.sltests(key);
            end
            keys = obj.discovered_sltests.keys;
            for i=1:numel(keys)
                key = keys{i};
                all_tests(key) = obj.discovered_sltests(key);
            end
            ia = Simulink.testadvisor.internal.ImpactAnalysis(obj.name);
            ia.do_analysis(all_tests);
        end

        % add all discovered tests to the current tests (sltests)
        % Input(obj): self
        % Output(obj): self
        function obj = add_all_discovered_tests(obj)
            if Simulink.testadvisor.internal.TestAdvisorUtils.yes_no_question('Add all discovered tests to TA?')
                keys = obj.discovered_sltests.keys;
                for i=1:numel(keys)
                    key = keys{i};
                    obj.sltests(key) = obj.discovered_sltests(key);
                    obj.discovered_sltests.remove(key);
                end
            end
        end

        % add all discovered requirements to the current tests (reqs)
        % Input(obj): self
        % Output(obj): self
        function obj = add_all_discovered_reqs(obj)
            if Simulink.testadvisor.internal.TestAdvisorUtils.yes_no_question( ...
                    'Add all discovered requirements to TA?')
                keys = obj.discovered_reqs.keys;
                for i=1:numel(keys)
                    key = keys{i};
                    obj.reqs(key) = obj.discovered_reqs(key);
                    obj.discovered_reqs.remove(key);
                end
            end
        end

        % Find test harnesses from the model
        % Input(obj): self
        % Output(obj): self
        function obj = get_test_harnesses(obj)
            harness_list = sltest.harness.find(obj.name,'SearchDepth', ...
                1, 'Name', '_[Hh]arnes+', 'RegExp', 'on');
            for i=1:numel(harness_list)
                obj.test_harnesses(end+1) = {harness_list(i)};
                % QUESTION: should I load this harness?
                fprintf('Loading test harness "%s".\n', harness_list(i).name);
                sltest.harness.load(obj.name, harness_list(i).name);
            end
        end

        % print discoverd tests
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_discovered_tests(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_map(obj.discovered_sltests, ...
                Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_TEST_HEADER, ...
                @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
        end

        % print discoverd requirements
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_discovered_reqs(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_map(obj.discovered_reqs, ...
                Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_REQ_HEADER, ...
                @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
        end

        % print tests
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_tests(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_map(obj.sltests, ...
                Simulink.testadvisor.internal.TestAdvisor.CURRENT_TEST_HEADER, ...
                @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
        end

        % print requirements
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_reqs(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_map(obj.reqs, ...
                Simulink.testadvisor.internal.TestAdvisor.CURRENT_REQ_HEADER, ...
                @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
        end

        % print discoverd dependencies
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_deps(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_map(obj.deps, ...
                Simulink.testadvisor.internal.TestAdvisor.DEP_HEADER, ...
                @Simulink.testadvisor.internal.TestAdvisor.dep_id_func);
        end

        % print model components
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_model_components(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_map(obj.components, ...
                Simulink.testadvisor.internal.TestAdvisor.CURRENT_COMPONENTS_HEADER, ...
                @obj.component_id_func);
        end

        % print test paths
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_test_paths(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_lst(obj.test_paths, ...
                Simulink.testadvisor.internal.TestAdvisor.TEST_PATHS_HEADER);
        end

        % print requirement paths
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_req_paths(obj)
            Simulink.testadvisor.internal.TestAdvisorUtils.print_lst(obj.req_paths, ...
                Simulink.testadvisor.internal.TestAdvisor.REQ_PATHS_HEADER);
        end

        % print linked to a chosen requirement
        % Input(obj): self
        % Output(Nothing): Nothing
        function list_tests_linked_to_chosen_req(obj)
            req = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.reqs, ...
                'Which requirement? [1,2,...n]: ', ...
                @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
            obj.list_tests_linked_to_req(req)
        end

        % list all tests to a given requirement
        % Input(obj): self
        % Input(current_req): the requirement
        % Output(Nothing): Nothing
        function list_tests_linked_to_req(obj, current_req)
            tests = obj.get_tests_linked_to_req(current_req);
            for i=1:numel(tests)
                fprintf('%s\n', tests{i}.TestPath);
            end
        end

        % Get tests that are dependent on a given test (recursive)
        % Input(obj): self
        % Input(current_test): the source test
        % Input(current_lst): the list of dependent tests
        % Output(tests): a list of all dependent tests
        function tests = get_dep_tests(obj, current_test, current_lst)
            dep_keys = obj.deps.keys;
            for i=1:numel(dep_keys)
                key = dep_keys{i};
                current_dep = obj.deps(key);
                if strcmp(current_dep.source_id, current_test.TestPath)
                    found_test = obj.find_test(current_dep.dest_id);
                    % NOTE: this might be Wront!
                    if strcmp(class(found_test), 'Simulink.testadvisor.internal.sltest')
                        current_lst(end+1) = {found_test};
                        current_lst = horzcat(current_lst, ...
                            obj.get_dep_tests(found_test, {}));
                    end
                end
            end
            tests = current_lst;
        end

        % find a test from an id
        % Input(obj): self
        % Input(test_id): the test id
        % Output(test): the test
        function test = find_test(obj, test_id)
            if ismember(test_id, obj.sltests.keys)
                test = obj.sltests(test_id);
            elseif ismember(test_id, obj.discovered_sltests.keys)
                test = obj.discovered_sltests(test_id);
            else
                test = Simulink.testadvisor.internal.TestAdvisorUtils.NONE;
            end
        end

        % get requirements from a given component
        % Input(obj): self
        % Input(comp): the component
        % Output(reqs): the list of requirements
        function reqs = get_reqs_from_component(obj, comp)
            reqs = {};
            % NOTE: internal slreq call
            reqData = slreq.data.ReqData.getInstance();
            % NOTE: internal slreq call
            [in_links, out_links] = reqData.getLinksForNonReqItem(comp.handle);
            for i=1:numel(out_links)
                filepath = out_links(i).dest.getReqSet.filepath;
                sid = num2str(out_links(i).dest.sid);
                id = Simulink.testadvisor.internal.Requirement.make_id_raw(filepath, sid);
                if ismember(id, obj.reqs.keys)
                    reqs(end+1) = {obj.reqs(id)};
                elseif ismember(id, obj.discovered_reqs.keys)
                    reqs(end+1) = {obj.discovered_reqs(id)};
                end
            end
        end

        % get requirements from a chosen component
        % Input(obj): self
        % Output(reqs): the list of requirements
        function reqs = get_reqs_from_chosen_component(obj)
            comp = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.components, ...
                Simulink.testadvisor.internal.TestAdvisor.COMP_QUESTION_STR, ...
                @Simulink.testadvisor.internal.TestAdvisor.component_id_func);
            reqs = obj.get_reqs_from_component(...
                comp);
        end

        % Get all changed components (NOTE: currently a canned example)
        % Input(obj): self
        % Output(changed_comps): a list of changed components
        function changed_comps = get_changed_components(obj)
            % NOTE: this is a canned example for now!
            % TODO: develop this
            changed_comps = obj.CHANGED_COMPS;
        end

        % get tests that are dependent on components in a list
        % Input(obj): self
        % Input(comp_names): a list of components names
        % Output(tests): the dependent tests
        function tests = get_tests_from_components(obj, comp_names)
            comp_lst = {};
            for i=1:numel(comp_names)
                comp_lst(end+1) = {obj.components(comp_names(i))};
            end
            tests = {};
            for i=1:numel(comp_lst)
                comp = comp_lst{i};
                dep_keys = obj.deps.keys;
                for j=1:numel(dep_keys)
                    key = dep_keys{j};
                    if contains(obj.deps(key).Id, comp.name)
                        test_id = obj.deps(key).dest_id;
                        if contains(obj.discovered_sltests.keys, test_id)
                            tests(end+1) = obj.discovered_sltests(test_id);
                        elseif contains(obj.sltests.keys, test_id)
                            tests(end+1) = obj.sltests(test_id);
                        end
                    end
                end
                comp_reqs = obj.get_reqs_from_component(comp_lst{i});
                for j=1:numel(comp_reqs)
                    found_reqs = obj.get_tests_linked_to_req(comp_reqs{j});
                    for k=1:numel(found_reqs)
                        test = found_reqs{k};
                        tests(end+1) = {test};
                    end
                end
            end
        end

        % get tests dependent on a given component
        % Input(obj): self
        % Input(comp): the component
        % Output(tests): the dependent tests
        function tests = get_tests_from_component(obj, comp)
            comp_reqs = obj.get_reqs_from_component(comp);
            tests = {};
            for i=1:numel(comp_reqs)
                req = comp_reqs{i};
                tests = [tests; obj.get_tests_linked_to_req(req)];
            end
        end

        function results = run_tests_from_components(obj, comps)
            tests = obj.get_tests_from_components(comps);
            for i=1:numel(tests)
                obj.run_test(tests{i});
            end
        end

        % get tests from a chosen component
        % Input(obj): self
        % Output(tests): the list of tests dependent on the chosen
        %   component
        function tests = list_tests_from_chosen_component(obj)
            reqs = {};
            comp = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.components, ...
                Simulink.testadvisor.internal.TestAdvisor.COMP_QUESTION_STR, ...
                @Simulink.testadvisor.internal.TestAdvisor.component_id_func);
            tests = obj.get_tests_from_component(comp);
        end

        %
        % Input(obj): get tests linked to a given requirement
        % Input(current_req): the requirement
        % Output(found_tests): a list of tests linked to the requirement
        function found_tests = get_tests_linked_to_req(obj, current_req)
            found_tests = {};
            in_links = current_req.req_entity.inLinks;
            out_links = current_req.req_entity.outLinks;
            for i=1:numel(in_links)
                link = in_links(i);
                if strcmp(link.source.domain, ...
                    Simulink.testadvisor.internal.TestAdvisor.TESTMNGRLINK)
                    found_tests(end+1) = {obj.find_test_with_matching_id( ...
                        link.source.id)};
                end
            end
        end

        % create a new dependency
        % Input(obj): self
        % Output(obj): self
        function obj = create_dep(obj)
             % OPTIMIZE: this function is WAY too big and non-generic.
            src_id = 'from';
            dest_id = 'to';
            error_occured = false;
            from_type = Simulink.testadvisor.internal.TestAdvisor.dep_categories( ...
                'From where? [1,2...n]: ');
            % first pick where we are coming FROM
            if strcmp(from_type, ...
                Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_TESTS_CHOICE)
                test_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.discovered_sltests, ...
                    'Which test? [1,2,...n]: ', ...
                    @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                src_id = test_to_add.TestPath;
            elseif strcmp(from_type, ...
                Simulink.testadvisor.internal.TestAdvisor.CURRENT_TESTS_CHOICE)
                test_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.sltests, ...
                    'Which test? [1,2,...n]: ', ...
                    @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                src_id = test_to_add.TestPath;
            elseif strcmp(from_type, ...
                Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_REQS_CHOICE)
                req_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.discovered_reqs, ...
                    'Which requirement? [1,2,...n]: ', ...
                    @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
                src_id = req_to_add.Id;
            elseif strcmp(from_type, ...
                Simulink.testadvisor.internal.TestAdvisor.CURRENT_REQS_CHOICE)
                req_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.reqs, ...
                    'Which requirement? [1,2,...n]: ', ...
                    @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
                src_id = req_to_add.Id;
            elseif strcmp(from_type, ...
                Simulink.testadvisor.internal.TestAdvisor.COMPONENT_CHOICE)
                comp_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.components, ...
                    'Which Component? [1,2,...n]: ', ...
                    @Simulink.testadvisor.internal.TestAdvisor.component_id_func);
                src_id = comp_to_add.name;
            else
                fprintf('Exiting.\n');
                error_occured = true;
            end
            % then where we are going TO
            if ~error_occured
                to_type = Simulink.testadvisor.internal.TestAdvisor.dep_categories( ...
                    'To where? [1,2...n]: ');
                dep_type = 'None';
                % QUESTION: are the three other types needed
                if strcmp(from_type, ...
                    Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_REQS_CHOICE) || ...
                        strcmp(from_type, Simulink.testadvisor.internal.TestAdvisor.CURRENT_REQS_CHOICE)
                     dep_type = Simulink.testadvisor.internal.TestAdvisor.REQTOTEST;
                elseif strcmp(from_type, Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_TESTS_CHOICE) || ...
                        strcmp(from_type, Simulink.testadvisor.internal.TestAdvisor.CURRENT_TESTS_CHOICE)
                     dep_type = Simulink.testadvisor.internal.TestAdvisor.TESTTOTEST;
                elseif strcmp(from_type, Simulink.testadvisor.internal.TestAdvisor.COMPONENT_CHOICE)
                      dep_type = Simulink.testadvisor.internal.TestAdvisor.COMPTOTEST;
                else
                    fprintf('Exiting.\n');
                end
                if ~strcmp(dep_type, 'None')
                    if strcmp(to_type, ...
                            Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_TESTS_CHOICE)
                        test_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el( ...
                            obj.discovered_sltests, ...
                            'Which test? [1,2,...n]: ', ...
                            @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                        dest_id = test_to_add.TestPath;
                        new_id = ...
                            Simulink.testadvisor.internal.Dependency.make_id(...
                                src_id, dest_id);
                        if ~ismember(new_id, obj.deps.keys)
                            trigger = obj.choose_trigger(dep_type);
                            obj.deps(new_id) = ...
                                Simulink.testadvisor.internal.Dependency( ...
                                    dep_type, src_id, dest_id, trigger);
                        else
                            fprintf('Dependency already exists.\n');
                        end
                    elseif strcmp(to_type, ...
                            Simulink.testadvisor.internal.TestAdvisor.CURRENT_TESTS_CHOICE)
                        test_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.sltests, ...
                            'Which test? [1,2,...n]: ', ...
                            @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                        dest_id = test_to_add.TestPath;
                        new_id = Simulink.testadvisor.internal.Dependency.make_id(src_id, dest_id);
                        if ~ismember(new_id, obj.deps.keys)
                            trigger = obj.choose_trigger(dep_type);
                            obj.deps(new_id) = ...
                                Simulink.testadvisor.internal.Dependency( ...
                                    dep_type, src_id, dest_id, trigger);
                        else
                            fprintf('Dependency already exists.\n');
                        end
                    elseif strcmp(to_type, Simulink.testadvisor.internal.TestAdvisor.DISCOVERED_REQS_CHOICE)
                        req_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el( ...
                            obj.discovered_reqs, ...
                            'Which requirement? [1,2,...n]: ', ...
                            @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
                        dest_id = req_to_add.Id;
                        new_id = Simulink.testadvisor.internal.Dependency.make_id(src_id, dest_id);
                        if ~ismember(new_id, obj.deps.keys)
                            trigger = obj.choose_trigger(dep_type);
                            obj.deps(new_id) = ...
                                Simulink.testadvisor.internal.Dependency(dep_type, src_id, dest_id, ...
                                    trigger);
                        else
                            fprintf('Dependency already exists.\n');
                        end
                    elseif strcmp(to_type, Simulink.testadvisor.internal.TestAdvisor.CURRENT_REQS_CHOICE)
                        req_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.reqs, ...
                            'Which requirement? [1,2,...n]: ', ...
                            @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
                        dest_id = req_to_add.Id;
                        new_id = Simulink.testadvisor.internal.Dependency.make_id(src_id, dest_id);
                        if ~ismember(new_id, obj.deps.keys)
                            trigger = obj.choose_trigger(dep_type);
                            obj.deps(new_id) = ...
                                Simulink.testadvisor.internal.Dependency(dep_type, src_id, dest_id, ...
                                    trigger);
                        else
                            fprintf('Dependency already exists.\n');
                        end
                    elseif strcmp(to_type, Simulink.testadvisor.internal.TestAdvisor.COMPONENT_CHOICE)
                        test_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.sltests, ...
                            'Which test? [1,2,...n]: ', ...
                            @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                        dest_id = test_to_add.TestPath;
                        new_id = Simulink.testadvisor.internal.Dependency.make_id(src_id, dest_id);
                        if ~ismember(new_id, obj.deps.keys)
                            trigger = obj.choose_trigger(dep_type);
                            obj.deps(new_id) = ...
                                Simulink.testadvisor.internal.Dependency(dep_type, src_id, dest_id, ...
                                    trigger);
                        else
                            fprintf('Dependency already exists.\n');
                        end
                    end
                end
            end
        end

        % remove a dependency
        % Input(obj): self
        % Output(obj): self
        function obj = remove_dep(obj)
            dep_to_remove = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.deps, ...
                'Which Dependency? [1,2,...n]: ', ...
                @Simulink.testadvisor.internal.TestAdvisor.dep_id_func);
            obj.deps.remove(dep_to_remove.Id);
        end

        % run a chosen test
        % Input(obj): self
        % Output(Nothing): Nothing
        function run_chosen_test(obj)
            test_to_run = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.sltests, ...
                'Tests that can be run:', @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
            obj.run_test(test_to_run);
        end

        % run a given test
        % Input(obj): self
        % Input(test_to_run): the test
        % Output(Nothing): Nothing
        function run_test(obj, test_to_run)
            fprintf('Running %s...', test_to_run.TestPath);
            result = test_to_run.run_test();
            if result.Outcome == Simulink.testadvisor.internal.TestAdvisor.FAILED
                fprintf('%s failed.\n', test_to_run.TestPath);
            else
                fprintf('%s Passed.\n', test_to_run.TestPath);
            end
            obj.drill_down_on_test_result(test_to_run, result.Outcome)
        end

        % run a test from a given requirement
        % Input(obj): self
        % Input(chosen_req): the requirement
        % Output(Nothing): Nothing
        function run_test_from_req(obj, chosen_req)
            % OPTIMIZE: this function is too big.
            dep_keys = obj.deps.keys;
            % get all deps
            dep_tests_to_run = {};
            dep_reqs_to_run = {};
            for i=1:numel(dep_keys)
                key = dep_keys{i};
                current_dep = obj.deps(key);
                if strcmp(current_dep.source_id, chosen_req.Id)
                    if ismember(current_dep.dest_id, obj.sltests.keys)
                        dep_tests_to_run(end+1) = {obj.sltests( ...
                            current_dep.dest_id)};
                    elseif ismember(current_dep.dest_id, ...
                            obj.discovered_sltests.keys)
                        dep_tests_to_run(end+1) = {obj.discovered_sltests( ...
                            current_dep.dest_id)};
                    elseif ismember(current_dep.dest_id, ...
                            obj.reqs.keys)
                        dep_reqs_to_run(end+1) = {obj.reqs( ...
                            current_dep.dest_id)};
                    elseif ismember(current_dep.dest_id, ...
                            obj.discovered_reqs.keys)
                        dep_reqs_to_run(end+1) = {obj.discovered_reqs( ...
                            current_dep.dest_id)};
                    else
                        fprintf('Could not find "%s" in the workspace.\n', ...
                            current_dep.dest_id);
                    end
                end
            end
            % get deps from linked reqs
            additional_tests = obj.get_tests_linked_to_req(chosen_req);
            dep_tests_to_run = horzcat(dep_tests_to_run, additional_tests);
            if numel(dep_tests_to_run) > 0 || numel(dep_reqs_to_run) > 0
                run_tests = false;
                run_reqs = false;
                fprintf('This requirement is linked to the following....\n');
                if numel(dep_tests_to_run) > 0
                    fprintf('Test links:\n')
                    for i=1:numel(dep_tests_to_run)
                        fprintf('%s\n', dep_tests_to_run{i}.TestPath);
                    end
                    run_tests = Simulink.testadvisor.internal.TestAdvisorUtils.yes_no_question( ...
                        'Run these tests? [Y/N]: ');
                end
                if numel(dep_reqs_to_run) > 0
                    fprintf('Requirements links:\n')
                    for i=1:numel(dep_reqs_to_run)
                        fprintf('%s\n', dep_reqs_to_run{i}.Id);
                    end
                    run_reqs = Simulink.testadvisor.internal.TestAdvisorUtils.yes_no_question( ...
                            'Run tests linked to these requirements? [Y/N]: ');
                end
                if run_tests
                    for i=1:numel(dep_tests_to_run)
                        obj.run_test(dep_tests_to_run{i});
                    end
                end
                if run_reqs
                    for i=1:numel(dep_reqs_to_run)
                        obj.run_test_from_req_object(dep_reqs_to_run{i});
                    end
                end
            else
                fprintf('Nothing is linked to %s.\n', chosen_req.Id);
            end
        end

        % run a test from a chosen requirement
        % Input(obj): self
        % Output(Nothing): Nothing
        function run_test_from_chosen_req(obj)
            chosen_req = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.reqs, ...
                'Requirements:', @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
            obj.run_test_from_req(chosen_req)
        end

        % add a requirement (discovered_reqs to reqs)
        % Input(obj): self
        % Output(obj): self
        function obj = add_req(obj)
            if obj.discovered_reqs.Count > 0
                req_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.discovered_reqs, ...
                    'Requirements that can be added:', @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
                obj.reqs(req_to_add.Id) = req_to_add;
                obj.discovered_reqs.remove(req_to_add.Id);
            else
                fprintf('No requirements to add.');
            end
        end

        % remove a requirement (reqs to discovered_reqs)
        % Input(obj): self
        % Output(obj): self
        function obj = remove_req(obj)
            if obj.reqs.Count > 0
                % and remove functions.
                req_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.reqs, ...
                    'Requirements that can be removed:', ...
                    @Simulink.testadvisor.internal.TestAdvisor.req_id_func);
                obj.discovered_reqs(req_to_add.Id) =  req_to_add;
                obj.reqs.remove(req_to_add.Id);
            else
                fprintf('No requirements to remove.');
            end
        end

        % add a test (discovered_sltests to sltests)
        % Input(obj): self
        % Output(obj): self
        function obj = add_test(obj)
            if obj.discovered_sltests.Count > 0
                test_to_add = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(...
                    obj.discovered_sltests, 'Tests that can be added:', ...
                    @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                if strcmp(class(test_to_add), Simulink.testadvisor.internal.TestAdvisor.TEST_SUITE_CLASS)
                    test_type = Simulink.testadvisor.internal.TestAdvisor.TEST_SUITE;
                else
                    test_type = Simulink.testadvisor.internal.TestAdvisor.TEST_CASE;
                end
                obj.sltests(test_to_add.TestPath) = test_to_add;
                obj.discovered_sltests.remove(test_to_add.TestPath);
            else
                fprintf('No tests to add.\n')
            end
        end

        % add a test (sltests to discovered_sltests)
        % Input(obj): self
        % Output(obj): self
        function obj = remove_test(obj)
            if obj.sltests.Count > 0
                test_to_remove = Simulink.testadvisor.internal.TestAdvisorUtils.choose_map_el(obj.sltests, ...
                    'Tests that can be removed:', @Simulink.testadvisor.internal.TestAdvisor.test_id_func);
                obj.sltests.remove(test_to_remove.TestPath)
                obj.discovered_sltests(test_to_remove.TestPath) = ...
                    test_to_remove;
            else
                fprintf('No tests to remove.\n');
            end
        end

        % add a requirement path, parses for requirement files and reads
        %   them
        % Input(obj): self
        % Input(path): the new path
        % Output(obj): self
        function obj = add_req_path(obj, path)
            path = char(path);
            if ~ismember(path, obj.req_paths)
                obj.req_paths(end+1) = {path};
                found_files = Simulink.testadvisor.internal.TestAdvisorUtils.parse_path_node(path, ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.SLREQX_EXT);
                for i=1:numel(found_files)
                    req_file = found_files{i};
                    obj = obj.parse_req_set(req_file, path);
                end
            else
                fprintf('Path "%s" has already been added.\n', path);
            end
        end

        % add a test path, parses for test files and reads them
        % Input(obj): self
        % Input(path):the new path
        % Output(obj): self
        function obj = add_test_path(obj, path)
            path = char(path);
            if ~ismember(path, obj.test_paths)
                obj.test_paths(end+1) = {path};
                found_files = Simulink.testadvisor.internal.TestAdvisorUtils.parse_path_node(path, ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.MLDATX_EXT);
                for i=1:numel(found_files)
                    test_file = found_files{i};
                    obj = obj.parse_sltest_file(test_file, path);
                end
            else
                fprintf('Path "%s" has already been added.\n', path);
            end
        end

        % remove a chosen requirement path, also remove any requirement
        %   that is linked to a requirement file in that path
        % Input(obj): self
        % Output(obj): self
        function obj = remove_req_path(obj)
            if numel(obj.req_paths) > 0
                req_path_index = Simulink.testadvisor.internal.TestAdvisorUtils.choose_lst_el_index( ...
                    obj.req_paths, Simulink.testadvisor.internal.TestAdvisor.PATH_QUESTION_STR);
                path = obj.req_paths(req_path_index);
                to_remove_reqs = {};
                to_remove_discovered_reqs = {};
                fprintf('This will remove the following Requirements:\n');
                keys = obj.reqs.keys;
                for i=1:numel(keys)
                    current_req = obj.reqs(keys{i});
                    if contains(current_req.parent_path, path)
                        to_remove_reqs(end+1) = {obj.reqs(keys{i}).Id};
                        fprintf('%s\n',obj.reqs(keys{i}).Id);
                    end
                end
                keys = obj.discovered_reqs.keys;
                for i=1:numel(obj.discovered_reqs.keys)
                    current_req = obj.discovered_reqs(keys{i});
                    if contains(current_req.parent_path, path)
                        to_remove_discovered_reqs(end+1) = ...
                            {obj.discovered_reqs(keys{i}).Id};
                        fprintf('%s\n',obj.discovered_reqs(keys{i}).Id);
                    end
                end
                if Simulink.testadvisor.internal.TestAdvisorUtils.yes_no_question( ...
                        Simulink.testadvisor.internal.TestAdvisor.CONTINUE_QUESTION_STR)
                    obj.req_paths(req_path_index) = [];
                    for i=1:numel(to_remove_reqs)
                        obj.reqs.remove(to_remove_reqs{i});
                    end
                    for i=1:numel(to_remove_discovered_reqs)
                        obj.discovered_reqs.remove( ...
                            to_remove_discovered_reqs{i});
                    end
                else
                    fprintf('Not removing any requirement paths.');
                end
            else
                fprintf('No requirement paths to remove.');
            end
        end

        % remove a chosen test path, also remove any test
        %   that is linked to a test file in that path
        % Input(obj): self
        % Output(obj): self
        function obj = remove_test_path(obj)
            % TODO: generalize this function and clean it up
            % OPTIMIZE: way too long
            if numel(obj.test_paths) > 0
                path_index = Simulink.testadvisor.internal.TestAdvisorUtils.choose_lst_el_index(obj.test_paths, ...
                    Simulink.testadvisor.internal.TestAdvisor.PATH_QUESTION_STR);
                to_remove_sltests = {};
                to_remove_discovered_tests = {};
                fprintf('This will remove the following defined tests:\n');
                keys = obj.sltests.keys;
                for i=1:numel(keys)
                    key = keys{i};
                    current_test = obj.sltests(key);
                    if contains(current_test.parent_file, ...
                            obj.test_paths(path_index))
                        fprintf('%s\n', current_test.Name);
                        to_remove_sltests(end+1) = {current_test};
                    end
                end
                keys = obj.discovered_sltests.keys;
                for i=1:numel(keys)
                    key = keys{i};
                    current_test = obj.discovered_sltests(key);
                    if contains(current_test.test_entity.TestFile.FilePath, ...
                            obj.test_paths(path_index))
                        fprintf('%s\n', current_test.Name);
                        to_remove_discovered_tests(end+1) = {current_test};
                    end
                end
                if Simulink.testadvisor.internal.TestAdvisorUtils.yes_no_question( ...
                        Simulink.testadvisor.internal.TestAdvisor.CONTINUE_QUESTION_STR)
                    obj.test_paths(path_index) = [];
                    for i=1:numel(to_remove_sltests)
                        obj.sltests.remove( ...
                            to_remove_sltests{i}.TestPath);
                    end
                    for i=1:numel(to_remove_discovered_tests)
                        obj.discovered_sltests.remove( ...
                            to_remove_discovered_tests{i}.TestPath);
                    end
                else
                    fprintf('Not removing any test paths.');
                end
            else
                fprintf('No test paths to remove.\n');
            end
        end
    end


    methods(Access='private')

       % find test with a matching uuid
       % Input(obj): self
       % Input(uuid): the uuid
       % Output(test): the test with that uuid
        function test = find_test_with_matching_id(obj, uuid)
            keys = obj.sltests.keys;
            for i=1:numel(keys)
                key = keys{i};
                if strcmp(uuid, obj.sltests(key).uuid)
                    test = obj.sltests(key);
                end
            end
            keys = obj.discovered_sltests.keys;
            for i=1:numel(keys)
                key = keys{i};
                if strcmp(uuid, obj.discovered_sltests(key).uuid)
                    test = obj.discovered_sltests(key);
                end
            end
        end

        % choose a dependency trigger
        % Input(obj): self
        % Input(dep_type): the dependency type
        % Output(trigger): the chosen trigger
        function trigger = choose_trigger(obj, dep_type)
            % TODO: depending on the dep type this will changed.... this is
            % for TESTTOTEST....
            if strcmp(dep_type, Simulink.testadvisor.internal.TestAdvisor.TESTTOTEST)
                fprintf('Trigger types:\n');
                fprintf('1. Passed\n');
                fprintf('2. Failed\n');
                prompt = input('Which trigger (1 or 2)');
                if prompt == 1
                    trigger = sltest.testmanager.TestResultOutcomes.Passed;
                else
                    trigger = sltest.testmanager.TestResultOutcomes.Failed;
                end
            else
                trigger = 'SimpleDep';
            end
        end

        % based on the result of a test that was run, drill down on
        %   dependent tests
        % Input(obj): self
        % Input(main_test): the test that was run
        % Input(test_result): the result of the test
        % Output(results): (TODO: add this) the list of test results
        function results = drill_down_on_test_result(obj, main_test, test_result)
            % OPTIMIZE: this function is too big.
            dep_tests_to_run = {};
            dep_keys = obj.deps.keys;
            % fprintf('The following tests are dependent on %s (%s):\n', ...
                % main_test.TestPath, test_result);
            for i=1:numel(dep_keys)
                key = dep_keys{i};
                current_dep = obj.deps(key);
                if strcmp(current_dep.source_id, main_test.TestPath) && ...
                        test_result == current_dep.trigger
                    test = obj.find_test(current_dep.dest_id);
                    % TODO: change to use isa
                    if strcmp(class(test), 'Simulink.testadvisor.internal.SimulinkTest')
                        dep_tests_to_run(end+1) = {test};
                    end
                end
            end
            if numel(dep_tests_to_run) > 0
                dep_tests = containers.Map('KeyType','char','ValueType','any');
                for i=1:numel(dep_tests_to_run)
                    test = dep_tests_to_run{i};
                    fprintf('Running %s...', test.TestPath);
                    result = dep_tests_to_run{i}.run_test();
                    if result.Outcome == Simulink.testadvisor.internal.TestAdvisor.FAILED
                        fprintf('failed.\n')

                    else
                        fprintf('Passed.\n');
                    end
                    obj.drill_down_on_test_result(test, result.Outcome);
                end
            end
        end

      % parse a test file for TestCases and TestSuites
      % Input(obj): self
      % Input(test_file): the test file
      % Input(path): the path that we are parsing (to keep track, if we
      %     delete it later. If we do delete the path the all tests
      %     that were found there can be deleted without having to parse
      %     again).
      % Output(obj): self
        function obj = parse_sltest_file(obj, test_file, path)
            test_suites = test_file.getTestSuites();
            for i=1:numel(test_suites)
                test_suite_i = test_suites(i);
                obj = obj.parse_test_suite(test_suite_i, path);
            end
        end

        % parse a TestSuite
        % Input(obj): self
        % Input(current_node): whatever node we are currently in
        % Input(path): the path that we are parsing (to keep track, if we
        %     delete it later. If we do delete the path the all tests
        %     that were found there can be deleted without having to parse
        %     again).
        % Output(obj): self
        function obj = parse_test_suite(obj, current_node, path)
            fprintf('Discovered a test suite: %s\n', current_node.Name);
            test_suites = current_node.getTestSuites();
            test_cases = current_node.getTestCases();
            if ~ismember(current_node.TestPath, obj.sltests.keys)
                obj.discovered_sltests(current_node.TestPath) = ...
                    Simulink.testadvisor.internal.SimulinkTest( ...
                        current_node.Name, Simulink.testadvisor.internal.TestAdvisor.TEST_SUITE, ...
                        current_node.TestPath, current_node.TestFile.FilePath, ...
                    path);
            end
            for i=1:numel(test_cases)
                test_case_i = test_cases(i);
                if ~ismember(test_case_i.TestPath, obj.sltests.keys)
                    fprintf('Discovered a test case: %s\n', test_case_i.Name);
                    obj.discovered_sltests(test_case_i.TestPath) = ...
                        Simulink.testadvisor.internal.SimulinkTest( ...
                        test_case_i.Name, Simulink.testadvisor.internal.TestAdvisor.TEST_CASE, ...
                        test_case_i.TestPath, test_case_i.TestFile.FilePath, ...
                        path);
                end
            end

            for i=1:numel(test_suites)
                test_suite_i = test_suites(i);
                obj = obj.parse_test_suite(test_suite_i, path);
            end
        end

        % parse all test paths
        % Input(obj): self
        % Output(obj): self
        function obj = parse_test_paths(obj)
            found_files_all = {};
            for i=1:numel(obj.test_paths)
                 found_files = Simulink.testadvisor.internal.TestAdvisorUtils.parse_path_node(obj.test_paths{i}, ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.MLDATX_EXT);
                for j=1:numel(found_files)
                    current_file = found_files{j};
                    obj.discovered_sltest_files(end+1) = {current_file};
                    obj.parse_sltest_file(current_file, obj.test_paths{i});
                end
            end
            % sltest.testmanager.clear;
        end

        % parse a requirement
        % Input(obj): self
        % Input(current_req):
        % Input(filename): the filename
        % Input(path): the path that we are parsing (to keep track, if we
        %     delete it later. If we do delete the path the all tests
        %     that were found there can be deleted without having to parse
        %     again).
        % Output(obj): self
        function obj = parse_req(obj, current_req, filename, path)
            req_id = Simulink.testadvisor.internal.Requirement.make_id(current_req);

            if ~ismember(req_id, obj.reqs.keys)
                obj.discovered_reqs(req_id) = ...
                    Simulink.testadvisor.internal.Requirement(current_req.Id, req_id, filename, path);
                req_children = current_req.children;
                for i=1:numel(current_req.children)
                    % IDEA: automatically add parent-child dependencies
                    % child_id = Simulink.testadvisor.internal.Requirement.make_id(req_children(i));
                    % dep_id = Simulink.testadvisor.internal.Dependency.make_id(req_id, child_id);
                    % if ~contains(obj.deps.keys, dep_id)
                    %     obj.deps(dep_id) = Simulink.testadvisor.internal.Dependency( ...
                    %         Simulink.testadvisor.internal.TestAdvisor.REQTOREQ, req_id, child_id);
                    % end
                    obj = obj.parse_req(req_children(i), filename, path);
                end
            end
        end

        % parse a RequirementSet to extract all of the Requirements
        % Input(obj): self
        % Input(current_req_set): the RequirementSet
        % Input(path): the path that we are parsing (to keep track, if we
        %     delete it later. If we do delete the path the all tests
        %     that were found there can be deleted without having to parse
        %     again).
        % Output(obj): self
        function obj = parse_req_set(obj, current_req_set, path)
            % FIXME: check if it already exists, blindly adding is a bad idea
            obj.discovered_req_sets(end+1) = {current_req_set};
            all_reqs = find(current_req_set, 'Type', 'Requirement');
            for i=1:numel(all_reqs)
                req = all_reqs(i);
                if strcmp(class(req.parent), Simulink.testadvisor.internal.TestAdvisorUtils.REQSET_CLASS)
                    obj = obj.parse_req(req, current_req_set.Filename, path);
                end
            end
        end

        % Parse all the requirement paths
        % Input(obj): self
        % Output(obj): self
        function obj = parse_req_paths(obj)
            found_files_all = {};
            for i=1:numel(obj.req_paths)
                found_files = Simulink.testadvisor.internal.TestAdvisorUtils.parse_path_node( ...
                    obj.req_paths{i}, ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.SLREQX_EXT);
                for j=1:numel(found_files)
                    obj = obj.parse_req_set(found_files{j}, obj.req_paths{i});
                end
            end
            % sltest.testmanager.clear;
        end
    end
end
