classdef(Abstract)DataCollector<handle





    methods
        function dataContext=collect(~,solutionObject)
            dataContext=FunctionApproximation.internal.visualizer.DataContext();
            dataContext.Feasible=solutionObject.Feasible;
            dataContext.Options=solutionObject.Options;
        end
    end

    methods(Sealed)
        function functionWrapper=getFunctionWrapperForAbsError(~,solutionObject)
            functionWrapper=abs(solutionObject.ErrorFunction.Original-solutionObject.ErrorFunction.Approximation);
        end

        function functionWrapper=getFunctionWrapperForMaxDiff(~,solutionObject)
            functionWrapper=max(abs(solutionObject.ErrorFunction.Original).*solutionObject.Options.RelTol,solutionObject.Options.AbsTol);
        end

        function rangeObject=getRangeObject(~,solutionObject)
            rangeObject=FunctionApproximation.internal.Range(...
            solutionObject.SourceProblem.InputLowerBounds,...
            solutionObject.SourceProblem.InputUpperBounds);
        end
    end

    methods(Static)
        function dataContext=convertJSONToContext(jsonEncoded)


            jsonDecoded=jsondecode(jsonEncoded);
            dataContext=FunctionApproximation.internal.visualizer.DataContext.empty();
            if~isempty(jsonDecoded)
                dataContext=FunctionApproximation.internal.visualizer.DataContext();
                breakpointDimensions=size(jsonDecoded.Breakpoints);
                if breakpointDimensions(1)==1
                    dataContext.Breakpoints={jsonDecoded.Breakpoints'};
                else
                    indices=[ones(1,breakpointDimensions(1)),arrayfun(@(x)x,breakpointDimensions(2:end),'UniformOutput',false)];
                    data=mat2cell(jsonDecoded.Breakpoints,indices{:});
                    dataContext.Breakpoints=cellfun(@(x)squeeze(x),data','UniformOutput',false);
                end
                dataContext.Original=jsonDecoded.Original;
                dataContext.Approximate=jsonDecoded.Approximate;
                dataContext.AbsDiff=jsonDecoded.AbsDiff;
                dataContext.MaxDiff=jsonDecoded.MaxDiff;
                dataContext.Feasible=jsonDecoded.Feasible;
                dataContext.Options=FunctionApproximation.Options('LicenseCheck',false);
                propertyNames=fieldnames(jsonDecoded.Options);
                for iName=1:numel(propertyNames)
                    currentName=propertyNames{iName};
                    value=jsonDecoded.Options.(currentName);
                    if~isempty(value)
                        dataContext.Options.(currentName)=value;
                    end
                end
            end
        end
    end
end
