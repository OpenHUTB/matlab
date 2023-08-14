classdef AudioModeController<handle







    properties(Constant)
        ControllerID='AudioModeController';
    end

    properties(SetAccess=protected)

DataRepositoryModel

ImportAudioController
AudioPlaybackController
    end

    properties(Access=protected,Transient)
        IsInitialized(1,1)logical=false;
    end

    properties(Access=protected,Constant,Transient)
        AudioToolboxLicenseName='Audio_System_Toolbox';
        AudioToolboxVersion=ver('audio');
        DSPSystemToolboxLicenseName='Signal_Blocks';
        DSPSystemToolboxVersion=ver('dsp');
    end

    methods(Static)
        function ctrl=getInstance()

            persistent ctrlObj
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                ctrlObj=audio.labeler.internal.AudioModeController;
            end
            ctrl=ctrlObj;
        end

        function flag=isAudioToolboxInstalled()

            import audio.labeler.internal.*
            flag=~isempty(AudioModeController.AudioToolboxVersion)&&...
            builtin('license','test',AudioModeController.AudioToolboxLicenseName);
        end

        function[success,errMsg]=checkoutAudioToolboxLicense()

            import audio.labeler.internal.*
            [success,errMsg]=builtin('license','checkout',...
            AudioModeController.AudioToolboxLicenseName);
            success=logical(success);
        end

        function[success,errMsg]=checkoutDSPSystemToolboxLicense()

            import audio.labeler.internal.*
            [success,errMsg]=builtin('license','checkout',...
            AudioModeController.DSPSystemToolboxLicenseName);
            success=logical(success);
        end

        function flag=isAudioPlaybackSupported()


            import matlab.internal.lang.capability.*
            flag=audio.labeler.internal.AudioModeController.isAudioToolboxInstalled()&&...
            Capability.isSupported(Capability.LocalClient);
        end
    end

    methods(Access=protected)
        function this=AudioModeController()

        end
    end

    methods
        function delete(this)

            delete(this.ImportAudioController);
            delete(this.AudioPlaybackController);

            munlock;
        end

        function initialize(this)



            if~this.IsInitialized&&this.isAudioToolboxInstalled()
                createModels(this);
                createControllers(this);
                this.IsInitialized=true;
            end
        end

        function resetModels(this)

            if~isempty(this.AudioPlaybackController)&&isvalid(this.AudioPlaybackController)
                resetPlaybackModels(this.AudioPlaybackController);
            end
        end
    end

    methods(Access=protected)
        function createModels(this)

            this.DataRepositoryModel=audio.labeler.internal.AudioDataRepository.getModel();
        end

        function createControllers(this)


            this.ImportAudioController=audio.labeler.internal.ImportAudioController.getInstance();
            if audio.labeler.internal.AudioModeController.isAudioPlaybackSupported()



                this.AudioPlaybackController=audio.labeler.internal.AudioPlaybackController.getInstance();
            end
        end
    end
end
