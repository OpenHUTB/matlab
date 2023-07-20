classdef LidarAlgorithmSetupHelper<handle




    properties(Access=protected)

Dispatcher



Algorithm


LabelChecker


AppName

    end

    events
CaughtExceptionEvent
    end

    properties(Dependent,SetAccess=private)



ValidROILabelNames




ValidFrameLabelNames



InvalidROILabelIndices



InvalidFrameLabelIndices



ValidLabelDefinitions




AlgorithmInstance
    end

    methods

        function this=LidarAlgorithmSetupHelper(appName)
            this.AppName=appName;

            this.Dispatcher=lidar.internal.lidarLabeler.LidarLabelerAlgorithmDispatcher();
        end


        function configureDispatcher(this,algorithmClass)
            this.Dispatcher.configure(algorithmClass);
        end


        function algorithmClass=getDispatcherAlgorithmClass(this)
            algorithmClass=this.Dispatcher.AlgorithmClass;
        end


        function success=isAlgorithmOnPath(this,hFig)

            if~this.Dispatcher.isAlgorithmOnPath



                cancelButton=vision.getMessage('vision:uitools:Cancel');
                addToPathButton=vision.getMessage('vision:labeler:addToPath');
                cdButton=vision.getMessage('vision:labeler:cdFolder');




                folder=this.Dispatcher.FolderFromRepository;
                alg=sprintf('''%s''',this.Dispatcher.AlgorithmName);

                msg=vision.getMessage(...
                'vision:labeler:notOnPathQuestion',alg,folder);
                dlgTitle=getString(message('vision:labeler:notOnPathTitle'));

                buttonName=vision.internal.labeler.handleAlert(hFig,'question',msg,dlgTitle,...
                cdButton,addToPathButton,cancelButton,cdButton);

                hasCanceled=true;
                switch buttonName
                case cdButton
                    cd(folder);
                case addToPathButton
                    addpath(folder);
                otherwise
                    hasCanceled=true;
                end

                success=~hasCanceled;
            else
                success=true;
            end
        end


        function success=isAlgorithmValid(this,hFig)

            [success,msg]=isAlgorithmValid(this.Dispatcher);

            if~success
                dialogTitle=vision.getMessage('vision:labeler:InvalidAlgorithmTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,dialogTitle);
            end
        end


        function success=instantiateAlgorithm(this)

            success=false;
            try
                this.Dispatcher.instantiate();
                this.Algorithm=this.Dispatcher.Algorithm;
            catch ME
                dlgTitle='vision:labeler:CantInstantiateAlgorithmTitle';
                showExceptionMessage(this,ME,dlgTitle);
                return;
            end
            success=true;
        end


        function fixAlgorithmTimeInterval(this,interval,intervalIndices,isAutomationFwd)

            if hasTemporalContext(this.Algorithm)
                setAlgorithmTimes(this.Algorithm,interval,intervalIndices);
                setAutomationDirection(this.Algorithm,isAutomationFwd);
                if isAutomationFwd
                    updateCurrentTime(this.Algorithm,interval(1));
                else
                    updateCurrentTime(this.Algorithm,interval(2));
                end
            end
        end


        function setAlgorithmLabelData(this,labels)

            setVideoLabels(this.Algorithm,labels);
        end


        function success=checkValidLabels(this,roiLabelList,frameLabelList,signalType,hFig)

            success=false;
            try
                import lidar.internal.labeler.tool.AlgorithmLabelChecker;
                this.LabelChecker=AlgorithmLabelChecker(this.Algorithm,roiLabelList,frameLabelList,signalType);
            catch ME
                dlgTitle='vision:labeler:CantValidateLabels';
                showExceptionMessage(this,ME,dlgTitle);
                return;
            end

            if~isAlgorithmSelectionConsistent(this.LabelChecker)



                onlyVoxelLabelsDefined=~isempty({this.LabelChecker.ROILabelDefinitions.Type});
                for i=1:numel(this.LabelChecker.ROILabelDefinitions)
                    onlyVoxelLabelsDefined=onlyVoxelLabelsDefined&&(this.LabelChecker.ROILabelDefinitions(i).Type==lidarLabelType.Voxel);
                end

                if onlyVoxelLabelsDefined
                    dlgTitle=vision.getMessage('vision:labeler:UnsupportedLabelsTitle');
                    msg=vision.getMessage('lidar:labeler:VoxelLabelsNotSupported');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,dlgTitle);
                    return;
                end

                dlgTitle=vision.getMessage('vision:labeler:UnsupportedLabelsTitle');
                msg=vision.getMessage('vision:labeler:UnsupportedLabelsMessage');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,dlgTitle);
                return;
            end



            if hasVoxelLabels(this.LabelChecker)

                algName=this.AlgorithmInstance.Name;

                if~onlyVoxelLabels(this.LabelChecker)
                    allValidLabels=[this.ValidROILabelNames,this.ValidFrameLabelNames];
                    validVoxelLabels=this.LabelChecker.ValidVoxelLabelNames;
                    validNonVoxelLabels=setdiff(allValidLabels,validVoxelLabels);

                    dlgTitle=vision.getMessage('vision:labeler:InconsistentLabelsTitle');
                    msg=vision.getMessage('lidar:labeler:OnlyVoxelLabelsMessage',algName,toText(validVoxelLabels),toText(validNonVoxelLabels));

                    okBtn=vision.getMessage('vision:uitools:OK');
                    goBtn=vision.getMessage('vision:labeler:GoToCheckLabelDefinition');
                    btnName=vision.internal.labeler.handleAlert(hFig,'question',msg,dlgTitle,...
                    okBtn,goBtn,okBtn);

                    switch btnName
                    case okBtn

                    case goBtn
                        openCheckLabelDefinition(this.LabelChecker);
                    end
                    return;
                end

                if~allVoxelLabels(this.LabelChecker)
                    invalidVoxelLabels=this.LabelChecker.InvalidVoxelLabelNames;

                    dlgTitle=vision.getMessage('vision:labeler:InconsistentLabelsTitle');
                    msg=vision.getMessage('lidar:labeler:AllVoxelLabelsMessage',algName,toText(invalidVoxelLabels));

                    okBtn=vision.getMessage('vision:uitools:OK');
                    goBtn=vision.getMessage('vision:labeler:GoToCheckLabelDefinition');
                    btnName=vision.internal.labeler.handleAlert(hFig,'question',msg,dlgTitle,...
                    okBtn,goBtn,okBtn);

                    switch btnName
                    case okBtn

                    case goBtn
                        openCheckLabelDefinition(this.LabelChecker);
                    end
                    return;
                end

            end
            success=true;

            labelDefs=this.ValidLabelDefinitions;
            setValidLabelDefinitions(this.Algorithm,labelDefs);

            function text=toText(names)
                if isempty(names)
                    text='';
                elseif numel(names)==1
                    text=names{1};
                else

                    names(1:end-1)=strcat(names(1:end-1),{', '});
                    text=[names{:}];
                end
            end
        end






        function validIdx=importCurrentLabelROIsInAlgoMode(this,rois)

            if size(this.Algorithm.SignalName,1)==1
                if hasTemporalContext(this.Algorithm)
                    currentTime=this.Algorithm.CurrentTime;
                    [roisToImport,validIdx]=computeValidROIs(this.LabelChecker,rois,currentTime);
                else
                    [roisToImport,validIdx]=computeValidROIs(this.LabelChecker,rois);
                end
            end
            importLabels(this.Algorithm,roisToImport);
        end


        function TF=hasSettingsDefined(this)
            TF=hasSettingsDefined(this.Algorithm);
        end


        function isvoxelalg=isVoxelLabelingAlgorithm(this)
            isvoxelalg=false;
            try
                if this.LabelChecker.hasVoxelLabels
                    isvoxelalg=true;
                end
            catch

            end
        end
    end

    methods

        function names=get.ValidROILabelNames(this)
            if isempty(this.LabelChecker)
                names={};
            else
                names=this.LabelChecker.ValidROILabelNames;
            end
        end


        function names=get.ValidFrameLabelNames(this)
            if isempty(this.LabelChecker)
                names={};
            else
                names=this.LabelChecker.ValidFrameLabelNames;
            end
        end


        function labelDefs=get.ValidLabelDefinitions(this)

            roiDefs=this.LabelChecker.ROILabelDefinitions;
            roiDefs(this.LabelChecker.InvalidROILabelIndices)=[];



            if isfield(roiDefs,'VoxelLabelID')&&isempty([roiDefs.VoxelLabelID])
                roiDefs=rmfield(roiDefs,'VoxelLabelID');
            end

            frameDefs=this.LabelChecker.FrameLabelDefinitions;
            frameDefs(this.LabelChecker.InvalidFrameLabelIndices)=[];

            if isempty(roiDefs)&&isempty(frameDefs)
                labelDefs=[];
            else

                if isfield(roiDefs,'VoxelLabelID')
                    if isempty(frameDefs)
                        hasLabelAttribute=isfield(roiDefs,'Attributes');
                        if hasLabelAttribute
                            frameDefs=repmat(struct('Name',[],'Type',[],'Attributes',[],'VoxelLabelID',[]),size(frameDefs));
                        else
                            frameDefs=repmat(struct('Name',[],'Type',[],'VoxelLabelID',[]),size(frameDefs));
                        end
                    else
                        frameDefs(end).VoxelLabelID=[];
                    end
                end
                labelDefs=vertcat(roiDefs,frameDefs);
            end
        end


        function idx=get.InvalidROILabelIndices(this)
            idx=this.LabelChecker.InvalidROILabelIndices;
        end


        function idx=get.InvalidFrameLabelIndices(this)
            idx=this.LabelChecker.InvalidFrameLabelIndices;
        end


        function alg=get.AlgorithmInstance(this)
            alg=this.Algorithm;
        end
    end

    methods(Access=private)

        function showExceptionMessage(this,ME,dlgTitle)

            dlgTitle=vision.getMessage(dlgTitle);
            evtData=vision.internal.labeler.tool.ExceptionEventData(dlgTitle,ME);
            notify(this,'CaughtExceptionEvent',evtData);
        end

    end




    methods(Hidden,Access=public)
        function setSelectedLabelDefinitionsTestingHook(this,labelDef)
            setSelectedLabelDefinitions(this.Algorithm,labelDef);
        end
    end
end




