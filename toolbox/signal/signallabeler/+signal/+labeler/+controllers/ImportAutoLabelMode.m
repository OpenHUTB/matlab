classdef ImportAutoLabelMode<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
        Engine;
        CurrentArgsData;
    end

    properties(Constant)
        ControllerID='ImportAutoLabelMode';
    end

    events
ImportSignalComplete
SignalDataForSignalSelectionDialog
PlotSignalInAutoLabelMode
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.ImportAutoLabelMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=ImportAutoLabelMode(dispatcherObj,modelObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.ImportAutoLabelMode;

            this.Dispatcher.subscribe(...
            [ImportAutoLabelMode.ControllerID,'/','importsignalstoautomode'],...
            @(arg)cb_ImportSignal(this,arg));

            this.Dispatcher.subscribe(...
            [ImportAutoLabelMode.ControllerID,'/','signalselectionforautomode'],...
            @(arg)cb_ImportSignal(this,arg));

            this.Dispatcher.subscribe(...
            [ImportAutoLabelMode.ControllerID,'/','plotsignalsinautomode'],...
            @(arg)cb_PlotSignalsInAutomode(this,arg));
        end

    end

    methods(Hidden)




        function cb_ImportSignal(this,args)
            data=args.data;
            if data.srcWidget=="toolstrip"
                this.CurrentArgsData=data;
                [isWaitForSelectedSignalDataFromClient,checkedSignalIDs,memberIDs]=this.needToRequestSignalSelectionFromClient(data);
                if isWaitForSelectedSignalDataFromClient

                    signalDataForSignalSelectionDialog=this.Model.getSignalDataForSignalSelectDialog(checkedSignalIDs,memberIDs);
                    this.notify('SignalDataForSignalSelectionDialog',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'data',signalDataForSignalSelectionDialog,...
                    'messageID','signalDataComplete')));
                    return;
                end
                this.CurrentArgsData.memberIDs=memberIDs;
                this.CurrentArgsData.signalIDs=checkedSignalIDs;
            else
                this.CurrentArgsData.memberIDs=data.memberIDs;
                this.CurrentArgsData.signalIDs=data.signalIDs;
            end
            this.Model.setupForAutoLabelMode(this.CurrentArgsData.memberIDs,this.CurrentArgsData.signalIDs,this.CurrentArgsData.labelDefintionsData);

            this.CurrentArgsData.settings=this.Model.getAutoLabelSettingsWidgetData(this.CurrentArgsData.lablerInfo.functionID);
            this.CurrentArgsData.isTimeSpecified=this.Model.getIsTimeSpecified();
            this.notify('ImportSignalComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',this.CurrentArgsData,...
            'messageID','showAutoLabelMode')));
        end

        function cb_PlotSignalsInAutomode(this,args)
            data=args.data;
            this.Model.setAppName('autoLabelMode');
            signalIDs=data.signalIDs;
            displayClientID=str2double(args.clientID);

            signalsOutData=this.Model.getSignalsData(signalIDs,'check');
            if~isempty(signalsOutData)
                this.notify('PlotSignalInAutoLabelMode',signal.internal.SAEventData(struct('clientID',displayClientID,...
                'messageID','importMultipleSignalsInPlot',...
                'actionName','importToAutoLabelMode',...
                'data',signalsOutData)));
            end
            memberIDs=string(data.memberIDs);
            axesLabelData=this.Model.getLabelDataForAxesInAutoLabelModeOnImport(memberIDs);
            for idx=1:numel(axesLabelData)
                dataPacket.clientID=args.clientID;
                dataPacket.signalID=axesLabelData(idx).SignalID;
                dataPacket.totalChuncks=1;
                dataPacket.labelData=axesLabelData(idx);
                this.notify('PlotSignalInAutoLabelMode',signal.internal.SAEventData(struct('clientID',displayClientID,...
                'messageID','axesLabelData',...
                'data',dataPacket)));
            end
            this.notify('PlotSignalInAutoLabelMode',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','hideSpinner',...
            'data',struct)));
        end
    end

    methods(Access=protected)
        function[isWaitForSelectedSignalData,signalIDs,memberIDs]=needToRequestSignalSelectionFromClient(this,data)
            isWaitForSelectedSignalData=false;
            if any(strcmp(data.lablerInfo.functionType,{'sptSingleLabelDef','sptCustomSingleLabelDef'}))
                [signalIDs,memberIDs]=this.Model.getCheckedSignalAndMemberIDs();
                switch data.lablerInfo.functionID
                case 'PeakLabeler'
                    isWaitForSelectedSignalData=numel(signalIDs)~=numel(unique(memberIDs));
                case{'SpeechDetector','SpeechToText'}

                    isWaitForSelectedSignalData=numel(signalIDs)~=numel(unique(memberIDs));
                otherwise

                    isWaitForSelectedSignalData=false;
                end
            end
        end
    end
end
