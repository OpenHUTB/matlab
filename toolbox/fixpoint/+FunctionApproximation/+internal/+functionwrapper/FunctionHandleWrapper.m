classdef(Sealed)FunctionHandleWrapper<FunctionApproximation.internal.functionwrapper.AbstractWrapper







    properties(SetAccess=private)
        TempDirHandler=[]
        FileDependencies={}
    end

    methods
        function this=FunctionHandleWrapper(functionHandle)
            generator=FunctionApproximation.internal.StandardFunctionHandleGenerator(functionHandle);
            this.FunctionToEvaluate=generator.FunctionHandle;
            this.NumberOfDimensions=generator.NumberOfDimensions;
            if isvarname(generator.extractFunctionName)




                navigator=matlab.depfun.internal.ProductComponentModuleNavigator();
                componentName=navigator.componentOwningBuiltin(generator.extractFunctionName);


                if isempty(componentName)
                    this.FileDependencies=matlab.codetools.requiredFilesAndProducts(generator.extractFunctionName);
                end
            end
            if~isempty(this.FileDependencies)
                this.TempDirHandler=FunctionApproximation.internal.TempDirectoryHandler();
                this.TempDirHandler.createDirectory();
                curDir=pwd;
                cd(this.TempDirHandler.TempDir);
                for iFile=1:numel(this.FileDependencies)
                    [~,filename,fileExt]=fileparts(this.FileDependencies{iFile});
                    destinationFile=[this.TempDirHandler.TempDir,filesep,filename,fileExt];
                    copyfile(this.FileDependencies{iFile},destinationFile,'f');
                end
                cd(curDir);
            end
        end

        function delete(this)
            if~isempty(this.TempDirHandler)
                delete(this.TempDirHandler);
            end
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            if~isempty(this.TempDirHandler)
                outputValue=executeWithDependencies(this,inputs);
            else
                outputValue=executeWithoutDependencies(this,inputs);
            end
        end
    end

    methods(Access=private)
        function outputValue=executeWithDependencies(this,inputs)
            curDir=pwd;
            cd(this.TempDirHandler.TempDir);
            outputValue=executeWithoutDependencies(this,inputs);
            cd(curDir);
        end

        function outputValue=executeWithoutDependencies(this,inputs)
            if this.getVectorized()
                outputValue=this.FunctionToEvaluate(inputs);
            else
                N=size(inputs,1);
                outputValue=zeros(N,1);
                for idx=1:N
                    outputValue(idx)=this.FunctionToEvaluate(inputs(idx,:));
                end
            end
        end
    end
end
