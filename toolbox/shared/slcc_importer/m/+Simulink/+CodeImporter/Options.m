classdef Options<handle

    properties
        PassByPointerDefaultSize(1,1)string="-1";
        CreateTestHarness(1,1)logical=true;

        LibraryBrowserName(1,1)string="";
        SimulateInSeparateProcess(1,1)logical=false;
        UndefinedFunctionHandling(1,1)internal.CodeImporter.UndefinedFunctionHandling=internal.CodeImporter.UndefinedFunctionHandling.FilterOut;
    end


    properties(Hidden)
        ImportTypesToFile(1,1)logical=false;
        ValidateBuild(1,1)logical=true;
        BuildForIPProtection(1,1)logical=false;
    end


    properties(Hidden,Access=private)
        HasSLTest(1,1)logical=false;
        isSLTest(1,1)logical;
    end


    methods
        function obj=Options(HasSLTest,isSLTest)
            if nargin>0
                obj.HasSLTest=HasSLTest;
                obj.CreateTestHarness=obj.HasSLTest;
                obj.isSLTest=isSLTest;
            end
        end
    end


    methods

        function obj=set.PassByPointerDefaultSize(obj,src)
            src=strip(src);
            obj.PassByPointerDefaultSize=src;
        end


        function obj=set.CreateTestHarness(obj,src)
            if~obj.HasSLTest&&src
                warning(message('Simulink:CodeImporter:GenerateTestHarnessIgnored'));
                return;
            end
            obj.CreateTestHarness=src;
        end


        function obj=set.LibraryBrowserName(obj,src)
            src=strip(src);
            if obj.isSLTest&&~isempty(char(src))
                warning(message('Simulink:CodeImporter:GenerateSLBlocksIgnored'));
                return;
            end
            obj.LibraryBrowserName=src;
        end
    end
end

