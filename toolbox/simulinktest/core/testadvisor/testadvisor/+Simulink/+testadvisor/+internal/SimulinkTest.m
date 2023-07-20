classdef SimulinkTest
    properties
        % test name
        Name
        % the tes ttype
        type
        % the path of the test within the test file (lineage)
        TestPath
        % the test parent file
        parent_file
        % the parent file path
        parent_path
        % the actual test entity (sltest.testmanager.TestCase or
        %    sltest.testmanager.TestSuite)
        test_entity
        % uuid
        uuid
    end
    properties(Constant)
        MLDATX_EXT = '.mldatx';
        LINEAGE_DELIM_ESCAPED = ' > ';
        TEST_FILE_CLASS = 'sltest.testmanager.TestFile';
    end
    methods

        % SimulinkTest constructor
        % Input(Name): test name
        % Input(type): test type
        % Input(TestPath): test lineage
        % Input(parent_file): test parent file
        % Input(parent_path): parent file path
        % Output(obj): self
        function obj = SimulinkTest(Name, type, TestPath, parent_file, ...
                parent_path)
             if Simulink.testadvisor.internal.TestAdvisorFeature() == 0
                DAStudio.error('sltest:testadvisor:FeatureNotOn');
            else
                obj.Name = string(Name);
                obj.type = type;
                obj.TestPath = string(TestPath);
                obj.parent_file = string(parent_file);
                obj.parent_path = parent_path;
                obj = obj.get_test();
             end
        end

        % get the actual sltest.testmanager.TestCase or
        %    sltest.testmanager.TestSuite object for a given test
        % Input(obj): self
        % Output(obj): self
        function obj = get_test(obj)
            lineage_list = split(obj.TestPath, obj.LINEAGE_DELIM_ESCAPED);
            desc = matlabshared.mldatx.internal.getDescription( ...
                obj.parent_file);
            if strcmp(DAStudio.message('stm:general:TestFileDescription'), ...
                    desc)
                current_entity = sltest.testmanager.load(obj.parent_file);
                for i=2:numel(lineage_list) - 1
                    current_name = lineage_list(i);
                    current_entity = ...
                        current_entity.getTestSuiteByName(current_name);
                end

                if strcmp(obj.type, 'TestCase')
                    te = current_entity.getTestCaseByName(obj.Name);
                    obj.test_entity = te;
                    obj.uuid = te.UUID;
                else
                    te = current_entity.getTestSuiteByName(obj.Name);
                    obj.test_entity = te;
                    obj.uuid = te.UUID;
                end
            else
                fprintf('Test file "%s" not found!\n', obj.parent_file);
            end
        end

        % run a test
        % Input(obj): self
        % Output(results): the results of the test
        function results = run_test(obj)
            % TODO: need to return results and such, test manager might
            % just pick it up though...
            results = obj.test_entity.run();
        end
    end
end
