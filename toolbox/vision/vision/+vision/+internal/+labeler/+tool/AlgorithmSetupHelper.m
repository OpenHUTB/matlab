classdef AlgorithmSetupHelper<handle




    properties(Access=protected)

Dispatcher



Algorithm


        LabelChecker vision.internal.labeler.tool.AlgorithmLabelChecker


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

        function this=AlgorithmSetupHelper(appName)
            this.AppName=appName;

            if isImageLabeler(this)
                this.Dispatcher=vision.internal.imageLabeler.ImageLabelerAlgorithmDispatcher();
            elseif isVideoLabeler(this)
                this.Dispatcher=vision.internal.labeler.VideoLabelerAlgorithmDispatcher();
            else
                this.Dispatcher=vision.internal.videoLabeler.MultiSignalLabelerAlgorithmDispatcher();
            end
        end


        function configureDispatcher(this,algorithmClass)
            this.Dispatcher.configure(algorithmClass);
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


        function success=supportsMultisignalAutomation(this,hFig)
            success=this.Algorithm.supportsMultisignalAutomation;
            if(~success)
                dialogTitle=vision.getMessage('vision:labeler:UnsupportedAlgorithmTitle');
                msg=vision.getMessage('vision:labeler:UnsupportedAlgorithmMessage');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,dialogTitle);
            end
        end


        function success=algorithmInstanceFromSession(this,session)
            success=false;
            try
                session.AlgorithmInstances=getInstance(this.Dispatcher,session.AlgorithmInstances);
                this.Algorithm=this.Dispatcher.Algorithm;
            catch ME
                dlgTitle='vision:labeler:CantInstantiateAlgorithmTitle';
                showExceptionMessage(this,ME,dlgTitle);
                return;
            end
            success=true;
        end


        function[success,algorithms]=instantiateAlgorithm(this,algorithms)
            success=false;
            try
                instantiate(this.Dispatcher);
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
            import vision.internal.labeler.tool.AlgorithmLabelChecker;

            success=false;
            try

                this.LabelChecker=AlgorithmLabelChecker(this.Algorithm,roiLabelList,frameLabelList,signalType);
            catch ME
                dlgTitle='vision:labeler:CantValidateLabels';
                showExceptionMessage(this,ME,dlgTitle);
                return;
            end




            if isa(this.Algorithm,'vision.labeler.FunctionalAutomationAlgorithm')
                success=true;
                labelDefs=this.ValidLabelDefinitions;
                setValidLabelDefinitions(this.Algorithm,labelDefs);
                return
            end

            if~isAlgorithmSelectionConsistent(this.LabelChecker)



                onlyPixelLabelsDefined=~isempty([this.LabelChecker.ROILabelDefinitions.Type])&&all([this.LabelChecker.ROILabelDefinitions.Type]==labelType.PixelLabel);
                if onlyPixelLabelsDefined
                    dlgTitle=vision.getMessage('vision:labeler:UnsupportedLabelsTitle');
                    msg=vision.getMessage('vision:labeler:PixelLabelsNotSupported');
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,dlgTitle);
                    return;
                end

                dlgTitle=vision.getMessage('vision:labeler:UnsupportedLabelsTitle');
                msg=vision.getMessage('vision:labeler:UnsupportedLabelsMessage');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,dlgTitle);
                return;
            end



            if hasPixelLabels(this.LabelChecker)

                algName=this.AlgorithmInstance.Name;

                if~onlyPixelLabels(this.LabelChecker)
                    allValidLabels=[this.ValidROILabelNames,this.ValidFrameLabelNames];
                    validPixelLabels=this.LabelChecker.ValidPixelLabelNames;
                    validNonPixelLabels=setdiff(allValidLabels,validPixelLabels);

                    dlgTitle=vision.getMessage('vision:labeler:InconsistentLabelsTitle');
                    msg=vision.getMessage('vision:labeler:OnlyPixelLabelsMessage',algName,toText(validPixelLabels),toText(validNonPixelLabels));

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

                if~allPixelLabels(this.LabelChecker)
                    invalidPixelLabels=this.LabelChecker.InvalidPixelLabelNames;

                    dlgTitle=vision.getMessage('vision:labeler:InconsistentLabelsTitle');
                    msg=vision.getMessage('vision:labeler:AllPixelLabelsMessage',algName,toText(invalidPixelLabels));

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
            else
                roisToImport=cell(1,size(this.Algorithm.SignalName,1));
                validIdx=cell(1,size(this.Algorithm.SignalName,1));
                for i=1:size(this.Algorithm.SignalName,1)
                    if hasTemporalContext(this.Algorithm)
                        currentTime=this.Algorithm.CurrentTime;
                        [roisToImport{i},validIdx{i}]=computeValidROIs(this.LabelChecker,rois{i},currentTime);
                    else
                        [roisToImport{i},validIdx{i}]=computeValidROIs(this.LabelChecker,rois{i});
                    end
                end
            end
            importLabels(this.Algorithm,roisToImport);
        end


        function TF=hasSettingsDefined(this)
            TF=hasSettingsDefined(this.Algorithm);
        end


        function ispixelalg=isPixelLabelingAlgorithm(this)
            ispixelalg=false;
            try
                if this.LabelChecker.hasPixelLabels
                    ispixelalg=true;
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



            if isfield(roiDefs,'PixelLabelID')&&isempty([roiDefs.PixelLabelID])
                roiDefs=rmfield(roiDefs,'PixelLabelID');
            end

            frameDefs=this.LabelChecker.FrameLabelDefinitions;
            frameDefs(this.LabelChecker.InvalidFrameLabelIndices)=[];

            if isempty(roiDefs)&&isempty(frameDefs)
                labelDefs=[];
            else

                if isfield(roiDefs,'PixelLabelID')
                    if isempty(frameDefs)
                        hasLabelAttribute=isfield(roiDefs,'Attributes');
                        if hasLabelAttribute
                            frameDefs=repmat(struct('Name',[],'Type',[],'Attributes',[],'PixelLabelID',[]),size(frameDefs));
                        else
                            frameDefs=repmat(struct('Name',[],'Type',[],'PixelLabelID',[]),size(frameDefs));
                        end
                    else
                        frameDefs(end).PixelLabelID=[];
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


        function tf=isImageLabeler(this)
            tf=strcmpi(this.AppName,'imageLabeler');
        end


        function tf=isVideoLabeler(this)
            tf=strcmpi(this.AppName,'videoLabeler');
        end
    end




    methods(Hidden,Access=public)
        function setSelectedLabelDefinitionsTestingHook(this,labelDef)
            setSelectedLabelDefinitions(this.Algorithm,labelDef);
        end
    end
end
