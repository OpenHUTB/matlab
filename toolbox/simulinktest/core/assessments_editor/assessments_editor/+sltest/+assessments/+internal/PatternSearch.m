


classdef PatternSearch<sltest.assessments.internal.AssessmentsRunner
    properties
x0
l
u
pName
p
    end

    methods

        function obj=PatternSearch(config)
            obj=obj@sltest.assessments.internal.AssessmentsRunner(config);

            parameters=obj.Parameters;

            obj.pName={};
            obj.x0=zeros(1,numel(parameters));
            obj.l=zeros(1,numel(parameters));
            obj.u=zeros(1,numel(parameters));
            obj.p=zeros(1,numel(parameters));

            for i=1:numel(parameters)
                obj.pName{end+1}=parameters(i).name;
                obj.x0(i)=parameters(i).value;
                obj.l(i)=parameters(i).minValue;
                obj.u(i)=parameters(i).maxValue;
            end
        end


        function setParameters(obj,iteration)
            params=obj.Parameters;
            for i=1:numel(params)
                params(i).value=obj.p(i);
            end
            obj.IterationParameters{iteration}=params;
        end


        function explore(obj)

            function[stop,options,optchanged]=stopFunction(optimValues,options,flag)

                stop=obj.StopCondition(obj)||sltest.assessments.internal.AssessmentsRunner.stop();
                optchanged=[];
            end

            function F=optimizationFunction(p)

                obj.p=p;

                obj.setParameters(obj.Iteration);
                obj.overrideParameters();

                obj.preExec(obj.Iteration);

                fprintf('Simulate [%d]',obj.Iteration);
                obj.SimOut(obj.Iteration)=obj.simulate([]);
                obj.Iteration=obj.Iteration+1;

                res=obj.SimOut(processedId);
                completedIdx=processedId;


                if(isempty(obj.Model))
                    res=[];
                end
                obj.evaluateAssessments(res);

                obj.postExec(completedIdx);
                processedId=processedId+1;
                F=obj.Result(1).Robustness;

                drawnow();
            end

            processedId=1;
            obj.Tic=tic;
            obj.Iteration=1;


            if~isempty(obj.StartupCode)
                evalin('base',obj.StartupCode);
                obj.WorkspaceVars=sltest.assessments.internal.AssessmentsRunner.evalCallback(obj.StartupCode);
            end


            obj.loadModel();


            obj.markSignalForLogging();

            options=optimoptions(@patternsearch,'OutputFcn',@stopFunction,'InitialMeshSize',10);
            [~,~]=patternsearch(@optimizationFunction,obj.x0,[],[],[],[],obj.l,obj.u,[],options);


            obj.revertSignalForLogging();

            obj.closeModel();
        end

    end
end

