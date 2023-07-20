% sltest.testmanager.Test
% base class of TestCase, TestSuite, and TestFile

% Copyright 2015-2020 The MathWorks, Inc.

classdef (Hidden) Test < handle

    properties (SetAccess = protected, GetAccess = {?sltest.testmanager.Test, ?sltest.internal.Helper})
        id int32;
        Saved
        SecondarySaved
    end
    properties (SetAccess = immutable, GetAccess = private)
        className
        testType
    end
    properties (Dependent, SetAccess = private, GetAccess = public)
        Requirements
    end
    properties (Dependent)
        Description
        Enabled
        ReasonForDisabling
        Tags
    end
    
    properties(Dependent,Hidden)
        UUID
        Path
        Releases %Deprecated
        RevisionUUID
    end

    methods
        function obj = Test( className )
            obj.className = className;
            loc = strfind(className, '.');
            obj.testType = className(loc+1 : end);
        end
        
        function out = saveobj(obj)
            out.UUID = obj.UUID;
            out.RevisionUUID = obj.RevisionUUID;
            out.Path = obj.Path;
            out.Type = class(obj);
        end

        %% Check object validity
        function ret = get.id( obj )
            ret = obj.id;
        end
        
        %% Get methods for dependent Test object properties
        function ret = get.Requirements(obj)
            ret = sltest.internal.Helper.getRequirements(obj);
        end
        function ret = get.Description( obj )
            ret = stm.internal.getTestCaseProperty(obj.id, 'Description');
        end
        function ret = get.Enabled( obj )
            ret = stm.internal.getTestCaseProperty(obj.id, 'Enabled');
        end
        function ret = get.ReasonForDisabling( obj )
            if ~obj.Enabled
                ret = stm.internal.getTestProperty(obj.id, obj.testType).reasonForDisabling;
            end
        end
        function ret = get.Saved( obj )
            ret = stm.internal.getTestProperty(obj.id, obj.testType).saved;
        end
        function ret = get.SecondarySaved( obj )
            ret = stm.internal.getTestProperty(obj.id, obj.testType).secondarySaved;
        end
        function ret = get.Tags( obj )
            tagStr = stm.internal.getTestCaseProperty(obj.id, 'TestTags');
            if strlength(tagStr) == 0
                ret = string.empty;
            else
                ret = string(tagStr).split(', ').';
            end
        end
        function ret = get.UUID(obj)
            ret = stm.internal.getTestProperty(obj.id, obj.testType).uuid;
        end
        function ret = get.RevisionUUID(obj)
            ret = stm.internal.getTestProperty(obj.id, obj.testType).revisionuuid;
        end
        function ret = get.Path(obj)
            ret = stm.internal.getTestProperty(obj.id, obj.testType).testFilePath;
        end
        function ret = get.Releases(obj)
            ret = stm.internal.getTestProperty(obj.id, obj.testType, 'releaseNames');
        end

        %% Set methods for dependent Test object properties
        function set.Description( obj, val )
            obj.validateNoMFileExtension('Description');
            func = obj.functionHandle();
            func(obj.id, 'Description', val);
        end
        function set.Enabled( obj, val )
            func = obj.functionHandle();
            func(obj.id, 'Enabled', val);
        end
        function set.ReasonForDisabling( obj, val )
            func = obj.functionHandle();
            func(obj.id, 'ReasonForDisabling', val);
        end
        function set.Tags( obj, val )
            obj.validateNoMFileExtension('Tags');
            tagStr = obj.preprocessingStringArray(val);
            func = obj.functionHandle();
            func(obj.id, 'Tag', tagStr);
        end
        function set.Releases(obj, val)
            obj.validateNoMFileExtension('Releases');
            releaseStr = obj.preprocessingStringArray(val);
            func = obj.functionHandle();
            func(obj.id, 'Release', releaseStr);            
        end
    end

    methods (Access = protected)
        function func = functionHandle(obj)
            if strcmp(obj.className, 'stm.TestCase')
                func = @stm.internal.setTestCaseProperty;
            else
                func = @stm.internal.setTestSuiteProperty;
            end
        end
        
        function str = preprocessingStringArray(~,val)
            validateattributes(val, ["cell", "char", "string"], {'2d'});
            str = string(val).strip.join(',').char;
        end

        setPropertyHelper(obj, NV);
        val = getPropertyHelper(obj, name);
    end
    
    methods (Access = private)
        function validateNoMFileExtension(obj,propertyName) 
            if any(string({obj.Path}).endsWith('.m', 'IgnoreCase', true))
                me = MException(message('stm:ScriptedTest:SettingPropertyNotSupported',propertyName));
                throw(me);
            end
        end
    end
    
    methods (Static)
        %% Modify load process
        function out = loadobj(obj)
            uuid = obj.UUID;
            path = obj.Path;
            type = obj.Type;
            
            % load the test file
            try
                tf = sltest.testmanager.load(path);
            catch
                % seems the file is moved, try just the file name
                [~, fileName, ext] = fileparts(path);
                fileName = [fileName ext];
                tf = sltest.testmanager.load(fileName);
            end
            
            % find the entity corresponding to uuid
            id = stm.internal.getTestIdFromUUIDAndTestFile(uuid, tf.FilePath);
            out = [];
            switch type
                case 'sltest.testmanager.TestFile'
                    out = tf;
                case 'sltest.testmanager.TestCase'
                    out = sltest.testmanager.TestCase(tf,id);
                case 'sltest.testmanager.TestSuite'
                    out = sltest.testmanager.TestSuite(tf,id);
            end
        end

        resultObj = run(obj, type, varargin);
    end

    methods (Static, Hidden)
        function testObj = getTestObjFromID(testID)
            testType = arrayfun(@(id) string(stm.internal.getTestType(id)), testID);
            if all(testType == "testFile")
                testObj = arrayfun(@(id) sltest.testmanager.TestFile("", false, true, id), testID);
            elseif all(testType == "testSuite")
                testObj = arrayfun(@(id) sltest.testmanager.TestSuite([], id), testID);
            elseif all(testType == "simulationTest" | ...
                    testType == "baselineTest" | ...
                    testType == "equivalenceTest" | ...
		            testType == "MATLABUnitTest")
                testObj = arrayfun(@(id) sltest.testmanager.TestCase([], id), testID);
            elseif all(testType == "iteration")
                testObj(numel(testID)) = sltest.testmanager.TestIteration;
                testObj = reshape(testObj, size(testID));
                arrayfun(@(test, id) test.getIterationSettings(id), testObj, testID);
            else
                % non-uniform or unrecognized data
                testObj = sltest.testmanager.Test.empty(numel(testID), 0);
            end
        end

        function txt = replaceControlCharacters(txt)
            arguments
                txt (1,:) char;
            end
            txt(txt <= 31) = ' ';
        end
    end

    methods (Hidden)
        function ret = getID(obj)
            ret = [obj.id];
        end
        function ret = getSaved( obj )
            ret = obj.Saved;
        end
        function ret = getSecondarySaved( obj )
            ret = obj.SecondarySaved;
        end
    end
end
