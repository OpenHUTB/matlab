classdef slTrainingInstallHelper<handle

    properties(Constant,Hidden)
        SL_ONRAMP_FOLDER=fileparts(mfilename('fullpath'));
        INSTALL_HELPER_FOLDER=fullfile(slTrainingInstallHelper.SL_ONRAMP_FOLDER,'install');
    end

    methods(Static,Access=public)
        function startInstallation()

            assert((exist(fullfile(slTrainingInstallHelper.SL_ONRAMP_FOLDER,'simulinkTraining.m'),'file')~=0)...
            ||(exist(fullfile(slTrainingInstallHelper.SL_ONRAMP_FOLDER,'simulinkTraining.p'),'file')~=0));
            addpath(slTrainingInstallHelper.INSTALL_HELPER_FOLDER);
        end

        function endInstallation()

            assert((exist(fullfile(slTrainingInstallHelper.SL_ONRAMP_FOLDER,'simulinkTraining.m'),'file')~=0)...
            ||(exist(fullfile(slTrainingInstallHelper.SL_ONRAMP_FOLDER,'simulinkTraining.p'),'file')~=0));
            rmpath(slTrainingInstallHelper.INSTALL_HELPER_FOLDER);
        end
    end


    methods(Static,Access=public,Hidden)

        function filepath=getDebugAndTestToolPath()
            [filepath,~,~]=fileparts(mfilename('fullpath'));
            filepath=fullfile(filepath,'debug');
        end
    end

    methods(Access=public)

        function obj=slTrainingInstallHelper()

            slTrainingInstallHelper.startInstallation();
        end
        function delete(obj)

            slTrainingInstallHelper.endInstallation();
        end
    end
end
