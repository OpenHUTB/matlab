classdef XMLUtils

    properties(Constant, Access='private')
        % TODO: move these to xml
        ROOT = 'TestEntity'
        PATHS = 'paths'
        TESTPATHS = 'testpaths'
        TESTPATH = 'testpath'
        REQPATHS = 'requirementpaths'
        REQPATH = 'requirementpath'
        TESTS = 'tests'
        SLTESTS = 'sltests'
        SLTEST = 'sltest'
        NAME = 'name'
        PARENTFILE = 'parentfile'
        PARENTPATH = 'parentpath'
        TYPE = 'type'
        UUID = 'uuid'
        ID = 'id'
        REQS = 'requirements'
        REQ = 'requirement'
        DEPENDENCIES = 'dependencies'
        DEPENDENCY = 'dependency'
        SOURCE_ID = 'source_id'
        DEST_ID = 'dest_id'
        MODEL_PATH = 'model_path'
        TRIGGER = 'trigger'
    end

    methods(Static, Access='public')

        % read a TestAdvisor xml and create a TestAdvisor object
        % Input(xml_filename): the xml filename (and path)
        % Output(ta): the TestAdvisor object
        function ta = read_xml(xml_filename)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                xDoc = xmlread(xml_filename);
                ta = Simulink.testadvisor.internal.XMLUtils.xml_parser(xDoc);
            end
        end

        % serialize a TestAdvisor object into xml form
        % Input(ta): the TestAdvisor object
        % Output(Nothing): Nothing
        function write_xml(ta)
            if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn')
            else
                Simulink.testadvisor.internal.XMLUtils.xml_writer(ta);
            end
        end
    end

    methods(Static, Access='private')

        % create a base node element in xml
        % Input(docNode): the Document node
        % Input(tag): the tag of the elemen
        % Input(node_text): the text of the element
        % Output(node): the node
        function node = create_base_elem(docNode, tag, node_text)
            node = docNode.createElement(tag);
            node.appendChild(docNode.createTextNode(node_text));
        end

        % convert all of result triggers to strings (used on WRITE)
        % Input(trigger): the result object
        % Output(trigger_str): the string representation of the result
        %   object
        function trigger_str = trigger_to_str(trigger)
            if trigger == sltest.testmanager.TestResultOutcomes.Passed
                trigger_str = 'Passed';
            elseif trigger == sltest.testmanager.TestResultOutcomes.Failed
                trigger_str = 'Failed';
            else
                % TODO: change this to None
                trigger_str = 'Untested';
            end
        end

        % convert a string representation of a result object to and actual
        %   result object(used on READ)
        % Input(trigger_str): the string representation
        % Output(trigger): the result object
        function trigger = str_to_trigger(trigger_str)
            if strcmp(trigger_str, 'Passed')
                trigger = sltest.testmanager.TestResultOutcomes.Passed;
            elseif strcmp(trigger_str, 'Failed')
                trigger = sltest.testmanager.TestResultOutcomes.Failed;
            else
                % TODO: change this to None
                trigger = sltest.testmanager.TestResultOutcomes.Untested;
            end
        end

        % Write a TestAdvisor object to XML
        % Input(ta): the TestAdvisor object
        % Output(Nothing): Nothing
        function xml_writer(ta)
            docNode = com.mathworks.xml.XMLUtils.createDocument(Simulink.testadvisor.internal.XMLUtils.ROOT);
            xml_filename_basename = strcat(ta.name, '.xml');

            ta_entity = docNode.getDocumentElement;

            name = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
               Simulink.testadvisor.internal.XMLUtils.NAME, ta.name);
            ta_entity.appendChild(name);

            model_path = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.MODEL_PATH, ta.model_path);
            ta_entity.appendChild(model_path);

            uuid = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.UUID, ta.uuid);
            ta_entity.appendChild(uuid);

            % write paths
            paths = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.PATHS, '');
            test_paths = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.TESTPATHS, '');
            req_paths = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.REQPATHS, '');
            for i=1:numel(ta.test_paths)
                current_path = ta.test_paths{i};
                path = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                    Simulink.testadvisor.internal.XMLUtils.TESTPATH, current_path);
                test_paths.appendChild(path);
            end
            for i=1:numel(ta.req_paths)
                current_path = ta.req_paths{i};
                path = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                    Simulink.testadvisor.internal.XMLUtils.REQPATH, current_path);
                req_paths.appendChild(path);
            end
            paths.appendChild(test_paths);
            paths.appendChild(req_paths);
            ta_entity.appendChild(paths);

            % write sltests
            tests = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.TESTS, '');
            sltests = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.SLTESTS, '');
            sltest_keys = ta.sltests.keys;
            for i=1:numel(sltest_keys)
                key = sltest_keys{i};
                current_sltest = ta.sltests(key);
                sltest = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                    Simulink.testadvisor.internal.XMLUtils.SLTEST, '');
                sltest_name = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                    Simulink.testadvisor.internal.XMLUtils.NAME, current_sltest.Name);
                sltest_parentfile = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.PARENTFILE, current_sltest.parent_file);
                sltest_testpath = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.TESTPATH, current_sltest.TestPath);
                sltest_type = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.TYPE, current_sltest.type);
                sltest_parentpath = XMLUtils.create_base_elem(docNode, ...
                        XMLUtils.PARENTPATH, current_sltest.parent_path);
                sltest.appendChild(sltest_name);
                sltest.appendChild(sltest_parentfile);
                sltest.appendChild(sltest_parentpath);
                sltest.appendChild(sltest_testpath);
                sltest.appendChild(sltest_type);
                sltests.appendChild(sltest);
            end
            tests.appendChild(sltests);
            ta_entity.appendChild(tests);

            % write requirements
            reqs = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.REQS, '');
            req_keys = ta.reqs.keys;
            for i=1:numel(req_keys)
                key = req_keys{i};
                current_req = ta.reqs(key);
                req = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.REQ, '');
                req_name = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.NAME, current_req.Name);
                req_id = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.ID, current_req.Id);
                req_parentfile = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.PARENTFILE, current_req.parent_file);
                req_parentpath = XMLUtils.create_base_elem(docNode, ...
                    XMLUtils.PARENTPATH, current_req.parent_path);
                req.appendChild(req_name);
                req.appendChild(req_id);
                req.appendChild(req_parentfile);
                req.appendChild(req_parentpath);
                reqs.appendChild(req);
            end
            ta_entity.appendChild(reqs);

            % write dependencies
            deps = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                Simulink.testadvisor.internal.XMLUtils.DEPENDENCIES, '');
            dep_keys = ta.deps.keys;
            for i=1:numel(dep_keys)
                current_dep = ta.deps(dep_keys{i});
                dep = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                    Simulink.testadvisor.internal.XMLUtils.DEPENDENCY, '');
                dep_type = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                        Simulink.testadvisor.internal.XMLUtils.TYPE, current_dep.type);
                dep_source_id = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                        Simulink.testadvisor.internal.XMLUtils.SOURCE_ID, current_dep.source_id);
                dep_dest_id = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                        Simulink.testadvisor.internal.XMLUtils.DEST_ID, current_dep.dest_id);
                trigger = Simulink.testadvisor.internal.XMLUtils.create_base_elem(docNode, ...
                            Simulink.testadvisor.internal.XMLUtils.TRIGGER, ...
                            Simulink.testadvisor.internal.XMLUtils.trigger_to_str(current_dep.trigger));

                dep.appendChild(dep_type);
                dep.appendChild(dep_source_id);
                dep.appendChild(dep_dest_id);
                dep.appendChild(trigger);
                deps.appendChild(dep);
            end
            ta_entity.appendChild(deps);

            % NOTE: this is now architecture dependent
            names = split(ta.model_path, '/');
            names(end) = {xml_filename_basename};
            name_cell = join(names, '/');
            xml_filename = name_cell{1};
            xmlwrite(xml_filename, docNode);
            % NOTE: just for debug
            % type(xml_filename);

        end

        % parse an XML and turn it into a TestAdvisor object
        % Input(dom_doc): xmlread result
        % Output(parsed): the TestAdvisor object
        function parsed = xml_parser(dom_doc)
            test_entity = dom_doc.getDocumentElement;
            test_entity_children = test_entity.getChildNodes;

            uuid = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.UUID).getTextContent;
            name = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.NAME).getTextContent;
            model_path = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.MODEL_PATH).getTextContent;

            % initialize stuff
            test_paths = [];
            sltests = [];
            req_paths = [];

            path_func = @Simulink.testadvisor.internal.XMLUtils.create_path;
            sltest_func = @Simulink.testadvisor.internal.XMLUtils.create_sltest;
            req_func = @Simulink.testadvisor.internal.XMLUtils.create_req;
            dep_func = @Simulink.testadvisor.internal.XMLUtils.create_dep;

            % get paths, only one set of <paths></paths> is expected.
            path_node = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.PATHS);

            test_paths_node = Simulink.testadvisor.internal.XMLUtils.get_base_element(path_node, ...
                Simulink.testadvisor.internal.XMLUtils.TESTPATHS);

            req_paths_node = Simulink.testadvisor.internal.XMLUtils.get_base_element(path_node, ...
                Simulink.testadvisor.internal.XMLUtils.REQPATHS);

            test_paths = Simulink.testadvisor.internal.XMLUtils.parse_elem(path_func, ...
                Simulink.testadvisor.internal.XMLUtils.TESTPATH, test_paths_node, false);

            req_paths = Simulink.testadvisor.internal.XMLUtils.parse_elem(path_func, ...
                Simulink.testadvisor.internal.XMLUtils.REQPATH, ...
                req_paths_node, false);

            % get test-specifications which is the base for all test types
            tests = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.TESTS);

            % get sltests
            sltest_nodes = Simulink.testadvisor.internal.XMLUtils.get_base_element(tests, ...
                Simulink.testadvisor.internal.XMLUtils.SLTESTS);
            sltests = Simulink.testadvisor.internal.XMLUtils.parse_elem(sltest_func, ...
                Simulink.testadvisor.internal.XMLUtils.SLTEST, sltest_nodes, true);

            % get requirements
            req_nodes = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.REQS);
            reqs = Simulink.testadvisor.internal.XMLUtils.parse_elem(req_func, ...
                Simulink.testadvisor.internal.XMLUtils.REQ, req_nodes, true);

            % get dependencies
            dep_nodes = Simulink.testadvisor.internal.XMLUtils.get_base_element(test_entity, ...
                Simulink.testadvisor.internal.XMLUtils.DEPENDENCIES);
            deps = Simulink.testadvisor.internal.XMLUtils.parse_elem(dep_func, ...
                Simulink.testadvisor.internal.XMLUtils.DEPENDENCY, dep_nodes, true);

            % build TA object
            parsed = Simulink.testadvisor.internal.TestAdvisor( ...
                name, model_path, uuid, ...
                test_paths, req_paths, ...
                sltests, reqs, deps);
        end

        % just for convience, might get rid of this.
        % This function gets a child element that occurs only _once_
        % do not use for list of children
        function node = get_base_element(parent, tag_name)
            el = parent.getElementsByTagName(tag_name);
            % NOTE: this prints the error but doesnt do anything else, might
            % want to have it throw and error.
            if el.length == 1
                node = el.item(0);
            else
                fprintf('parsing error: el.length > 1');
            end
        end

       % parse a list of elements in the XML and create a list of
       %    coorisponding objects
       % Input(creation_function): the function used to create a new
       %    element
       % Input(elem_name): the element name
       % Input(node): the current node
       % Input(use_cells): true iff we want to store in cells
       % Output(elem_lst): the final list of objects
        function elem_lst = parse_elem(creation_function, elem_name, node, use_cells)
            children = node.getChildNodes;
            elem_lst = {};
            for i=0:children.getLength - 1
                child = children.item(i);
                if strcmpi(child.getNodeName, elem_name)
                    if use_cells
                        elem_lst(end+1) = {creation_function(child)};
                    else
                        elem_lst(end+1) = creation_function(child);
                    end
                end
            end
        end

        % path creation function to be passed into parse_elem()
        % Input(node): the node with the path
        % Output(path): a path object
        function path = create_path(node)
            path = node.getTextContent;
        end


        % requirement creation function to be passed into parse_elem()
        % Input(node): the node with the requirement
        % Output(path): a requirement object
        function req = create_req(node)
            name = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.NAME).getTextContent;
            id = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.ID).getTextContent;
            parent_file = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.PARENTFILE).getTextContent;
            parent_path = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.PARENTPATH).getTextContent;
            req = Simulink.testadvisor.internal.Requirement(name, id, parent_file, parent_path);
        end

        % test creation function to be passed into parse_elem()
        % Input(node): the node with the test
        % Output(path): a test object
        function sltest = create_sltest(node)
            name = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.NAME).getTextContent;
            parent_file = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.PARENTFILE).getTextContent;
            test_path = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.TESTPATH).getTextContent;
            parent_path = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.PARENTPATH).getTextContent;
            type = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.TYPE).getTextContent;
            sltest = Simulink.testadvisor.internal.SimulinkTest( ...
                name, type, test_path, parent_file, parent_path);
        end


        % dependency creation function to be passed into parse_elem()
        % Input(node): the node with the dependency
        % Output(path): a dependency object
        function dep = create_dep(node)
            type = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.TYPE).getTextContent;
            source_id = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.SOURCE_ID).getTextContent;
            dest_id = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.DEST_ID).getTextContent;
            trigger_str = Simulink.testadvisor.internal.XMLUtils.get_base_element(node, ...
                Simulink.testadvisor.internal.XMLUtils.TRIGGER).getTextContent;
            dep = Simulink.testadvisor.internal.Dependency( ...
                type, source_id, dest_id, ...
                Simulink.testadvisor.internal.XMLUtils.str_to_trigger(trigger_str));
        end

    end
end
