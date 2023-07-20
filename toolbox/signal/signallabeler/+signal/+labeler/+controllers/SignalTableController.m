

classdef SignalTableController<handle





    properties(Hidden)
        Model;
        TableDataProvider;
        MdomDataModel;
    end

    properties(Access=protected)
        Dispatcher;
    end

    properties(Constant)
        ControllerID='SignalTableCtrl';
    end

    events
MemberSignalDeleteComplete
ClearAllMembersComplete
DirtyStateChanged
CheckOrUncheckSignalsComplete
CheckOrUncheckLabelInstancesComplete
ContextMenuDataComplete
ScrollToComplete
    end


    methods(Static)
        function ret=getController()

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)
                dispatcherObj=Simulink.sdi.internal.controllers.SDIDispatcher.getDispatcher();
                modelObj=signal.labeler.models.LabelDataRepository.getModel();
                ctrlObj=signal.labeler.controllers.SignalTableController(dispatcherObj,modelObj);
            end

            ret=ctrlObj;
        end
    end



    methods(Access=protected)

        function this=SignalTableController(dispatcherObj,modelObj)

            this.Dispatcher=dispatcherObj;
            this.Model=modelObj;
            import signal.labeler.controllers.SignalTableController;

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','membersignaldelete'],...
            @(arg)cb_MemberSignalDelete(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','clearallmembers'],...
            @(arg)cb_ClearAllMembers(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','checkorunchecksignals'],...
            @(arg)cb_CheckOrUncheckSignals(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','checkorunchecklabelinstances'],...
            @(arg)cb_CheckOrUncheckLabelInstances(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','signalsmovedorcleared'],...
            @(arg)cb_SignalsMovedOrCleared(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','getcontextmenudata'],...
            @(arg)cb_GetContextMenuData(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','scrolltoid'],...
            @(arg)cb_ScrollToID(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','signalcolorchange'],...
            @(arg)cb_SignalColorChange(this,arg));

            this.Dispatcher.subscribe(...
            [SignalTableController.ControllerID,'/','signalcoloringtypechange'],...
            @(arg)cb_SignalColoringTypeChange(this,arg));

        end

    end

    methods(Hidden)



        function lazyLoadingDataCompleteAfterCheck(this,clientID,parentIDs)
            parentIDs=cellfun(@str2double,parentIDs);
            memberIDs=unique(this.Model.getMemberIDForSignalID(parentIDs),'stable');
            for idx=1:numel(memberIDs)
                args.clientID=clientID;
                args.data.rowID=str2double(memberIDs(idx));
                args.data.memberID=str2double(memberIDs(idx));
                args.data.eventType='checkAll';
                cb_CheckOrUncheckSignals(this,args);
            end
        end

        function handleMemberSignalsChanged(this,clientID)
            memberIDs=this.Model.getMemberIDs();
            numMemberIDs=numel(memberIDs);
            updateIDs=cell(1,numMemberIDs);
            for memIdx=1:numMemberIDs
                updateIDs{memIdx}=num2str(memberIDs(memIdx));
            end
            if nargin==2
                this.TableDataProvider.AppClientID=clientID;
            end
            this.MdomDataModel.rowChanged('',numel(this.Model.getMemberIDs()),updateIDs);
        end

        function refreshTreeTableData(this)
            this.MdomDataModel.refreshView();
        end

        function handleTreeTableRowChanged(this,data,srcAction)
            switch(srcAction)
            case "delete"
                if isfield(data,'rowIDs')&&isfield(data,'parentRowIDs')
                    this.MdomDataModel.removeRowsByIDUnderParent(data.rowIDs,data.parentRowIDs);
                end
            end
        end

        function modelID=getSignalTreeTableMdomDataModelID(this)
            modelID=this.MdomDataModel.getID();
        end

        function setupSignalTreeTablePaging(this,tableDataProviderObj,MdomDataModelObj)
            if~isempty(this.MdomDataModel)
                delete(this.MdomDataModel);
                delete(this.TableDataProvider);
            end


            if nargin>1

                this.TableDataProvider=tableDataProviderObj;
                this.MdomDataModel=MdomDataModelObj;
            else
                this.TableDataProvider=signal.labeler.models.SignalTreeTableDataProvider;
                this.TableDataProvider.FlatData=false;
                this.TableDataProvider.Model=this.Model;
                this.MdomDataModel=mdom.DataModel(this.TableDataProvider);
            end
            this.MdomDataModel.columnChanged(6,{});
            addlistener(this.TableDataProvider,'CheckboxEdit',@(src,evt)this.cb_CheckboxEdit(src,evt));
        end



        function cb_CheckboxEdit(this,~,args)
            data=args.Data.data;
            isChecked=data.checked;
            cbArgs.clientID=args.Data.clientID;
            this.notify('CheckOrUncheckLabelInstancesComplete',signal.internal.SAEventData(struct('clientID',cbArgs.clientID,...
            'messageID','removeSelectionOnCheckUncheck')));
            if data.rowDataType=="signal"
                cbArgs.data.rowID=str2double(data.rowID);
                cbArgs.data.memberID=str2double(this.Model.getMemberIDForSignalID(cbArgs.data.rowID));
                cbArgs.data.eventType="";
                if data.parentID==""&&isChecked
                    cbArgs.data.eventType="checkAll";
                elseif data.parentID==""&&~isChecked
                    cbArgs.data.eventType="uncheckAll";
                elseif isChecked
                    cbArgs.data.eventType="check";
                else
                    cbArgs.data.eventType="uncheck";
                end
                cb_CheckOrUncheckSignals(this,cbArgs);
            else
                cbArgs.data.rowID=string(data.rowID);
                cbArgs.data.parentLabelInstanceID="";
                if data.rowDataType=="labelInstance"
                    labelInstance=this.Model.getLabelInstanceFromLabelInstanceID(data.rowID);
                    cbArgs.data.parentLabelInstanceID=string(labelInstance.parentLabelInstanceID);
                end
                cbArgs.data.eventType="uncheckLabelInstance";
                if isChecked
                    cbArgs.data.eventType="checkLabelInstance";
                end
                cb_CheckOrUncheckLabelInstances(this,cbArgs);
            end
        end

        function cb_GetContextMenuData(this,args)
            if~isfield(args.data,"rowID")


                return;
            end
            mf0TreeTableRowData=this.Model.getMf0TreeTableRowByID(args.data.rowID);
            contextMenuData=args.data;
            contextMenuData.rowDataType=mf0TreeTableRowData.rowDataType;
            switch mf0TreeTableRowData.rowDataType
            case "signal"
                contextMenuData.isMemberSignal=mf0TreeTableRowData.parentID=="";
                isSignalHeader=true;
                memberID=mf0TreeTableRowData.rowID;
                if~contextMenuData.isMemberSignal
                    rowID=str2double(mf0TreeTableRowData.rowID);
                    if mf0TreeTableRowData.isExpanded


                        isSignalHeader=mf0TreeTableRowData.childrenRows.Size~=0;
                    else



                        childrenIDs=this.Model.getSignalChildrenIDs(rowID);
                        isSignalHeader=numel(childrenIDs)~=0;
                    end
                    memberID=this.Model.getMemberIDForSignalID(rowID);
                end
                contextMenuData.memberID=memberID;
                contextMenuData.isSignalHeader=isSignalHeader;
            case "attributeLabelInstance"
                mf0TreeTableParentRowData=this.Model.getMf0TreeTableRowByID(mf0TreeTableRowData.parentID);
                attLabelInstance=this.Model.getLabelInstanceFromLabelInstanceID(mf0TreeTableRowData.rowID);
                mf0TreeTableMemberSignalRowData=this.Model.getMf0TreeTableRowByID(attLabelInstance.memberID);
                contextMenuData.parentRowDataType=mf0TreeTableParentRowData.rowDataType;
                contextMenuData.isMemberSignalChecked=mf0TreeTableMemberSignalRowData.isChecked;
                contextMenuData.ParentLabelInstanceID=attLabelInstance.parentLabelInstanceID;
                contextMenuData.memberID=attLabelInstance.memberID;
                contextMenuData.isChecked=mf0TreeTableMemberSignalRowData.isChecked;
            case "labelInstance"
                lblInstance=this.Model.getLabelInstanceFromLabelInstanceID(mf0TreeTableRowData.rowID);
                mf0TreeTableMemberSignalRowData=this.Model.getMf0TreeTableRowByID(lblInstance.memberID);
                contextMenuData.isMemberSignalChecked=mf0TreeTableMemberSignalRowData.isChecked;
                contextMenuData.ParentLabelInstanceID=lblInstance.parentLabelInstanceID;
                contextMenuData.memberID=lblInstance.memberID;
                contextMenuData.isChecked=mf0TreeTableRowData.isChecked;
            case "labelHeader"
                mf0TreeTableParentRowData=this.Model.getMf0TreeTableRowByID(mf0TreeTableRowData.parentID);
                contextMenuData.ParentLabelInstanceID="";
                if mf0TreeTableParentRowData.rowDataType~="signal"
                    contextMenuData.ParentLabelInstanceID=mf0TreeTableRowData.parentID;
                end
            end
            this.notify('ContextMenuDataComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',struct('data',contextMenuData))));
        end

        function cb_ScrollToID(this,args)
            labelInstanceID=args.data.id;
            globalIndex=this.MdomDataModel.globalIndexFromID(labelInstanceID);
            if globalIndex==-1

                rowHierarchyInfo=this.Model.getRowHierarchyForLabelInstanceID(labelInstanceID);



                this.TableDataProvider.handleExpandWhenScrolling(rowHierarchyInfo.memberID,rowHierarchyInfo.memberChildrenIDs);
                if rowHierarchyInfo.isSublabel
                    this.TableDataProvider.handleExpandWhenScrolling(rowHierarchyInfo.parentLabelDefHeaderID,rowHierarchyInfo.parentLblDefHeaderChildrenIDs);
                    if~rowHierarchyInfo.isParentLabelDefAttribute
                        this.TableDataProvider.handleExpandWhenScrolling(rowHierarchyInfo.parentLabelInstanceID,rowHierarchyInfo.parentLblInstChildrenIDs);
                    end
                end
                this.TableDataProvider.handleExpandWhenScrolling(rowHierarchyInfo.labelDefHeaderID,rowHierarchyInfo.labelDefHeaderChildrenIDs);
            end


            globalIndex=this.MdomDataModel.globalIndexFromID(labelInstanceID);
            this.notify('ScrollToComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'data',struct('globalIndex',globalIndex))));
        end

        function cb_MemberSignalDelete(this,args)




            checkedSignalIDsInMember=this.Model.deleteMemberSignalFromModel(args.data.memberID);

            this.handleTreeTableRowChanged(struct('rowIDs',string(args.data.memberID),...
            'parentRowIDs',""),'delete');

            this.notify('MemberSignalDeleteComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','treeTableData','data',struct('checkedSignalIDsInMember',checkedSignalIDsInMember,...
            'numOfMemberSignalInApp',numel(this.Model.getMemberIDs())))));


            this.notify('MemberSignalDeleteComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','labelSignalsWidgetData','data',struct('id',string(args.data.memberID)))));


            this.notify('MemberSignalDeleteComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','SignalDataForAutoLabelDialog','data',struct('id',string(args.data.memberID)))));


            this.notify('MemberSignalDeleteComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','updateMultipleSignalsInPlot','data',checkedSignalIDsInMember)));

            if~this.Model.isAppHasMembers()

                this.Model.resetSettingOnNoMemberSignals();
            end



            if this.Model.isAppHasMemberOrLabelsDef()
                this.onDirtyStateChange(args.clientID,true);
            else
                this.onDirtyStateChange(args.clientID,false);
            end
            this.handleMemberSignalsChanged();
        end

        function cb_ClearAllMembers(this,args)




            this.Model.deleteAllMembersFromModel();


            this.notify('ClearAllMembersComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','clearPlot')));

            this.Model.resetSettingOnNoMemberSignals();




            if this.Model.isAppHasLabelsDef()
                this.onDirtyStateChange(args.clientID,true);
            else
                this.onDirtyStateChange(args.clientID,false);
            end
        end

        function cb_CheckOrUncheckSignals(this,args)


            eventType=args.data.eventType;
            clientID=args.clientID;
            labelInstanceIDs=[];
            axesLabelData=[];
            [signalIDs,memberID,signalChildHeaderIDs,checkStatus]=this.getIDsForCheckOrUncheckSignals(args);
            if~isempty(signalIDs)


                this.Model.updatedCheckedSignalIDs(signalIDs,checkStatus);
                if checkStatus=="check"
                    signalsPlotData=this.Model.getSignalsData(signalIDs,checkStatus);

                    this.notify('CheckOrUncheckSignalsComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                    'messageID','plotMultipleSignalsInDisplay','data',signalsPlotData)));
                    axesLabelData=this.Model.getLabelDataForAxesBySignalIDOnSignalCheck(signalIDs);
                    memberID=[memberID;signalChildHeaderIDs];
                else




                    this.notify('CheckOrUncheckSignalsComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                    'messageID','clearMultipleSignalsInDisplay','data',signalIDs)));
                    if~this.Model.isAnySignalInMemberChecked(memberID)



                        labelInstanceIDs=this.Model.getLabelInstaceIDsForMemberID(string(memberID));
                        memberID=[memberID;signalChildHeaderIDs];
                    elseif~isempty(signalChildHeaderIDs)



                        memberID=signalChildHeaderIDs;
                    else
                        memberID=[];
                    end
                end
            elseif eventType=="checkAllInMember"
                allSignalIDs=this.Model.getLeafSignalIDsForMemberID(memberID);
                if isempty(allSignalIDs)
                    allSignalIDs=memberID;
                end
                axesLabelData=this.Model.getLabelDataForAxesBySignalIDOnSignalCheck(allSignalIDs);
            end

            if checkStatus=="check"
                for idx=1:numel(axesLabelData)
                    dataPacket.clientID=clientID;
                    dataPacket.signalID=axesLabelData(idx).SignalID;
                    dataPacket.totalChuncks=1;
                    if eventType~="checkAllInMember"
                        axesLabelData(idx).isVisible=false;%#ok<AGROW>
                        messageID='labelViewerAxesLabelData';
                    elseif eventType=="checkAllInMember"
                        axesLabelData(idx).isVisible=true;%#ok<AGROW>
                        messageID='axesLabelData';
                        labelInstanceIDs=[labelInstanceIDs;axesLabelData(idx).LabelInstanceIDs];%#ok<AGROW>
                    end
                    dataPacket.labelData=axesLabelData(idx);
                    this.notify('CheckOrUncheckSignalsComplete',signal.internal.SAEventData(struct('clientID',clientID,...
                    'messageID',messageID,'data',dataPacket)));
                end
            end
            this.Model.updateTreeTableRowMetaDataByID(string([signalIDs(:);memberID;signalChildHeaderIDs(:)]),labelInstanceIDs,checkStatus=="check");

            this.refreshTreeTableData();


            this.notify('CheckOrUncheckSignalsComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','signalTreeTableData','data',...
            struct('memberID',memberID,'signalIDs',signalIDs,'labelInstanceIDs',...
            labelInstanceIDs,'checkStatus',checkStatus))));
        end

        function cb_CheckOrUncheckLabelInstances(this,args)

            [memberID,labelDefID]=this.Model.getMemberAndLabelDefIDFromLabelInstanceID(args.data.rowID);
            labelInstanceIDs=[];
            eventType=args.data.eventType;
            [includeSublabels,isVisibleFlag,checkStatus]=this.getFlagsForCheckOrUncheckLabelHeader(eventType);
            if this.Model.isAnySignalInMemberChecked(memberID)

                if ismember(eventType,["checkLabelInstance","uncheckLabelInstance"])
                    labelInstanceIDs=args.data.rowID;
                    labelData.LabelInstanceIDs=labelInstanceIDs;
                    labelData.ParentLabelInstanceIDs=args.data.parentLabelInstanceID;

                    axesLabelData=this.Model.getLabelDataForAxesOnLabelCheck(labelData,isVisibleFlag);
                else
                    axesLabelData=this.Model.getLabelDataForAxesBySignalIDOnSignalCheck(memberID,labelDefID,includeSublabels);
                end
                for idx=1:numel(axesLabelData)
                    axesLabelData(idx).isVisible=isVisibleFlag;
                    data.clientID=args.clientID;
                    data.signalID=axesLabelData(idx).SignalID;
                    data.totalChuncks=1;
                    data.labelData=axesLabelData(idx);
                    this.notify('CheckOrUncheckLabelInstancesComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
                    'messageID','labelTimeAxesLabelData','data',data)));
                    labelInstanceIDs=unique([labelInstanceIDs;axesLabelData(idx).LabelInstanceIDs]);

                end
            elseif eventType=="checkLabelInstance"
                labelInstanceIDs=args.data.rowID;
                checkStatus="uncheck";
            end
            this.Model.updateTreeTableRowMetaDataByID(string.empty,labelInstanceIDs,checkStatus=="check");

            this.refreshTreeTableData();
            this.notify('CheckOrUncheckLabelInstancesComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','signalTreeTableData','data',...
            struct('labelInstanceIDs',labelInstanceIDs,'checkStatus',checkStatus))));
        end

        function cb_SignalsMovedOrCleared(this,args)













            signalIDs=[];
            memberIDs=[];
            labelInstanceIDs=[];
            checkStatus="uncheck";
            signalData.data.eventType=checkStatus;
            if this.Model.isAppHasMembers()
                signalIDs=args.data.signalID;


                this.Model.updatedCheckedSignalIDs(signalIDs,checkStatus);
                for idx=1:numel(signalIDs)
                    signalData.data.rowID=signalIDs(idx);
                    signalData.data.memberID=str2double(this.Model.getMemberIDForSignalID(signalIDs(idx)));
                    signalData.clientID=args.clientID;
                    [~,memberID,signalChildHeaderIDs,~]=this.getIDsForCheckOrUncheckSignals(signalData);
                    if~this.Model.isAnySignalInMemberChecked(memberID)



                        labelInstanceIDs=unique([labelInstanceIDs;this.Model.getLabelInstaceIDsForMemberID(string(memberID))],'stable');
                        memberIDs=[memberIDs;memberID;signalChildHeaderIDs];%#ok<AGROW>
                    elseif~isempty(signalChildHeaderIDs)



                        memberIDs=[memberIDs;signalChildHeaderIDs];%#ok<AGROW>
                    end
                end
                memberIDs=unique(memberIDs);
                this.Model.updateTreeTableRowMetaDataByID(string([signalIDs;memberIDs]),labelInstanceIDs,false);


                this.refreshTreeTableData();
            end
            this.notify('CheckOrUncheckSignalsComplete',signal.internal.SAEventData(struct('clientID',args.clientID,...
            'messageID','signalTreeTableData','data',...
            struct('memberID',memberIDs,'signalIDs',signalIDs,'labelInstanceIDs',...
            labelInstanceIDs,'checkStatus',checkStatus))));
        end

        function cb_SignalColorChange(this,args)
            colorToChange=args.data.color;
            cellID=str2double(args.data.cellid);
            type=args.data.type;
            if(type=="changeOnlyCurrentRowColor"||type=="changeAllMemberColorsSame")

                [r,g,b]=this.hex2rgb(colorToChange);
                changedSignalIDs=this.changeColor(cellID,[r,g,b],type);
            end
            this.refreshSignals(changedSignalIDs,args.clientID);
        end

        function cb_SignalColoringTypeChange(this,args)
            signalColoringType=args.data.SignalColoringType;
            if(signalColoringType=="sameColoring")
                this.Model.makeAllSignalColorsSameAsTheirParents();
            elseif(signalColoringType=="differentColoring")
                this.Model.makeAllSignalColorsDifferentFromTheirParents();
            elseif(signalColoringType=="sameColoringAcrossMembers")
                this.Model.makeAllSignalColorsSameAcrossMembers();

            elseif(signalColoringType=="changeAllSignalColorsToMemberColor")
                cellID=str2double(args.data.cellid);
                this.Model.makeSignalColorsSameAsGivenParent(cellID);
            elseif(signalColoringType=="changeAllSignalColorsToDifferentColor")
                cellID=str2double(args.data.cellid);
                this.Model.makeSignalColorsDifferentFromGivenParent(cellID);
            end

            if(signalColoringType=="differentColoring"||signalColoringType=="sameColoring"||signalColoringType=="sameColoringAcrossMembers")
                memberIDs=this.Model.getMemberIDs();
                if(~isempty(this.Model.getMemberIDcolorRuleMap()))
                    for idx=1:length(memberIDs)
                        if(this.Model.isExistInMemberIDcolorRuleMap(memberIDs(idx)))
                            this.Model.addToMemberIDcolorRuleMap(memberIDs(idx),signalColoringType);
                        end
                    end
                end
                this.refreshAllSignals(args.clientID);
            elseif(signalColoringType=="changeAllSignalColorsToDifferentColor"||signalColoringType=="changeAllSignalColorsToMemberColor")
                cellID=str2double(args.data.cellid);
                if(this.Model.isExistInMemberIDcolorRuleMap(cellID))
                    this.Model.addToMemberIDcolorRuleMap(cellID,signalColoringType);
                end
                changedSignalIDs=[];
                changedSignalIDs(end+1)=cellID;
                childSignalIDs=this.Model.getAllSignalChildrenIDs(cellID);
                changedSignalIDs=cat(2,changedSignalIDs,childSignalIDs.');
                this.refreshSignals(changedSignalIDs,args.clientID);
            end

        end
    end


    methods

        function changedSignalIDs=changeColor(this,cellID,rgb,type)
            changedSignalIDs=[];
            changedSignalIDs(end+1)=cellID;
            this.Model.Engine.setSignalLineColor(cellID,rgb);
            if(type=="changeOnlyCurrentRowColor")
                if(this.Model.isHasChildrenSignal(cellID))
                    changedSignalIDs=this.Model.getCheckedSignalIDsInMember(cellID);
                end
                return
            end
            this.Model.makeSignalColorsSameAsGivenParent(cellID);
            childSignalIDs=this.Model.getAllSignalChildrenIDs(cellID);
            changedSignalIDs=cat(2,changedSignalIDs,childSignalIDs.');
        end

        function refreshSignals(this,changedSignalIDs,clientID)
            checkedSignalIDs=this.Model.getCheckedSignalIDs();
            checkedSignals=zeros(1,length(checkedSignalIDs));
            unCheckedSignals=zeros(1,length(checkedSignalIDs));
            for idx=1:length(changedSignalIDs)
                if(~this.Model.isHasChildrenSignal(changedSignalIDs(idx)))
                    if(ismember(changedSignalIDs(idx),checkedSignalIDs))
                        checkedSignals(idx)=changedSignalIDs(idx);
                    else
                        unCheckedSignals(idx)=changedSignalIDs(idx);
                    end
                end
            end
            checkedSignals=nonzeros(checkedSignals);
            unCheckedSignals=nonzeros(unCheckedSignals);
            checkedSignalsPlotData=this.Model.getSignalsData(checkedSignals,"check");
            uncheckedSignalsPlotData=this.Model.getSignalsData(unCheckedSignals,"uncheck");
            signalsPlotData=cat(1,checkedSignalsPlotData,uncheckedSignalsPlotData);

            this.notify('CheckOrUncheckSignalsComplete',signal.internal.SAEventData(struct('clientID',clientID,...
            'messageID','signalColorChange','data',signalsPlotData)));
            this.refreshTreeTableData();
        end

        function refreshMemberSignalsByIDs(this,changedMemberSignalIDs,clientID)
            for idx=1:length(changedMemberSignalIDs)
                changedSignalIDs=this.Model.getAllSignalLeafChildrenIDs(changedMemberSignalIDs(idx));
                this.refreshSignals(changedSignalIDs,clientID);
            end
        end

        function refreshAllSignals(this,clientID)
            MemberIDs=this.Model.getMemberIDs();
            for idx=1:length(MemberIDs)
                this.refreshSignals(this.Model.getAllSignalLeafChildrenIDs(MemberIDs(idx)),clientID);
            end
        end

        function[redcolor,greencolor,bluecolor]=hex2rgb(~,colorToChange)
            redcolor=hex2dec(colorToChange(2:3))/255;
            greencolor=hex2dec(colorToChange(4:5))/255;
            bluecolor=hex2dec(colorToChange(6:7))/255;
        end

        function onDirtyStateChange(this,clientID,dirtyState)
            dirtyStateChanged=this.Model.setDirty(dirtyState);
            if dirtyStateChanged
                this.changeAppTitle(this.Model.isDirty());
                this.notify('DirtyStateChanged',...
                signal.internal.SAEventData(struct('clientID',str2double(clientID))));
            end
        end

        function changeAppTitle(~,dirtyState)
            signal.labeler.Instance.gui().updateAppTitle(dirtyState);
        end

        function[signalIDs,memberID,signalChildHeaderIDs,checkStatus]=getIDsForCheckOrUncheckSignals(this,args)









            eventType=args.data.eventType;

            if ismember(eventType,["check","checkAll","checkAllInMember"])
                checkStatus="check";
            else
                checkStatus="uncheck";
            end

            rowID=args.data.rowID;
            memberID=args.data.memberID;
            signalIDs=[];
            signalChildHeaderIDs=[];
            if eventType=="uncheckAll"&&~this.Model.isAnySignalInMemberChecked(memberID)

                memberID=[];
                return;
            end
            leafSignalIDs=this.Model.getLeafSignalIDsForMemberID(memberID);
            isComplex=false;
            if~isempty(leafSignalIDs)
                isComplex=this.Model.isSignalHasComplexData(leafSignalIDs(1));
            end
            if checkStatus=="check"


                if rowID==memberID

                    info=this.Model.getMemberIDsRequiringLazyLoad(memberID);
                    hImportFromFile=signal.labeler.controllers.ImportSignalsFromFile.getController();
                    if~isempty(info.memberIDsForLazyLoad)
                        lazyLoadInfo=hImportFromFile.lazyLoadFileData(args.clientID,info.memberIDsForLazyLoad,'check');
                        if~lazyLoadInfo.success


                            signalIDs=[];
                            signalChildHeaderIDs=[];
                            checkStatus='uncheck';
                        end
                        return;
                    end
                end
                if isempty(leafSignalIDs)||all(leafSignalIDs==memberID)

                    signalChildHeaderIDs=[];
                    signalIDs=memberID;
                    return;
                else
                    childrenIDs=this.Model.getAllSignalChildrenIDs(rowID);
                    parentIDs=this.Model.getAllSignalParentIDs(rowID);
                    signalChildHeaderIDs=setdiff([rowID;parentIDs;childrenIDs],[memberID;leafSignalIDs],'stable');
                    if isComplex
                        numSignalChildHeaderIDs=numel(signalChildHeaderIDs);
                        hidderRowIDsIdx=true(1,numSignalChildHeaderIDs);
                        for sdx=1:numSignalChildHeaderIDs
                            hidderRowIDsIdx(sdx)=~this.isHiddenRowOfComplexSignal(signalChildHeaderIDs(sdx),true,leafSignalIDs);
                        end

                    end
                end
                if isempty(childrenIDs)

                    signalIDs=rowID;
                else
                    signalIDs=setdiff(childrenIDs,[signalChildHeaderIDs;this.Model.getCheckedSignalIDsInMember(memberID)],'stable');
                end
                if isComplex


                    signalChildHeaderIDs=signalChildHeaderIDs(hidderRowIDsIdx);
                end
            else
                if isempty(leafSignalIDs)||all(leafSignalIDs==memberID)

                    signalChildHeaderIDs=[];
                    signalIDs=memberID;
                    return;
                else
                    signalIDs=[];
                    signalChildHeaderIDs=[];
                    childrenIDs=this.Model.getAllSignalChildrenIDs(rowID);
                    parentIDs=this.Model.getAllSignalParentIDs(rowID);
                    if isempty(childrenIDs)



                        signalIDs=rowID;
                        this.Model.updatedCheckedSignalIDs(signalIDs,checkStatus);
                        signalChildHeaderIDs=[];
                    elseif rowID~=memberID

                        signalChildHeaderIDs=rowID;


                        signalIDs=this.Model.getAllSignalChildrenIDs(signalChildHeaderIDs);
                        this.Model.updatedCheckedSignalIDs(signalIDs,checkStatus);
                    end
                    parentIDsToBeChecked=setdiff(parentIDs,[memberID;signalChildHeaderIDs],'stable');
                    isHiddenRowOfComplexSignal=false;
                    for idx=1:numel(parentIDsToBeChecked)


                        if isComplex
                            isHiddenRowOfComplexSignal=this.isHiddenRowOfComplexSignal(parentIDsToBeChecked(idx),false,leafSignalIDs);
                        end

                        if~isHiddenRowOfComplexSignal&&~this.Model.isAnySignalInChildHeaderChecked(parentIDsToBeChecked(idx),memberID)
                            signalChildHeaderIDs=[signalChildHeaderIDs;parentIDsToBeChecked(idx)];%#ok<AGROW>
                        end
                    end
                    if~isempty(childrenIDs)
                        signalIDs=[signalIDs;setdiff(childrenIDs,[signalChildHeaderIDs;this.Model.getUncheckedSignalIDsInMember(memberID)],'stable')];
                        if isComplex
                            validSignalIDs=[];
                            for sdx=1:numel(signalIDs)

                                if~this.isHiddenRowOfComplexSignal(signalIDs(sdx),true,leafSignalIDs)
                                    validSignalIDs=[validSignalIDs,signalIDs(sdx)];%#ok<AGROW>
                                end
                            end
                            signalIDs=validSignalIDs;
                        end
                    end
                end
            end
        end

        function isHiddenRowOfComplexSignal=isHiddenRowOfComplexSignal(this,sigID,isCheckForImagSig,leafSignalIDs)
            isHiddenRowOfComplexSignal=false;
            if isCheckForImagSig
                [~,isImagPart]=this.Model.isSignalHasComplexData(sigID);
                if isImagPart


                    isHiddenRowOfComplexSignal=true;
                    return
                end
            end
            if nargin==4
                if any(sigID==leafSignalIDs)

                    isHiddenRowOfComplexSignal=false;
                    return;
                end
                childrenSignalIDs=this.Model.getSignalChildrenIDs(sigID,true);
                for cdx=1:numel(childrenSignalIDs)



                    if any(childrenSignalIDs(cdx)==leafSignalIDs)
                        isHiddenRowOfComplexSignal=true;
                        return;
                    end
                end
            end
        end

        function[includeSublabels,isVisibleFlag,checkStatus]=getFlagsForCheckOrUncheckLabelHeader(~,eventType)
            if ismember(eventType,["check","checkLabelInstance"])
                includeSublabels=false;
                isVisibleFlag=true;
                checkStatus="check";
            elseif ismember(eventType,["uncheck","uncheckLabelInstance"])
                includeSublabels=false;
                isVisibleFlag=false;
                checkStatus="uncheck";
            elseif eventType=="checkAll"
                includeSublabels=true;
                isVisibleFlag=true;
                checkStatus="check";
            elseif eventType=="uncheckAll"
                includeSublabels=true;
                isVisibleFlag=false;
                checkStatus="uncheck";
            end
        end
    end
end
