classdef AudioPlaybackController<handle




    properties(Constant)
        ControllerID='AudioPlaybackController';
    end

    properties(SetAccess=protected)

Dispatcher
Engine
Model
CurrentClientID

AudioDataReader
AudioPlayer

PlaybackStateChangedListener
PlaybackSteppedListener

PlaybackUpdateTimer
    end

    properties(Constant,Access=protected)

        UPDATE_INTERVAL=1/10;
    end

    methods(Static)
        function ctrl=getInstance()

            persistent ctrlObj
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=audio.labeler.internal.AudioDataRepository.getModel();
                sdiEngine=Simulink.sdi.Instance.engine();
                ctrlObj=audio.labeler.internal.AudioPlaybackController(...
                dispatcherObj,modelObj,sdiEngine);
            end
            ctrl=ctrlObj;
        end
    end

    methods(Access=protected)
        function this=AudioPlaybackController(dispatcherObj,modelObj,sdiEngine)



            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.Engine=sdiEngine;



            ctrlID=audio.labeler.internal.AudioPlaybackController.ControllerID;
            dispatcherObj.subscribe([ctrlID,'/','audioselectplayer'],...
            @(arg)cb_SelectPlayer(this,arg));
            dispatcherObj.subscribe([ctrlID,'/','audiorefreshplayerdevices'],...
            @(arg)cb_RefreshPlayerDevices(this,arg));


            dispatcherObj.subscribe([ctrlID,'/','audioplaybackstart'],...
            @(arg)cb_AudioPlaybackStart(this,arg));
            dispatcherObj.subscribe([ctrlID,'/','audioplaybackstop'],...
            @(arg)cb_AudioPlaybackStop(this,arg));
            dispatcherObj.subscribe([ctrlID,'/','audioplaybackskipback'],...
            @(arg)cb_AudioPlaybackSkipBack(this,arg));
            dispatcherObj.subscribe([ctrlID,'/','audioplaybackskipforward'],...
            @(arg)cb_AudioPlaybackSkipForward(this,arg));
            dispatcherObj.subscribe([ctrlID,'/','audioplaybackrepeat'],...
            @(arg)cb_AudioPlaybackRepeat(this,arg));


            dispatcherObj.subscribe([ctrlID,'/','appmodechanged'],...
            @(arg)cb_AppModeChanged(this,arg));
            dispatcherObj.subscribe([ctrlID,'/','audiosignalselectionchanged'],...
            @(arg)cb_SignalSelectionChanged(this,arg));
        end

        function player=createAudioPlayer(this)




            player=[];
            if~audio.labeler.internal.AudioModeController.checkoutAudioToolboxLicense()
                ME=MException(message('shared_audiosiglabeler:labeler:AudioToolboxLicenseFailedAtPlayback'));
                handleException(this,ME);
                return
            end


            player=this.AudioPlayer;
            if isempty(player)


                if~audio.labeler.internal.AudioModeController.checkoutDSPSystemToolboxLicense()
                    ME=MException(message('shared_audiosiglabeler:labeler:DSPSystemToolboxLicenseFailedAtPlayback'));
                    handleException(this,ME);
                    return
                end


                try
                    player=audio.app.internal.device.AudioPlayerModel;
                catch ME
                    handleException(this,ME);
                    return
                end
                this.AudioPlayer=player;
                this.AudioDataReader=getAudioDataReader(player);


                this.PlaybackUpdateTimer=scopesutil.OneShotTimer(this.UPDATE_INTERVAL);
                start(this.PlaybackUpdateTimer);


                this.PlaybackStateChangedListener=addlistener(player.PlayerStateManager,...
                'SimulationStateChanged',@this.onPlaybackStateChanged);
                this.PlaybackSteppedListener=addlistener(player.PlayerStateManager,...
                'SimulationStepped',@this.onPlaybackStepped);
            end
        end
    end

    methods
        function delete(this)

            delete(this.PlaybackStateChangedListener);
            delete(this.PlaybackSteppedListener);
            delete(this.AudioPlayer);
            delete(this.PlaybackUpdateTimer);

            munlock;
        end

        function flag=isPlayerActive(this)

            flag=~isempty(this.AudioPlayer)&&...
            (isPlaying(this.AudioPlayer)||isPaused(this.AudioPlayer));
        end

        function resetPlaybackModels(this)

            if isPlayerActive(this)
                stop(this.AudioPlayer,'release-and-clear');
            end
        end
    end


    methods(Hidden)
        function cb_SelectPlayer(this,args)
            if isfield(args.data,'newValue')
                audioPlayer=createAudioPlayer(this);
                audioPlayer.Device=args.data.newValue;
            end
        end

        function cb_RefreshPlayerDevices(this,args)

            this.CurrentClientID=args.clientID;
            refreshAudioDevices(this);
        end

        function cb_AppModeChanged(this,~)


            if isPlayerActive(this)
                stop(this.AudioPlayer);
            end
        end

        function cb_SignalSelectionChanged(this,~)


            if isPlayerActive(this)

                stop(this.AudioPlayer);
            else



                notifyPlaybackStateChanged(this,'ready');
            end
        end
    end


    methods(Hidden)
        function cb_AudioPlaybackStart(this,args)

            this.CurrentClientID=args.clientID;



            audioPlayer=createAudioPlayer(this);
            if isempty(audioPlayer)
                return
            end


            try
                if isPlaying(audioPlayer)
                    pause(audioPlayer);
                elseif isPaused(audioPlayer)


                    play(audioPlayer);
                else

                    playbackRange=[];
                    if~isempty(args.data)&&isfield(args.data,'LabelInstanceTimeMinValues')...
                        &&~isempty(args.data.LabelInstanceTimeMinValues)...
                        &&isfield(args.data,'LabelInstanceTimeMaxValues')...
                        &&~isempty(args.data.LabelInstanceTimeMaxValues)
                        playbackRange=[args.data.LabelInstanceTimeMinValues,...
                        args.data.LabelInstanceTimeMaxValues];
                    end
                    setupDataReader(this,playbackRange);
                    play(audioPlayer);
                end
            catch ME
                stop(audioPlayer,'force-release');
                handleException(this,ME);
            end
        end

        function cb_AudioPlaybackStop(this,args)

            this.CurrentClientID=args.clientID;
            try
                stop(this.AudioPlayer);
            catch ME
                handleException(this,ME);
            end
        end

        function cb_AudioPlaybackSkipBack(this,args)

            this.CurrentClientID=args.clientID;
            try
                skipBack(this.AudioPlayer,5);
            catch ME
                handleException(this,ME);
            end
        end

        function cb_AudioPlaybackSkipForward(this,args)

            this.CurrentClientID=args.clientID;
            try
                skipForward(this.AudioPlayer,5);
            catch ME
                handleException(this,ME);
            end
        end

        function cb_AudioPlaybackRepeat(this,args)

            this.CurrentClientID=args.clientID;
            val=~isempty(args.data)&&isfield(args.data,'newValue')...
            &&args.data.newValue;
            player=createAudioPlayer(this);
            if~isempty(player)
                setPlayInLoop(player,val);
            end
        end

        function setupDataReader(this,playbackRange)


            signalIDs=getCheckedSignalAndMemberIDs(this.Model);
            dataReader=this.AudioDataReader;
            if~isempty(signalIDs)
                [y,fs]=getSignalData(this.Model,signalIDs);
                dataReader.AudioSource=y;
                dataReader.SampleRate=fs;


                if fs<=8000
                    dataReader.SamplesPerFrame=128;
                elseif fs<=16000
                    dataReader.SamplesPerFrame=256;
                else
                    dataReader.SamplesPerFrame=512;
                end
                dataReader.setReadRangeInSeconds(playbackRange);
            else
                dataReader.AudioSource=[];
            end
        end

        function onPlaybackStateChanged(this,~,ed)


            try
                evData=ed.EventData;

                notifyPlaybackStateChanged(this,evData.NewState);
            catch ME
                stop(this.AudioPlayer,true);
                handleException(this,ME);
            end
        end

        function onPlaybackStepped(this,~,~)

            if this.PlaybackUpdateTimer.isTimeUp
                start(this.PlaybackUpdateTimer);
                elapsedTime=getElapsedTime(this.AudioDataReader);
                notifyPlaybackTimeStatus(this,elapsedTime);
            end
        end

        function handleException(this,ME)

            info.ErrorID=ME.identifier;
            info.ErrorMsg=ME.message;
            this.Dispatcher.publishToClient(this.CurrentClientID,...
            'audioTabController','playbackError',info);
        end
    end

    methods(Access=protected)
        function refreshAudioDevices(this)

            player=createAudioPlayer(this);
            if~isempty(player)
                refreshDevices(player);
                data.playerDevices=getAudioDevices(player);
                data.selectedDevice=player.Device;

                this.Dispatcher.publishToClient(this.CurrentClientID,...
                'audioTabController','audioDevicesRefreshed',data);
            end
        end

        function notifyPlaybackStateChanged(this,playbackState)

            enabledButtons=cell2struct(repmat({false},5,1),...
            {'play','stop','skipBack','skipForward','repeat'});
            playButtonMode='';




            switch playbackState
            case 'running'
                playButtonMode='pause';
                enabledButtons.stop=true;
                enabledButtons.skipBack=true;
                enabledButtons.skipForward=true;
            case 'paused'
                playButtonMode='continue';
                enabledButtons.play=true;
                enabledButtons.stop=true;
                enabledButtons.skipBack=true;
                enabledButtons.skipForward=true;
                enabledButtons.repeat=true;
            case 'ready'


                [validFlag,errorID]=isValidStateForAudioPlayback(this.Model);
                if validFlag
                    playButtonMode='play';
                    enabledButtons.play=true;
                    enabledButtons.repeat=true;
                else
                    playbackState='badstate';
                end
            end
            outDataStruct=struct('playbackState',playbackState,...
            'enabledButtons',enabledButtons,...
            'playButtonMode',playButtonMode);
            if strcmp(playbackState,'badstate')
                outDataStruct.errorID=errorID;
            end
            this.Dispatcher.publishToClient(this.CurrentClientID,...
            'audioTabController','updatePlaybackState',outDataStruct);
        end

        function notifyPlaybackTimeStatus(this,playbackTime)

            evtData=struct('playbackTimeInSeconds',playbackTime);
            this.Dispatcher.publishToClient(this.CurrentClientID,...
            'audioTabController','updatePlaybackTime',evtData);
        end
    end
end
