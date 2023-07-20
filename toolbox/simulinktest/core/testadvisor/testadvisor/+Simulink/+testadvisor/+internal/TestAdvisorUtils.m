classdef TestAdvisorUtils

    properties(Constant, Access='private')
        % Delim for pretty printing on cmdln
        DELIM = '------------------------';
    end

    properties(Constant, Access='public')
        MLDATX_EXT = '.mldatx';
        SLREQX_EXT = '.slreqx';
        REQSET_CLASS = 'slreq.ReqSet';
        NONE = '';
    end

    methods(Static, Access='private')

        % Print a map with no pretty header
        % Input (map): a map
        % Input (sorted_keys): a sorted set of keys for the map
        % Output: nothing
        function print_map_no_header(map, sorted_keys)
            for i=1:numel(sorted_keys)
                key = sorted_keys{i};
                current_test = map(key);
                fprintf('%d: %s\n', i, current_test);
            end
        end

        % Print a map with a pretty header
        % Input (map): a map
        % Input (sorted_keys): a sorted set of keys for the map
        % Input (header): header to print
        % Output: nothing
        function print_map_with_header(map, sorted_keys, header)
            fprintf('%s:\n', header);
            fprintf('%s\n', Simulink.testadvisor.internal.TestAdvisorUtils.DELIM);
            for i=1:numel(sorted_keys)
                key = sorted_keys{i};
                current_test = map(key);
                fprintf('%d: %s\n', i, current_test);
            end
        end

        % Transfer a map to another map that has numeric keys, this
        %   is for printing and selection.
        % Input (original_map): a map
        % Input (id_func): the function to return the id of the value
        %   members of the map
        % Output: the transformed map
        function map = make_numbered_map(original_map, id_func)
            map = containers.Map('KeyType','char','ValueType','char');
            keys = original_map.keys;
            for i=1:numel(keys)
                key = keys{i};
                current_el = original_map(key);
                map(num2str(i)) = id_func(current_el);
            end
        end

        % A silly function to get a sorted set of numbers, takes a list of
        %   unsorted numbers (that are strings) turns them into doubles
        %   sorts them and turns them back to strings. This functions is
        %   for convenience but there is surely a better way to do it
        % Input (lst): an unsorted list of numbers (that are strings)
        % Output: the list sorted
        function lst_out = get_sorted_numeric_key_lst(lst)
            % OPTIMIZE: must be a better way to do this! fix it.
            lst_tmp = zeros(1, numel(lst));
            for i=1:numel(lst)
                lst_tmp(i) = str2num(lst{i});
            end
            lst_tmp = sort(lst_tmp);
            lst_out = {};
            for i=1:numel(lst_tmp)
                lst_out(end+1) = {num2str(lst_tmp(i))};
            end
        end

        % when parsing through directories handle an encountered file
        % Input (file): the file
        % Input (ending): the file ending
        % Output: the found file
        function found_file = handle_file(file, ending)
            full_filename = fullfile(file.folder, file.name);
            found_file = [];
            if endsWith(file.name, ending)
                if strcmp(ending, Simulink.testadvisor.internal.TestAdvisorUtils.MLDATX_EXT)
                    desc = matlabshared.mldatx.internal.getDescription( ...
                        full_filename);
                    if strcmp(DAStudio.message(...
                            'stm:general:TestFileDescription'), desc)
                        fprintf('Discovered a test file: %s\n', file.name);
                        found_file = sltest.testmanager.load(full_filename);
                    else
                        fprintf('Discovered an imposter test file: %s\n', ...
                            file.name);
                    end
                elseif strcmp(ending, Simulink.testadvisor.internal.TestAdvisorUtils.SLREQX_EXT)
                    % NOTE: might need a try catch here
                    fprintf('Discovered a requirement file: %s\n', file.name);
                    found_file = slreq.load(full_filename);
                end
            end
        end
    end

    methods(Static, Access='public')

        % create a new TestAdvisor object
        % Input(ta_obj_name): the name of the model
        % Input(model_path): the path to the model
        % Input(test_path): the initial path to look for tests
        % Input(req_path): the initial path to look for requirements
        % Output(ta): the TestAdvisor object
        function ta = create_ta(ta_obj_name, model_path, test_path, req_path)
            % TODO: this needs to be finished. Remember! We need this
            % to get the harness object.
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                ta = Simulink.testadvisor.internal.TestAdvisor( ...
                    ta_obj_name, model_path, '', {test_path}, ...
                    {req_path}, {}, {}, {});
            end
        end

        % Find the components of a system (used in TA and ImpactAnalysis
        % Input(sysname): the system name
        % Output(components): the list of components
        function components = update_components(sysname)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                components = ...
                    containers.Map('KeyType','char','ValueType','any');
                fprintf('Getting components....');
                % NOTE: this is our _current_ fix for large models, it takes too long
                %   otherwise
                findopts = Simulink.FindOptions('SearchDepth', 3);
                bl = Simulink.findBlocks(sysname);
                for i=1:numel(bl)
                    components(getfullname(bl(i))) =  ...
                        Simulink.testadvisor.internal.Component(bl(i));
                end
                fprintf('Done.\n');
            end
        end

        % ask a yes no question, for simplicity and QOL
        % Input(msg_str): the question
        % Output(bool): the answer
        function bool = yes_no_question(msg_str)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                prompt = input(msg_str, 's');
                if isempty(prompt)
                    prompt = 'Y';
                end
                if strcmpi(prompt, 'y')
                    bool = true;
                else
                    bool = false;
                end
            end
        end

        % print a map with numbers as keys
        % Input(map): the map
        % Input(header): the header to print
        % Input(id_func): a function for finding the id of the values in
        %   the map
        % Output(Nothing): Nothing
        function print_map(map, header, id_func)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                numbered_map = Simulink.testadvisor.internal.TestAdvisorUtils.make_numbered_map(map, id_func);
                sorted_keys = ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.get_sorted_numeric_key_lst(numbered_map.keys);
                Simulink.testadvisor.internal.TestAdvisorUtils.print_map_with_header(numbered_map, ...
                    sorted_keys, header);
            end
        end

        % print a list
        % Input(lst): the list
        % Input(header): the header to print
        % Output(Nothing): Nothing
        function print_lst(lst, header)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                    DAStudio.error('sltest:testadvisor:FeatureNotOn')
                else
                    fprintf('%s\n', header);
                    fprintf('%s\n', Simulink.testadvisor.internal.TestAdvisorUtils.DELIM);
                    for i=1:numel(lst)
                        fprintf('%d. %s\n', i, lst{i});
                    end
                end
            end
        end

        % Choose an element from a map, the map is transfered to a new map
        %   with numbers for keys (for easy selection)
        % Input(map): the map
        % Input(question_str): the question to ask (something like "Which
        %   test?"
        % Input(id_func): a function for finding the id of the values in
        %   the map
        % Output(map_el): the chosen element from the map
        function map_el = choose_map_el(map, question_str, id_func)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                numbered_map = Simulink.testadvisor.internal.TestAdvisorUtils.make_numbered_map(map, id_func);
                sorted_keys = ...
                    Simulink.testadvisor.internal.TestAdvisorUtils.get_sorted_numeric_key_lst(numbered_map.keys);
                Simulink.testadvisor.internal.TestAdvisorUtils.print_map_no_header(numbered_map, ...
                    sorted_keys);
                index = input(question_str, 's');
                % TODO: add bounds check here to make sure no bad input is given
                map_el = map(numbered_map(index));
            end
        end

        % get the _index_ of a chosen element in a list
        % Input(lst): the list
        % Input(question_str): the question to ask (something like "Which
        %   test?"
        % Output(lst_index): the list index
        function lst_index = choose_lst_el_index(lst, question_str)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                for i=1:numel(lst)
                    fprintf('%d. %s\n', i, lst{i});
                end
                lst_index = input(question_str);
            end
        end

        % Parse a path while traversing in a FS
        % Input(parent_node): the node we start at
        % Input(ending): what types of files we are looking for
        % Output(found_files): the list of found files
        function found_files = parse_path_node(parent_node, ending)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                parent_node = dir(parent_node);
                found_files = {};
                for i=1:numel(parent_node)
                    current_node = parent_node(i);
                    current_node_name = fullfile(current_node.folder, ...
                        current_node.name);
                    if ~strcmp(current_node.name, '.') && ...
                            ~strcmp(current_node.name, '..')
                        if ~current_node.isdir
                            found_file = Simulink.testadvisor.internal.TestAdvisorUtils.handle_file( ...
                                current_node, ending);
                            if ~isempty(found_file)
                                found_files(end+1) = {found_file};
                            end
                        else
                            node_fullfile = fullfile(current_node_name, ...
                                '**/*.*');
                            files = dir(node_fullfile);
                            files = files(~[files.isdir]);
                            for j=1:numel(files)
                                found_file = Simulink.testadvisor.internal.TestAdvisorUtils.handle_file( ...
                                    files(j), ending);
                                if ~isempty(found_file)
                                    found_files(end+1) = {found_file};
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
