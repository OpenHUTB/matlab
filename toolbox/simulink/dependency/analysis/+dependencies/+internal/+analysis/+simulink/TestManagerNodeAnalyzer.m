classdef TestManagerNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        CallbackVariables=i_createCallbackVariables;
        Extensions=".mldatx";
    end

    properties(Access=private,Constant)
        Type=dependencies.internal.graph.Type("RequirementInfo,TestManager");
    end

    methods

        function analyze=canAnalyze(this,handler,node)
            analyze=...
            canAnalyze@dependencies.internal.analysis.FileAnalyzer(this,handler,node)...
            &&strcmp(matlabshared.mldatx.internal.getApplication(node.Location{1}),'SimulinkTest');
        end

        function deps=analyze(this,handler,node)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;




            testFile=node.Location{1};
            files=dependencies.internal.analysis.simulink.getTestFileDependencies(testFile);


            for n=1:length(files)
                value=files(n).Value;
                depType=files(n).Type;


                isStringContent=strcmp(files(n).ValueType,'string');
                if~strcmp(value,node.Location{1})
                    if~isStringContent
                        target=dependencies.internal.graph.Node.createFileNode(value);
                        deps=[deps,dependencies.internal.graph.Dependency(...
                        node,'',target,'',depType)];%#ok<AGROW>
                    else

                        factory=dependencies.internal.analysis.DependencyFactory(...
                        handler,Component.createRoot(node),depType);
                        baseWorkspace=handler.Analyzers.MATLAB.BaseWorkspace;
                        workspace=dependencies.internal.analysis.matlab.Workspace.createAnalysisWorkspace(...
                        baseWorkspace,...
                        this.CallbackVariables);
                        deps=[deps,handler.Analyzers.MATLAB.analyze(value,factory,workspace)];%#ok<AGROW>
                    end
                end
            end


            import dependencies.internal.util.resolveExternalRequirementLinks;
            reqDeps=resolveExternalRequirementLinks(handler,node,this.Type);
            if~isempty(reqDeps)
                deps=[deps,reqDeps];
            end
        end
    end
end


function vars=i_createCallbackVariables

    import dependencies.internal.analysis.matlab.Variable;
    vars=[
    Variable('sltest_testFile',{'sltest.testmanager.TestFile'})
    Variable('sltest_testSuite',{'sltest.testmanager.TestSuite'})
    Variable('sltest_testCase',{'sltest.testmanager.TestCase'})
    Variable('sltest_bdroot')
    Variable('sltest_sut')
    Variable('sltest_isharness')
    Variable('sltest_simout',{'Simulink.SimulationOutput'})
    Variable('sltest_iterationName')
    Variable('sltest_externalInputs')
    Variable('sltest_parameterSets')
    Variable('sltest_configSets')
    Variable('sltest_signalBuilderGroups')
    Variable('sltest_loggedSignalSets')
    Variable('sltest_testSequenceScenarios')
    Variable('sltest_baselines')
    Variable('sltest_tableIterations',{'sltest.testmanager.TestIteration'})
    Variable('test',{'matlab.unittest.TestCase'})
    Variable('TestResult',{'sltest.testmanager.TestCaseResult','sltest.testmanager.TestIterationResult'})
    ]';

end
