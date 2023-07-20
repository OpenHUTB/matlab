

classdef SignalLoadController<handle

    properties

Model


View
    end

    properties(Access=private)


ToolGroupName

ContainerObj
    end

    events
SignalModelUpdated

ReadFrameException
    end



    methods

        function this=SignalLoadController(model,view)

            this.Model=model;
            this.View=view;

            configureListeners(this);
        end

    end




    methods
        function openDialog(this,viewInfo,varargin)



            signalInfoTable=getSignalInfo(this.Model);

            open(this.View,signalInfoTable,viewInfo,varargin{:});
            wait(this.View);

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=SignalModelUpdatedEvent(this.Model);
            notify(this,'SignalModelUpdated',evtData);
        end
    end




    methods
        function frameArray=readFrame(this,ts,signalNames)

            timeUnits=getTimeUnits(this.Model);

            if~isdatetime(ts)||~isduration(ts)
                if timeUnits=="datetime"
                    ts=datetime(ts,'ConvertFrom','datenum');
                else
                    ts=seconds(ts);
                end
            end

            if nargin<3
                [frameArray,exception]=readFrame(this.Model,ts);
            else
                [frameArray,exception]=readFrame(this.Model,ts,signalNames);
            end

            if exception.IsTrue
                handleException(this,exception);
            end
        end
    end




    methods
        function loadFromSourceObj(this,sourceObj)

            signalInfo=getSignalInfo(this.Model);

            if height(signalInfo)~=0
                deleteIndices=1;
                deleteSignal(this.Model,deleteIndices);
            end

            loadFromSourceObj(this.View,sourceObj);

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=SignalModelUpdatedEvent(this.Model);
            notify(this,'SignalModelUpdated',evtData);
        end

        function[oldSignalNames,newSignalNames]=handleSourceLoadFailures(this,alternatePaths,showFixInterface)
            sourcesNotLoaded=getSourcesNotLoaded(this.Model);

            oldSignalNames=[];
            newSignalNames=[];

            for idx=1:numel(sourcesNotLoaded)
                sourceId=sourcesNotLoaded(idx).Id;
                sourceName=string(sourcesNotLoaded(idx).SourceName);
                sourceParams=sourcesNotLoaded(idx).SourceParams;
                sourceObj=getSource(this.Model,sourceId);

                if~exist(sourceName,'file')
                    origPath=alternatePaths(1);
                    currentPath=alternatePaths(2);
                    try
                        sourceName=vision.internal.uitools.tryToAdjustPath(char(sourceName),...
                        char(currentPath),char(origPath));

                        sourceParams=sourceObj.fixSourceParams([origPath;currentPath]);
                    catch

                    end
                end


                if showFixInterface
                    if~exist(sourceName,'file')
                        dialogName=vision.getMessage('vision:labeler:LoadErrorTitle');
                        displayMessage=vision.getMessage('vision:labeler:LoadErrorMessage',sourceName);
                        yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
                        no=vision.getMessage('MATLAB:uistring:popupdialogs:No');

                        selection=vision.internal.labeler.handleAlert(this.View,'questionWithWaitDlg',displayMessage,dialogName,...
                        this.ContainerObj,yes,no,yes);

                        if strcmpi(selection,yes)
                            [sourceName,sourceParams]=openFixSourceView(this.View,sourceObj);
                        else

                        end
                    end
                end

                signalNames=fixSource(this.Model,sourceId,sourceName,sourceParams);
                if~isempty(signalNames)
                    oldSignalNames=[oldSignalNames,sourcesNotLoaded(idx).SignalNames'];
                    newSignalNames=[newSignalNames,signalNames];
                end

            end

            confirmChanges(this.Model);
        end

    end




    methods
        function[frameIndices,outTimeVector]=getFrameIndexFromTime(this,timeVector,signalName)

            if nargin<3
                signalNames=getSignalNames(this.Model);
                signalName=signalNames(1);
            else
                signalName=string(signalName);
            end

            timeUnits=getTimeUnits(this.Model);

            if~isdatetime(timeVector)||~isduration(timeVector)
                if timeUnits=="datetime"
                    timeVector=datetime(timeVector,'ConvertFrom','datenum');
                else
                    timeVector=seconds(timeVector);
                end
            end

            [frameIndices,outTimeVector]=getFrameIndexFromTime(this.Model,...
            timeVector,signalName);

            outTimeVector=seconds(outTimeVector);
        end

        function timeVector=getMasterSignalTime(this)
            timeVector=getMasterSignalTime(this.Model);
        end

        function nextTimeStamp=getNextMasterSignalTime(this)
            nextTimeStamp=getNextMasterSignalTime(this.Model);
        end

        function prevTimeStamp=getPrevMasterSignalTime(this)
            prevTimeStamp=getPrevMasterSignalTime(this.Model);
        end

        function lastReadIdx=getLastReadIdx(this,signalIdOrName)
            if nargin<2
                signalIdOrName=1;
            end
            lastReadIdx=getLastReadIdx(this.Model,signalIdOrName);
        end

        function lastReadIdx=getLastReadIdxFromIdNoCheck(this,signalId)
            lastReadIdx=getLastReadIdxFromIdNoCheck(this.Model,signalId);
        end
    end




    methods
        function addToolGroupName(this,toolgroupName)
            this.ToolGroupName=toolgroupName;
        end

        function getContainerObj(this,tool)
            this.ContainerObj=tool;
        end
    end

    methods(Access=private)
        function configureListeners(this)
            addlistener(this.View,'AddSignalSource',@this.addSignalSourceCallback);
            addlistener(this.View,'ConfirmChanges',@this.confirmChangesCallback);
            addlistener(this.View,'RemoveChanges',@this.removeChangesCallback);
            addlistener(this.View,'DeleteSignal',@this.deleteSignalCallback);
            addlistener(this.View,'ModifySignal',@this.modifySignalCallback);

            addlistener(this.Model,'SignalAdded',@this.signalAddedCallback);
            addlistener(this.Model,'SignalMarkedForDelete',@this.signalDeletedCallback);

        end
    end

    methods(Access=private)
        function addSignalSourceCallback(this,~,evtData)
            signalSource=evtData.SignalSourceObj;

            [success,msg]=addSignalSource(this.Model,signalSource);

            if~success
                title=vision.getMessage('vision:labeler:LoadErrorTitle');
                vision.internal.labeler.handleAlert(this.ContainerObj,'error',msg,title);
                resetSignalSource(this.View);
            end

        end

        function signalAddedCallback(this,~,evtData)
            signalInfoTable=evtData.SignalInfoTable;
            updateOnSignalAdd(this.View,signalInfoTable);
        end

        function confirmChangesCallback(this,~,~)
            confirmChanges(this.Model);
        end

        function removeChangesCallback(this,~,~)
            removeChanges(this.Model);
        end

        function deleteSignalCallback(this,~,evtData)
            deleteIndices=evtData.DeleteIndices;
            deleteSignal(this.Model,deleteIndices);
        end

        function signalDeletedCallback(this,~,evtData)
            deleteIndices=evtData.DeleteIndices;
            updateOnSignalDelete(this.View,deleteIndices);
        end

        function modifySignalCallback(this,~,evtData)
            idx=evtData.ModifyIndex;
            data.OldName=evtData.OldName;
            data.NewName=evtData.NewName;

            modifySignal(this.Model,idx,data);
        end

        function handleException(this,exception)

            notify(this,'ReadFrameException');

            dlgTitle=vision.getMessage('vision:labeler:DataSourceReadErrorTitle');

            dlgErrorSourceStr=vision.getMessage('vision:labeler:ErrorEncounteredSource',exception.Source);

            vision.internal.labeler.tool.ExceptionDialog(...
            this.ContainerObj,dlgTitle,exception.ME,...
            'modal',dlgErrorSourceStr);
        end
    end
end