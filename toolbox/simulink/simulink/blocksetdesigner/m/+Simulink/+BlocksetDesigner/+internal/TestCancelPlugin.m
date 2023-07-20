classdef TestCancelPlugin<matlab.unittest.plugins.TestRunnerPlugin
    properties(SetAccess=private)
Results
    end

    methods(Access=protected)
        function runTestSuite(plugin,pluginData)
            clean=onCleanup(@()plugin.storeResults(pluginData));
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
        end

        function setupTestMethod(plugin,pluginData)
            isCancelled=false;
            if isCancelled
                plugin.cancel();
            end
            setupTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
        end
    end

    methods(Access=public)
        function cancel(plugin)
            error('Simulink:BlockSetDesigner:CancelInterrupt','Test is cancelled');
        end
    end

    methods(Access=private)
        function storeResults(plugin,pluginData)
            plugin.Results=pluginData.TestResult;
        end
    end

end