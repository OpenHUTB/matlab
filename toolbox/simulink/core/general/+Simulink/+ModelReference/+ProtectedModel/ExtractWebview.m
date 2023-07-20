classdef ExtractWebview<handle






    properties(Access=private)
        extractionDir;
    end


    methods(Access=private)

        function obj=ExtractWebview()
            obj.extractionDir=fullfile(tempname,'webview');
        end

    end


    methods(Static)

        function returnDir=getExtractionDir(modelName)
            mlock;
            persistent extractionManager;

            if isempty(extractionManager)
                extractionManager=Simulink.ModelReference.ProtectedModel.ExtractWebview();
            end

            returnDir=fullfile(extractionManager.extractionDir,modelName);
        end

    end

    methods


        function delete(obj)

            if exist(obj.extractionDir,'dir')
                rmdir(obj.extractionDir,'s');
            end

        end

    end

end

