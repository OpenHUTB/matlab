
classdef SignalLoadViewSingle<handle

    events
AddSignalSource
DeleteSignal
ModifySignal

ConfirmChanges
RemoveChanges
    end

    methods

        function open(this,signalInfo,viewInfo)



            if height(signalInfo)~=0

                deleteIdx=1;

                import vision.internal.videoLabeler.tool.signalLoading.events.*
                evtData=DeleteSignalEvent(deleteIdx);

                notify(this,'DeleteSignal',evtData);
            end

            viewType=viewInfo.ViewType;

            if viewType=="video"
                this.loadVideo();
            elseif viewType=="imagesequnce"
                this.loadImageSequence();
            elseif viewType=="customimage"
                this.loadCustomReader()
            end

            notify(this,'ConfirmChanges');
        end

        function loadFromSourceObj(this,source)


            try
                import vision.internal.videoLabeler.tool.signalLoading.helpers.*
                signalSource=createMultiSourceFromGTDataSource(source);

            catch ME
                rethrow(ME)
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=AddSignalSourceEvent(signalSource);

            notify(this,'AddSignalSource',evtData);

            notify(this,'ConfirmChanges');

        end

        function wait(~)
        end

        function updateOnSignalAdd(~,~)
        end

        function updateOnSignalDelete(~,~)
        end

        function[sourceName,sourceParams]=openFixSourceView(~,sourceObj)

            if isa(sourceObj,'vision.labeler.loading.VideoSource')
                [fileName,userCanceled]=vision.internal.videoLabeler.videogetfile;

                if~userCanceled
                    sourceName=vision.getFullPathName(fileName);
                else
                    sourceName=[];
                end
                sourceParams=[];


            elseif isa(sourceObj,'vision.labeler.loading.ImageSequenceSource')

                [imgDataStore,timestamps,userCanceled]=...
                vision.internal.videoLabeler.loadImageSequenceDialog();

                if~userCanceled
                    [sourceName,~]=fileparts(imgDataStore.Files{1});
                else
                    sourceName=[];
                end

                sourceParams=[];

                sourceObj.setTimestamps(timestamps);


            elseif isa(sourceObj,'vision.labeler.loading.CustomImageSource')

                [fcnHandle,sourceName,timestamps,userCanceled]=...
                vision.internal.videoLabeler.loadCustomReaderDialog();

                if userCanceled
                    sourceName=[];
                end

                sourceParams=struct();
                sourceParams.FunctionHandle=fcnHandle;

                sourceObj.setTimestamps(timestamps);
            end
        end

        function resetSignalSource(this)
        end
    end

    methods(Access=private)
        function loadVideo(this)

            [fileName,userCanceled]=vision.internal.videoLabeler.videogetfile;

            if userCanceled
                return;
            end


            try
                fullFileName=vision.getFullPathName(fileName);
                signalSource=vision.labeler.loading.VideoSource();
                signalSource.loadSource(fullFileName,[]);
            catch ME
                rethrow(ME)
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=AddSignalSourceEvent(signalSource);

            notify(this,'AddSignalSource',evtData);
        end

        function loadImageSequence(this)

            [imgDataStore,timestamps,userCanceled]=...
            vision.internal.videoLabeler.loadImageSequenceDialog();

            if userCanceled
                return;
            end

            try
                [pathname,~]=fileparts(imgDataStore.Files{1});
                signalSource=vision.labeler.loading.ImageSequenceSource();
                signalSource.setTimestamps(timestamps);
                signalSource.loadSource(pathname,[]);
            catch ME
                rethrow(ME);
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=AddSignalSourceEvent(signalSource);

            notify(this,'AddSignalSource',evtData);
        end

        function loadCustomReader(this)
            [fcnHandle,sourceName,timestamps,userCanceled]=...
            vision.internal.videoLabeler.loadCustomReaderDialog();

            if userCanceled
                return;
            end

            try
                signalSource=vision.labeler.loading.CustomImageSource();
                signalSource.setTimestamps(timestamps);

                sourceParams=struct();
                sourceParams.FunctionHandle=fcnHandle;

                signalSource.loadSource(sourceName,sourceParams);
            catch ME
                rethrow(ME);
            end

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=AddSignalSourceEvent(signalSource);

            notify(this,'AddSignalSource',evtData);
        end
    end

end