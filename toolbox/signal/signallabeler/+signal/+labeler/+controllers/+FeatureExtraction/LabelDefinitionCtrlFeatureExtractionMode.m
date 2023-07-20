

classdef LabelDefinitionCtrlFeatureExtractionMode<handle




    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='LabelDefinitionCtrlFeatureExtractionMode';
    end

    events
UpdateFeatureDefsComplete
DeleteFeatureDefsComplete
GetlabelDataForToolstripComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.FeatureExtractionDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=LabelDefinitionCtrlFeatureExtractionMode(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.FeatureExtraction.LabelDefinitionCtrlFeatureExtractionMode;

            this.Dispatcher.subscribe(...
            [LabelDefinitionCtrlFeatureExtractionMode.ControllerID,'/','updatefeaturedef'],...
            @(arg)cb_UpdateFeatureDef(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionCtrlFeatureExtractionMode.ControllerID,'/','deletefeaturedef'],...
            @(arg)cb_DeleteFeaturedef(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionCtrlFeatureExtractionMode.ControllerID,'/','getlabeldatafortoolstrip'],...
            @(arg)cb_GetlabelDataForToolstrip(this,arg));

            this.Dispatcher.subscribe(...
            [LabelDefinitionCtrlFeatureExtractionMode.ControllerID,'/','clearallfeaturedefs'],...
            @(arg)cb_ClearAllFeatureDefs(this,arg));


            this.Dispatcher.subscribe(...
            [LabelDefinitionCtrlFeatureExtractionMode.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)

        function deleteFeatureDefinitions(this,args)


            lblDefIDs=args.data.featureDefIDs;
            args.data=struct('labelData',struct('LabelDefinitionID',''));
            for idx=1:numel(lblDefIDs)
                args.data.labelData.LabelDefinitionID=lblDefIDs(idx);
                this.cb_DeleteFeaturedef(args);
            end
        end




        function cb_HelpButton(~,args)
            data=args.data;

            if strcmp(data.messageID,'edit')
                signal.labeler.controllers.SignalLabelerHelp('editFeatureDefinitionHelp');
            end
        end

        function cb_UpdateFeatureDef(this,args)




            data=args.data.labelData;
            [successFlag,exceptionKeyword,labelDefID,islabelNameChanged]=this.Model.updateLabelDefinitions(data);
            if successFlag

                this.notify('UpdateFeatureDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','closeDialog',...
                'srcWidget',args.data.src,...
                'data',struct('parent',data.ParentLabelDefinitionID))));

                if islabelNameChanged

                    treeOutData=this.Model.getLabelDefinitionsDataForTree(labelDefID);
                    if~isempty(treeOutData)

                        this.notify('UpdateFeatureDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                        'messageID','treeLabelDefData',...
                        'data',treeOutData)));
                    end


                    axesOutData=this.Model.getLabelDefinitionsDataForAxes(labelDefID,[]);
                    for idx=1:length(axesOutData)
                        dataPacket.clientID=args.clientID;
                        dataPacket.signalID=axesOutData(idx).SignalID;
                        dataPacket.memberID=axesOutData(idx).MemberID;
                        dataPacket.labelData=axesOutData(idx);
                        dataPacket.totalChunks=1;

                        this.notify('UpdateFeatureDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                        'messageID','axesLabelDefData',...
                        'data',dataPacket)));
                    end
                else


                    evtData.clientID=args.clientID;
                    evtData.data.id=data.LabelDefinitionID;
                    cb_GetlabelDataForToolstrip(this,evtData);
                end
            else

                this.notify('UpdateFeatureDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','error',...
                'srcWidget',args.data.src,...
                'data',struct('errorID',exceptionKeyword))));
            end
        end

        function cb_DeleteFeaturedef(this,args)




            data=args.data.labelData;
            [labelDefId,info]=this.Model.deleteLabelDefinitions(data);


            treeOutData=this.Model.getLabelDefinitionsDataForTreeOnDelete(info);
            this.notify('DeleteFeatureDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','treeLabelDefData',...
            'data',treeOutData)));


            axesOutData=this.Model.getLabelDefinitionsDataForAxesOnDelete(labelDefId,info);
            for idx=1:length(axesOutData)
                dataPacket.clientID=args.clientID;
                dataPacket.signalID=axesOutData(idx).SignalID;
                dataPacket.memberID=axesOutData(idx).MemberID;
                dataPacket.labelData=axesOutData(idx);

                this.notify('DeleteFeatureDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'messageID','axesLabelDefData',...
                'data',dataPacket)));
            end
        end

        function cb_ClearAllFeatureDefs(this,args)

            args.data=struct('featureDefIDs',this.Model.getModeCreatedFeatureDefinitionIDs());
            this.deleteFeatureDefinitions(args);
        end

        function cb_GetlabelDataForToolstrip(this,args)
            data=args.data;
            outData=this.Model.getLabelDefinitionsData(data);


            this.notify('GetlabelDataForToolstripComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',outData)));
        end
    end
end
