

classdef FeatureExtractor<handle



    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
        CurrentExtractorObj;
        clientID;
    end

    properties(Constant)
        ControllerID='FeatureExtractor';
    end

    events
FeatureExtractionComplete
ShowFeatureExtractionDialogComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.FeatureExtraction.FeatureExtractor(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)
        function this=FeatureExtractor(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.FeatureExtraction.FeatureExtractor;

            this.Dispatcher.subscribe(...
            [FeatureExtractor.ControllerID,'/','extract'],...
            @(arg)cb_Extract(this,arg));

            this.Dispatcher.subscribe(...
            [FeatureExtractor.ControllerID,'/','showfeatureextractiondialog'],...
            @(arg)cb_ShowFeatureExtractionDialog(this,arg));

            this.Dispatcher.subscribe(...
            [FeatureExtractor.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)
        function cleanupForFeatureExtration(this)

            if this.CurrentExtractorObj.NeedCleanUp
                this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',this.clientID,...
                'messageID','error',...
                'data',struct(...
                "exceptionID","cleanup",...
                "exceptionMsg",""))));
            end
        end



        function cb_HelpButton(~,args)

            featureExtractorType=args.data.featureExtractorType;
            switch(featureExtractorType)
            case 'signalfrequency'
                signal.labeler.controllers.SignalLabelerHelp('signalFrequencyFeatureExtractorHelp');
            case 'signaltime'
                signal.labeler.controllers.SignalLabelerHelp('signalTimeFeatureExtractorHelp');
            end
        end

        function cb_ShowFeatureExtractionDialog(this,args)
            args.data.isHaveFeaturesForFeatureExtractor=this.Model.isHaveFeaturesForFeatureExtractor(args.data.featureExtractorType);
            this.notify('ShowFeatureExtractionDialogComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',args.data)));
        end

        function cb_Extract(this,args)

            srcWidget=args.data.srcWidget;
            features=string(args.data.features);
            featureExtractorType=string(args.data.featureExtractorType);
            numFeatures=numel(features);
            this.clientID=args.clientID;
            currentClientID=this.clientID;

            switch featureExtractorType
            case 'signaltime'
                this.CurrentExtractorObj=signal.labeler.controllers.FeatureExtraction.TimeFeatureExtractor(this.Model);
            case 'signalfrequency'
                this.CurrentExtractorObj=signal.labeler.controllers.FeatureExtraction.FrequencyFeatureExtractor(this.Model);
            end
            [successFlag,exceptionInfo]=this.CurrentExtractorObj.setupAndValidateFeatureExtractor(features,args.data);
            if~successFlag
                this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
                'messageID','error',...
                'srcWidget',srcWidget,...
                'data',exceptionInfo)));
                return;
            end


            selectedSignalIndices=this.Model.getSelectedSignalIndices();
            featDefIDs=[];
            frameIdx=-1;
            tx=this.Model.getLabelerModel().Mf0DataModel.beginTransaction;
            for idx=1:numFeatures
                if idx~=numFeatures||numFeatures==1


                    currentIdx=idx;
                    if numFeatures==1&&idx==1


                        currentIdx=0;
                    end
                    this.notifyProgressBar(currentClientID,'featureDefCreateStatus',srcWidget,currentIdx,numFeatures);
                end
                [featDefID,treeFeatureDefData,axesFeatureDefData,frameIdx]=this.Model.createFeatureDefinition(features(idx),args.data,selectedSignalIndices(1),this.CurrentExtractorObj,frameIdx);
                featDefIDs=[featDefIDs;featDefID];
                this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
                'messageID','treeFeatureDefData',...
                'data',treeFeatureDefData)));

                for jdx=1:numel(axesFeatureDefData)
                    dataPacket.clientID=currentClientID;
                    dataPacket.signalID=axesFeatureDefData(jdx).SignalID;
                    dataPacket.memberID=axesFeatureDefData(jdx).MemberID;
                    dataPacket.totalChuncks=1;
                    dataPacket.labelData=axesFeatureDefData(jdx);
                    this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
                    'messageID','axesFeatureDefData',...
                    'data',dataPacket)));
                end
            end

            this.notifyProgressBar(currentClientID,'featureDefCreateStatus',srcWidget,idx,numFeatures);


            memberIDS=string(this.Model.getLabelerModel().getMemberIDs());
            numMembers=numel(memberIDS);
            for idx=1:numMembers
                if idx~=numMembers||numMembers==1


                    currentIdx=idx;
                    if numMembers==1&&idx==1


                        currentIdx=0;
                    end
                    this.notifyProgressBar(currentClientID,'featureCreateStatus',srcWidget,currentIdx,numMembers);
                end
                memberID=memberIDS(idx);
                [successFlag,exceptionInfo,axesFeatureData]=this.CurrentExtractorObj.generateFeaturesAndLabels(memberID,featDefIDs,features,@this.cleanupForFeatureExtration);
                if successFlag
                    for jdx=1:numel(axesFeatureData)
                        dataPacket.clientID=currentClientID;
                        dataPacket.signalID=axesFeatureData(jdx).SignalID;
                        dataPacket.memberID=axesFeatureData(jdx).MemberID;
                        dataPacket.totalChuncks=1;
                        dataPacket.labelData=axesFeatureData(jdx);
                        this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
                        'messageID','axesFeatureData',...
                        'data',dataPacket)));
                    end

                else
                    this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
                    'messageID','deleteFeatureDefs',...
                    'srcWidget',srcWidget,...
                    'data',struct("featureDefIDs",featDefIDs))));

                    this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
                    'messageID','error',...
                    'srcWidget',srcWidget,...
                    'data',exceptionInfo)));
                    tx.rollBack
                    return;
                end
            end
            tx.commit;



            this.notifyProgressBar(currentClientID,'featureCreateStatus',srcWidget,idx,numMembers);
            this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',currentClientID,...
            'messageID','toolstripData',...
            'data',struct('mode',args.data.mode))));
        end
    end

    methods
        function notifyProgressBar(this,clientID,messageID,srcWidget,idx,total)
            if idx==1||idx==total||mod(idx,5)==0

                this.notify('FeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID',messageID,...
                'srcWidget',srcWidget,...
                'data',struct(...
                'index',idx,...
                'total',total))));
            end
        end
    end
end
