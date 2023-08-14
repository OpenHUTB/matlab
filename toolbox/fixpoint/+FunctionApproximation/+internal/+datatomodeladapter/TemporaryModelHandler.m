classdef TemporaryModelHandler<handle






    properties(SetAccess=private)
        ModelInfo FunctionApproximation.internal.datatomodeladapter.ModelInfo
        ModelName char
TempDirHandler
    end

    methods
        function registerModelInfo(this,modelInfo)




            this.TempDirHandler=FunctionApproximation.internal.TempDirectoryHandler().createDirectory();
            curDir=pwd;
            cd(this.TempDirHandler.TempDir);
            modelName=[modelInfo.ModelName,'.slx'];
            save_system(modelInfo.ModelName,modelName);
            cd(curDir);
            this.ModelName=modelInfo.ModelName;
            unlinkModel(modelInfo);
            this.ModelInfo=modelInfo;
            closeModel(this);
        end

        function delete(this)


            closeModel(this);
        end

        function loadModel(this)

            curDir=pwd;
            cd(this.TempDirHandler.TempDir);
            load_system(this.ModelName);
            cd(curDir);
        end

        function blockPath=getSourceBlockPath(this)

            blockPath=[this.ModelName,'/',this.ModelInfo.SourceBlockName];
        end

        function closeModel(this)

            close_system(this.ModelName,0);
        end
    end
end