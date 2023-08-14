classdef SadeaController<handle
    properties
        AlgorithmSettings;
        Algorithm;
        AlgorithmResponse;
        plotX;
        plotY;
        plotZ;
        plotSymbol;
    end

    methods




        function obj=SadeaController(algSettings)




            if~isa(algSettings,'AlgorithmSettings')
                error('You must send AlgorithmSettings to this class contructor');
            end


            obj.AlgorithmResponse=AlgorithmResponse();


            obj.AlgorithmSettings=algSettings;


            obj.Algorithm=Sadea(obj.AlgorithmSettings);
            obj.SetupSADEA();
        end






        function obj=SetupSADEA(obj)



            if strcmp(obj.AlgorithmSettings.PopType,'Constrained')
                obj.Algorithm.bound_v=str2func...
                (obj.AlgorithmSettings.GeometricConstraintFunction);
            end

            obj.Algorithm.hasObj=...
            ~isempty(obj.AlgorithmSettings.ListOfObjectiveFunctions);


            obj.AlgorithmSettings=obj.Algorithm.initSMAS(obj.AlgorithmSettings);


            obj.ConstructResponse();


            obj.AlgorithmResponse.Iterations=obj.Algorithm.iter;
        end






        function obj=Run(obj,times)





            for i=1:times
                obj.Algorithm.Run(obj.AlgorithmSettings);
            end
            obj.ConstructResponse();
        end






        function obj=RunWithPlot(obj,times)









            iterPerf=[];
            for i=1:times
                obj.Algorithm.Run(obj.AlgorithmSettings);
                obj.ConstructResponse();
                perf=...
                Evaluator.Evaluate(obj.AlgorithmSettings,obj.AlgorithmResponse.DesignVector);
                iterPerf(end+1)=perf(1);
                plot(1:i,iterPerf,'-');
                drawnow;
            end
        end






        function obj=RunWithPlots(obj,times)
            for i=1:times
                obj.Algorithm.Run(obj.AlgorithmSettings);
                obj.ConstructResponse();

                if~isempty(obj.AlgorithmSettings.EnableLog)
                    if obj.AlgorithmSettings.EnableLog
                        fprintf('%s \n',obj.AlgorithmResponse.ResponseStrings{obj.AlgorithmResponse.Iterations-1});
                    end
                end

                obj.drawPlots();
                drawnow;
            end
        end

    end

    methods(Hidden)





        function obj=ConstructResponse(obj)








            obj.AlgorithmResponse.Iterations=obj.Algorithm.iter;
            obj.AlgorithmResponse.PerformanceVector=obj.Algorithm.tr;
            obj.AlgorithmResponse.DesignVector=obj.Algorithm.Realbestmem;


            tempMember=obj.AlgorithmResponse.DesignVector;
            for i=1:length(obj.Algorithm.logDims)
                tempMember(obj.Algorithm.logDims(i))=...
                exp(tempMember(obj.Algorithm.logDims(i)))-...
                obj.Algorithm.prevNeg(i);
            end
            obj.AlgorithmResponse.DesignVector=tempMember;


            if strcmp(obj.AlgorithmSettings.ParamType,'Smart')
                funcString=obj.AlgorithmSettings.SmartParamFunction;
                obj.AlgorithmResponse.DesignVector=...
                feval(funcString,...
                obj.AlgorithmResponse.DesignVector);
            end


            if~isempty(obj.Algorithm.perf_best)
                perfString={};
                for i=1:length(obj.Algorithm.perf_best)
                    if i~=length(obj.Algorithm.perf_best)
                        perfString{end+1}=sprintf('%f, ',obj.Algorithm.perf_best(i));
                    else
                        perfString{end+1}=sprintf('%f',obj.Algorithm.perf_best(i));
                    end
                end
                obj.AlgorithmResponse.ResponseStrings{end+1}=['Iteration: ',num2str(length(obj.Algorithm.tr))...
                ,',  Best: ',...
                perfString{:}];
            else
                obj.AlgorithmResponse.ResponseStrings{end+1}=sprintf('Iteration: %d,  Best: %f',...
                length(obj.Algorithm.tr),obj.Algorithm.tr(end));
            end


            if isempty(obj.Algorithm.perf_best)
                obj.AlgorithmResponse.PerformanceVector=obj.Algorithm.tr(end);
            else
                obj.AlgorithmResponse.PerformanceVector=obj.Algorithm.perf_best;
            end



            obj.plotX=1:length(obj.Algorithm.tr);
            obj.plotY=obj.Algorithm.tr;
            obj.plotSymbol='-';


            obj.AlgorithmResponse.MeanStd=obj.Algorithm.MeanStd;
        end
    end

    methods(Access=private)



        function obj=drawPlots(obj)
            if~isempty(obj.AlgorithmSettings.ParentFigure)
                if isa(obj.AlgorithmSettings.ParentFigure,...
                    'matlab.ui.internal.FigureDocument')
                    obj.AlgorithmSettings.ParentFigure.Figure.HandleVisibility='on';
                    obj.AlgorithmSettings.ParentFigure.Figure.Internal=false;
                    set(groot,'CurrentFigure',obj.AlgorithmSettings.ParentFigure.Figure);
                else
                    figure(obj.AlgorithmSettings.ParentFigure);
                end
            end
            populationDiversityPlot=subplot(2,1,1);
            convergenceTrendPlot=subplot(2,1,2);
            plot(populationDiversityPlot,1:length(obj.AlgorithmResponse...
            .MeanStd),obj.AlgorithmResponse...
            .MeanStd,'-');
            grid(populationDiversityPlot,'on');
            plot(convergenceTrendPlot,obj.plotX,obj.plotY,obj.plotSymbol);
            grid(convergenceTrendPlot,'on');
            title(populationDiversityPlot,'Population Diversity');
            title(convergenceTrendPlot,'Convergence Trend');
            yl=ylim(populationDiversityPlot);
            yl(1)=0;
            ylim(populationDiversityPlot,yl);
        end
    end
end

