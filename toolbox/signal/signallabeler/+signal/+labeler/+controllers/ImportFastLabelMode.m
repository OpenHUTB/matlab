

classdef ImportFastLabelMode<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='ImportFastLabelMode';
    end

    events
ImportFastLabelComplete
PlotSignalsForMemberComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FastLabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.ImportFastLabelMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=ImportFastLabelMode(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.ImportFastLabelMode;

            this.Dispatcher.subscribe(...
            [ImportFastLabelMode.ControllerID,'/','importmembersandlabeldefsinfastlabel'],...
            @(arg)cb_ImportMembersAndLabelDefs(this,arg));

            this.Dispatcher.subscribe(...
            [ImportFastLabelMode.ControllerID,'/','plotsignalsformember'],...
            @(arg)cb_PlotSignalsAndLabelsForMember(this,arg));
        end

    end

    methods(Hidden)




        function cb_ImportMembersAndLabelDefs(this,args)


            this.Model.setAppName('fastLabelMode');


            this.Model.setCheckedSignalIDsCallback();


            treeData=this.Model.getAllLabelDefinitionsDataForTree([]);

            labelDefinitionsData=args.data.labelDefinitionsData;
            if isfield(labelDefinitionsData,'LabelDefinitionID')
                isSelectedInLabeler=num2cell([treeData.id]==string(labelDefinitionsData.LabelDefinitionID));
            else

                isSelectedInLabeler=false(numel(treeData),1);
                isSelectedInLabeler(1)=true;
                isSelectedInLabeler=num2cell(isSelectedInLabeler);
            end
            [treeData.isSelectedInLabeler]=deal(isSelectedInLabeler{:});
            this.notify('ImportFastLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','importLabelDefinitions','data',treeData)));


            treeTableData=this.Model.getImportedSignalsDataForTreeTable();
            this.notify('ImportFastLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','importMembers','data',treeTableData)));


            tableData=this.Model.getTableDataForSignalSelectionWidget();
            this.notify('ImportFastLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','addMinNumOfSignals','data',tableData)));


            this.notify('ImportFastLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','showFastLabelMode','data',args.data)));



            [~,maxNumOfSignals]=this.Model.getMinAndMaxNumberOfSignalsInMembers();
            isVectors=maxNumOfSignals>1;
            this.notify('ImportFastLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','disableSelectionRadioButtons','data',isVectors)));


            this.notify('ImportFastLabelComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','hideSpinner','data',struct)));

        end

        function cb_PlotSignalsAndLabelsForMember(this,args)

            data=args.data;
            if isempty(data.memberID)
                return;
            end
            memberID=str2double(data.memberID);
            clientID=args.clientID;

            signalIDsToBeCleared=[];
            if~isempty(data.memberToBeCleared)



                signalIDsToBeCleared=this.getSelectedSignalIDs(str2double(data.memberToBeCleared));
            end

            isSignalSelectionOKEvent=false;
            if isfield(data,'selectedSignals')
                selectedSignals=data.selectedSignals;

                if isnumeric(selectedSignals)


                    this.Model.setSelectedSignalIndices(selectedSignals);
                elseif selectedSignals=="All"

                    this.Model.setSelectedSignalIndices([]);
                elseif selectedSignals=="First"

                    this.Model.setSelectedSignalIndices(1);
                end
                isSignalSelectionOKEvent=true;
            end

            selectedSignalIDs=this.getSelectedSignalIDs(memberID);



            signalIDsToBeCleared=setdiff(signalIDsToBeCleared,selectedSignalIDs,'stable');

            signalsPlotData=this.Model.getSignalsDataForSignals(selectedSignalIDs,"check");

            this.notify('PlotSignalsForMemberComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','plotSignalsInDisplay','data',signalsPlotData,'signalIDsToBeCleared',signalIDsToBeCleared)));


            this.notify('PlotSignalsForMemberComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','updatePlottedSignals','data',...
            struct('signalIDs',selectedSignalIDs,'isSignalSelectionOKEvent',isSignalSelectionOKEvent))));

            axesLabelData=this.Model.getLabelDataForAxesForPlot(memberID);

            for idx=1:numel(axesLabelData)
                dataPacket.clientID=clientID;
                dataPacket.signalID=axesLabelData(idx).SignalID;
                dataPacket.totalChuncks=1;
                dataPacket.labelData=axesLabelData(idx);
                this.notify('PlotSignalsForMemberComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','labelViewerAxesLabelData','data',dataPacket)));
            end



            isVisibleFlag=true;
            isHighlightedFlag=false;
            axesOutData=this.Model.getFastLabelCreatedLabelDataForAxes(memberID,isVisibleFlag,isHighlightedFlag);

            for idx=1:numel(axesOutData)
                dataPacket.clientID=clientID;
                dataPacket.signalID=axesOutData(idx).SignalID;
                dataPacket.totalChuncks=1;
                dataPacket.labelData=axesOutData(idx);
                this.notify('PlotSignalsForMemberComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                'messageID','labelTimeAxesLabelData','data',dataPacket)));
            end


            this.notify('PlotSignalsForMemberComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','hideSpinner')));

        end
    end

    methods
        function selectedSignalIDs=getSelectedSignalIDs(this,memberID)
            signalIDs=this.Model.getLeafSignalIDsForMemberID(memberID);
            selectedSignalIndices=this.Model.getSelectedSignalIndices();
            if isempty(selectedSignalIndices)
                selectedSignalIDs=signalIDs;
            else
                selectedSignalIDs=signalIDs(selectedSignalIndices);
            end
        end
    end
end
