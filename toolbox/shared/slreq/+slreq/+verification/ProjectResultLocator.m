classdef ProjectResultLocator<handle

    methods(Static)
        function singleObj=getInstance()
            mlock;
            persistent singleton;
            if isempty(singleton)||~isvalid(singleton)
                singleton=slreq.verification.ProjectResultLocator();
            end
            singleObj=singleton;
        end
    end

    methods(Access=private)
        function this=ProjectResultLocator()
        end
    end

    methods

        function scanProject(this)
            try
                proj=simulinkproject;
            catch ME %#ok<NASGU>
                disp('No project loaded');
                return;
            end

            registry=slreq.verification.LinkResultProviderRegistry.getInstance();
            resultProviders=registry.getAllResultProviders();

            for i=1:length(resultProviders)
                resultProviders{i}.scanProject(proj);
            end
        end
    end

    methods(Static)
        function viewInTestManager(testFile,id)
            callback=@()stm.internal.openTestCase(testFile,id);
            sltest.internal.invokeFunctionAfterWindowRenders(callback);
        end
    end

end

