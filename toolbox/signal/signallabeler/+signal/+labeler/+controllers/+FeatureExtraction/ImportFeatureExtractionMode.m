

classdef ImportFeatureExtractionMode<handle





    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='ImportFeatureExtractionMode';
    end

    events
ImportFeatureExtractionComplete
PlotSignalsForMemberComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.FeatureExtraction.ImportFeatureExtractionMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=ImportFeatureExtractionMode(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.FeatureExtraction.ImportFeatureExtractionMode;

            this.Dispatcher.subscribe(...
            [ImportFeatureExtractionMode.ControllerID,'/','importmembersandlabeldefs'],...
            @(arg)cb_ImportMembersAndLabelDefs(this,arg));
        end

    end

    methods(Hidden)




        function cb_ImportMembersAndLabelDefs(this,args)
            [flag,type,sampleRate]=this.Model.verifySignalsSampleRateAndComplexity();
            if~flag
                this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','error','data',type)));
                return;
            end
            this.Model.setAppName('featureExtractionMode');
            this.Model.setModeSampleRate(sampleRate);



            this.Model.setCheckedSignalIDsCallback();


            treeTableData=this.Model.getImportedSignalsDataForTreeTable();
            this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','importMembers','data',treeTableData)));


            tableData=this.Model.getTableDataForSignalSelectionWidget();
            this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','addMinNumOfSignals','data',tableData)));


            this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','showFeatureExtractionMode','data',args.data)));

            if sampleRate>0
                this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','setSampleRate','data',sampleRate)));
            end



            [~,maxNumOfSignals]=this.Model.getMinAndMaxNumberOfSignalsInMembers();
            isVectors=maxNumOfSignals>1;
            this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','disableSelectionRadioButtons','data',isVectors)));


            this.notify('ImportFeatureExtractionComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','hideSpinner','data',struct)));
        end
    end
end
