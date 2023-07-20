

classdef Import<handle



    properties(Hidden)
        Model;
    end

    properties(Access=protected)
        Dispatcher;
        Engine;
        MemberNames;
    end

    properties(Constant)
        ControllerID='Import';
    end

    events
ImportLabelDefsComplete
ImportSignalComplete
LazyLoadImportSignalComplete
SwitchAcitveApp
SignalDataForAutoLabelDialog
DirtyStateChanged
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.Import(dispatcherObj,modelObj);
            end


            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=Import(dispatcherObj,modelObj)

            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            this.MemberNames=[];
            import signal.labeler.controllers.Import;

            this.Dispatcher.subscribe(...
            [Import.ControllerID,'/','importsignals'],...
            @(arg)cb_ImportSignal(this,arg));

            this.Dispatcher.subscribe(...
            [Import.ControllerID,'/','getchildrenforautolabeldialog'],...
            @(arg)cb_GetChildrenDataForAutoLabelDialog(this,arg));

            this.Dispatcher.subscribe(...
            [Import.ControllerID,'/','importlabeldef'],...
            @(arg)cb_ImportLabelDefinitions(this,arg));

            this.Dispatcher.subscribe(...
            [Import.ControllerID,'/','labelerapphelp'],...
            @(arg)cb_HelpButton(this,arg));
        end
    end

    methods(Hidden)



        function[successFlag,isShowIncompatibleLabelWarning]=importSignal(this,clientID,signalIDs,lss,signalColoringType)
            if nargin<4
                lss=[];
                signalColoringType="differentColors";
            elseif nargin<5
                signalColoringType="differentColors";
            end
            importToAppArgs.clientID=clientID;
            importToAppArgs.data.signalIDs=signalIDs;
            [successFlag,isShowIncompatibleLabelWarning]=cb_ImportSignal(this,importToAppArgs,lss,signalColoringType);
        end

        function successFlag=importChildrenSignal(this,clientID,memberID,childIDs,isLazyLoadingChildernSignal,srcAction)
            leafIDs=[];
            for idx=1:numel(childIDs)
                currentLeafIDs=this.Model.getAllSignalLeafChildrenIDs(childIDs(idx));
                if isempty(currentLeafIDs)
                    currentLeafIDs=childIDs(idx);
                end
                leafIDs=[leafIDs;currentLeafIDs(:)];%#ok<AGROW>
            end
            this.Model.addAllCheckableSignalIDs(leafIDs);
            this.Model.setLeafSignalIDsForMemberID(memberID,leafIDs);
            importToAppArgs.clientID=clientID;
            importToAppArgs.data.parentIDs={string(memberID)};
            importToAppArgs.data.isLazyLoadingChildernSignal=isLazyLoadingChildernSignal;
            importToAppArgs.data.srcAction=srcAction;





            if(this.Model.isExistInMemberIDcolorRuleMap(memberID))
                coloringType=this.Model.getMemberColorFromMemberIDcolorRuleMap(memberID);
                if(coloringType=="sameColors"||coloringType=="sameColoring"||coloringType=="changeAllSignalColorsToMemberColor")
                    this.Model.makeSignalColorsSameAsGivenParent(memberID);
                elseif(coloringType=="SameColoringAcrossMembers"||coloringType=="sameColoringAcrossMembers")
                    this.Model.makeSignalColorsSameAcrossMember(memberID);
                else
                    this.Model.makeSignalColorsDifferentFromGivenParent(memberID);
                end
                this.Model.removeFromMemberIDcolorRuleMap(memberID);
            end

            if srcAction=="check"
                this.Model.setPlotSignalAfterLazyLoadComplete(true);
            end
            successFlag=cb_GetChildren(this,importToAppArgs)&&...
            cb_GetChildrenDataForAutoLabelDialog(this,importToAppArgs);
        end




        function cb_HelpButton(~,args)
            data=args.data;

            if strcmp(data.messageID,'importLabelDefinition')
                signal.labeler.controllers.SignalLabelerHelp('importLabelDefinitionHelp');
            end

            if strcmp(data.messageID,'importSignals')
                signal.labeler.controllers.SignalLabelerHelp('importSignalsHelp');
            end
        end

        function[successFlag,isShowIncompatibleLabelWarning]=cb_ImportSignal(this,args,lss,signalColoringType)
            successFlag=true;
            isShowIncompatibleLabelWarning=false;
            if nargin<3
                lss=[];
                signalColoringType="differentColors";
            elseif nargin<4
                signalColoringType="differentColors";
            end
            inputIDs=args.data.signalIDs;
            numberOfInputIDs=length(inputIDs);
            memberIDs=[];
            nonLSSMemberIDs=[];
            lssMemberIDs=[];
            lssInfo=[];
            allCheckableSignalIDs=[];
            addSignalsSuccessFlag=false;
            for idx=1:numberOfInputIDs
                isSignalVerficationNeeded=false;
                currentID=signal.sigappsshared.SignalUtilities.getSignalSuperparent(this.Engine,inputIDs(idx));
                currentMemberIDTmMode=getSignalTmMode(this.Engine,currentID);
                if strcmp(currentMemberIDTmMode,'inherentLabeledSignalSet')




                    if isempty(lssInfo)||isempty(find([lssInfo.lssSuperParentID]==currentID,1))

                        currentLSSInfo=struct('lssSuperParentID',currentID,'lssMemberIDs',[]);

                        currentID=getSignalChildren(this.Engine,currentID);
                        isSignalVerficationNeeded=true;
                        for cdx=1:numel(currentID)
                            currentID(cdx)=this.Model.correctMemberIDIfComplexSignal(currentID(cdx));
                        end
                        memberIDs=[memberIDs;currentID(:)];%#ok<AGROW>
                        currentLSSInfo.lssMemberIDs=currentID(:);
                        setMemberNames(lss,string(currentID(:)));
                        lssMemberIDs=currentLSSInfo.lssMemberIDs;
                        lssInfo=[lssInfo;currentLSSInfo];%#ok<AGROW>
                    end
                elseif strcmp(currentMemberIDTmMode,'file')&&~isempty(lss)
                    memberIDs=[memberIDs;currentID(:)];%#ok<AGROW>
                    lssMemberIDs=[lssMemberIDs;currentID(:)];%#ok<AGROW>
                    isSignalVerficationNeeded=true;
                elseif isempty(find(memberIDs==currentID,1))


                    currentID=this.Model.correctMemberIDIfComplexSignal(currentID);
                    memberIDs=[memberIDs;currentID];%#ok<AGROW>
                    nonLSSMemberIDs=[nonLSSMemberIDs;currentID];%#ok<AGROW>
                    isSignalVerficationNeeded=true;
                end

                if isSignalVerficationNeeded
                    [addSignalsSuccessFlag,currentLeafSignalIDs]=this.verifySignals(currentID(:));
                    if~addSignalsSuccessFlag

                        successFlag=false;
                        break;
                    end
                    allCheckableSignalIDs=[allCheckableSignalIDs;currentLeafSignalIDs];%#ok<AGROW>
                end
            end
            this.MemberNames=[];

            previousLabelDefinitionIDs=this.Model.getAllLabelDefinitionIDs();

            for idx=1:length(memberIDs)
                this.Model.makeAllMemberColorsInOrderWhileImport(memberIDs(idx));
                if(signalColoringType=="sameColors")
                    this.Model.makeSignalColorsSameAsGivenParent(memberIDs(idx));
                elseif(signalColoringType=="sameColoringAcrossMembers")
                    this.Model.makeSignalColorsSameAcrossMember(memberIDs(idx));
                else
                    this.Model.makeSignalColorsDifferentFromGivenParent(memberIDs(idx));
                end



                if(this.Engine.getSignalTmMode(memberIDs(idx))=="file"&&ismember(memberIDs(idx),lssMemberIDs))
                    this.Model.addToMemberIDcolorRuleMap(memberIDs(idx),signalColoringType);
                end
            end

            if addSignalsSuccessFlag
                [addSignalsSuccessFlag,isShowIncompatibleLabelWarning]=this.Model.addImportedSignalsAndLabelsToRepository(nonLSSMemberIDs,lss,lssMemberIDs);
            end

            if addSignalsSuccessFlag


                this.Model.addMemberIDs(memberIDs);
                this.Model.addAllCheckableSignalIDs(allCheckableSignalIDs);
                labelDefTreeOutData=this.Model.getAllLabelDefinitionsDataForTree(previousLabelDefinitionIDs);


                [signalDataForAutoLabelDialog,bNeedToFetchMoreData]=this.Model.getSignalDataForAutoLabelDialog(memberIDs);
                if isempty(signalDataForAutoLabelDialog)||~bNeedToFetchMoreData
                    this.notify('SignalDataForAutoLabelDialog',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'data',signalDataForAutoLabelDialog,...
                    'messageID','signalDataComplete')));
                else
                    this.notify('SignalDataForAutoLabelDialog',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'data',signalDataForAutoLabelDialog,...
                    'messageID','signalData')));
                end
            end


            if~addSignalsSuccessFlag&&numberOfInputIDs~=0
                successFlag=false;
                return;
            end

            if addSignalsSuccessFlag


                this.notify('ImportSignalComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'data',memberIDs)));


                this.notify('ImportLabelDefsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'data',labelDefTreeOutData,'messageID','treeLabelDefData')));
            end
        end

        function success=cb_GetChildren(this,args)
            isLazyLoadingChildernSignal=false;
            if isfield(args.data,'isLazyLoadingChildernSignal')&&args.data.isLazyLoadingChildernSignal
                isLazyLoadingChildernSignal=args.data.isLazyLoadingChildernSignal;
            end
            if isLazyLoadingChildernSignal
                this.notify('LazyLoadImportSignalComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                'isPlotSignalAfterLazyLoadComplete',this.Model.isPlotSignalAfterLazyLoadComplete(),...
                'data',args.data)));
                this.Model.setPlotSignalAfterLazyLoadComplete(false);
                success=true;
                return;
            end
            this.Dispatcher.publishToClient(args.clientID,...
            'appViewController','hideSpinner',[]);
            success=true;
        end

        function success=cb_GetChildrenDataForAutoLabelDialog(this,args)
            parentIDs=args.data.parentIDs;


            [signalDataForAutoLabelDialog]=this.Model.getSignalLeafChildrenDataForAutoLabelDialog(parentIDs);
            this.notify('SignalDataForAutoLabelDialog',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',signalDataForAutoLabelDialog,...
            'messageID','signalDataComplete')));
            success=true;
        end

        function cb_ImportLabelDefinitions(this,args)
            matFile_FileName=args.data.matFile_FileName;
            srcWidget=args.data.srcWidget;

            try
                m=load(string(matFile_FileName));
            catch ME


                this.Dispatcher.publishToClient(args.clientID,...
                srcWidget,'importLabelDefinitionsFromFileError',...
                struct('errorMsg',ME.message));
                return;
            end



            vals=struct2cell(m);
            lblDefIdx=cellfun(@(x)isa(x,'signalLabelDefinition'),vals);
            vals=vals(lblDefIdx);
            lblDefs=vertcat(vals{:});

            if~isempty(lblDefs)


                [isValid,errorID,uniqueLblDefs]=this.Model.validateCompatibleLabelDefinitionsForMerge(lblDefs);
                if~isValid

                    this.Dispatcher.publishToClient(args.clientID,...
                    srcWidget,'importLabelDefinitionsFromFileError',...
                    struct('errorID',errorID));
                    return;
                end
                if numel(uniqueLblDefs)>0

                    controller=signal.labeler.controllers.LabelDefinitionController.getController();




                    for idx=1:numel(uniqueLblDefs)
                        label=uniqueLblDefs(idx);



                        args.data.labelData=getCreateLabelDefinitionStruct(this,label);


                        info=controller.cb_CreateLabelDef(args);



                        if~isempty(label.Sublabels)
                            for sidx=1:numel(label.Sublabels)
                                sublabel=label.Sublabels(sidx);
                                args.data.labelData=getCreateLabelDefinitionStruct(this,sublabel);
                                args.data.labelData.ParentLabelDefinitionID=info.newLabelDefIDs;
                                controller.cb_CreateLabelDef(args);
                            end
                        end
                    end


                    dirtyStateChanged=this.Model.setDirty(true);
                    if dirtyStateChanged
                        this.changeAppTitle(this.Model.isDirty());
                        this.notify('DirtyStateChanged',...
                        signal.internal.SAEventData(struct('clientID',str2double(args.clientID))));
                    end
                end
                this.Dispatcher.publishToClient(args.clientID,...
                srcWidget,'closeDialog',[]);
            else


                this.Dispatcher.publishToClient(args.clientID,...
                srcWidget,'importLabelDefinitionsFromFileError',struct('errorID','NoLabelDefinitions'));
            end
        end
    end

    methods(Access=protected)
        function[successFlag,allLeafIDs,exceptionKeyword]=verifySignals(this,memberIDs)

            successFlag=true;
            exceptionKeyword='';
            allLeafIDs=[];
            for idx=1:numel(memberIDs)
                currentMemberID=memberIDs(idx);
                leafIDs=this.Model.getAllSignalLeafChildrenIDs(currentMemberID);


                this.Model.setLeafSignalIDsForMemberID(currentMemberID,leafIDs);
                tmMode=this.Engine.getSignalTmMode(currentMemberID);
                if~strcmp(tmMode,"file")


                    if isempty(leafIDs)
                        leafIDs=currentMemberID;
                    end
                    currentName=this.Engine.getSignalName(currentMemberID);
                    this.MemberNames=[this.MemberNames,{Simulink.sdi.internal.signalanalyzer.Utilities.convertToValidMemberName(currentName)}];
                end
                for leaf_idx=1:length(leafIDs)
                    tmMode=this.Engine.getSignalTmMode(leafIDs(leaf_idx));
                    if strcmp(tmMode,'inherentLabeledSignalSet')
                        tmMode=signal.sigappsshared.SignalUtilities.getTmModeLabeledSignalSet(this.Engine,leafIDs(leaf_idx));
                    end
                    if isempty(this.Model.getIsTimeSpecified())
                        this.Model.setIsTimeSpecified(~strcmp(tmMode,'samples'));
                    elseif~isequal(this.Model.getIsTimeSpecified(),~strcmp(tmMode,'samples'))
                        successFlag=false;
                        exceptionKeyword='ImportMixedTimeSignalsWarning';
                        return;
                    end
                end
                allLeafIDs=[allLeafIDs;leafIDs];%#ok<AGROW>
            end


            if length(unique(this.MemberNames))~=length(this.MemberNames)
                successFlag=false;
                exceptionKeyword='NonUniqueMemberNames';
                return;
            end

            if~isempty(this.MemberNames)
                currentMemberIDs=this.Model.getMemberIDs();
                currentMemberNames=strings(numel(currentMemberIDs),1);
                for idx=1:numel(currentMemberIDs)
                    currentMemberNames(idx)=this.Engine.getSignalName(currentMemberIDs(idx));
                end
                if any(ismember(this.MemberNames,currentMemberNames))
                    successFlag=false;
                    exceptionKeyword='NonUniqueMemberNames';
                    return;
                end
            end
        end

        function data=getCreateLabelDefinitionStruct(~,lblDef)






            data.ParentLabelDefinitionID='';
            data.LabelName=char(lblDef.Name);
            labelType=lblDef.LabelType;
            data.featureExtractorType="";
            framePolicy=lblDef.getFramePolicy();
            if labelType=="attributeFeature"
                data.isFeature=true;
            elseif labelType=="roiFeature"
                data.isFeature=true;
                if isfield(framePolicy,'FrameOverlapLength')
                    data.framePolicyType='frameOverlapLength';
                    data.frameRateOrOverlapLength=framePolicy.FrameOverlapLength;
                else
                    data.framePolicyType='framerate';
                    data.frameRateOrOverlapLength=framePolicy.FrameRate;
                end
                data.frameSize=framePolicy.FrameSize;
            end
            data.LabelType=char(lblDef.getSimpleLabelType());
            data.LabelDescription=char(lblDef.Description);
            data.LabelDataType=char(lblDef.LabelDataType);
            if data.LabelDataType=="categorical"
                data.LabelDataCategories=lblDef.Categories;
            else
                data.LabelDataCategories='';
            end
            if data.LabelDataType=="numeric"||isempty(lblDef.DefaultValue)

                data.LabelDataDefaultValue=sprintf("%.20g",lblDef.DefaultValue);
            else
                data.LabelDataDefaultValue=string(lblDef.DefaultValue);
            end
        end

        function flag=isImportTreeTableDataComplete(~,data)


            flag=~any([data.hasChildren]);
        end
    end

    methods
        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end
    end
end
