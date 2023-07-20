classdef JSMiscService<handle




    methods
        function utilOpenEMHelp(~)
            helpview('deeplearning','exp-mgr-app-ref');
        end

        function utilOpenEMGetStartedHelp(~)
            helpview('nnet','exp-mgr-get-started');
        end

        function utilOpenEMExample(~,data)
            cd(setupExample(data.exampleName));
            setupExpMgr(data.projectName);
        end
    end
end
