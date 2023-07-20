classdef SignalObserverMenu






    methods(Static)



        function schema=getSimulinkSchema(cbinfo,tag,startLabel,stopLabel,icon,toggle)



            import Simulink.sdi.internal.SignalObserverMenu;
            if~isempty(toggle)&&toggle
                schema=sl_toggle_schema;
            else
                schema=sl_action_schema;
            end

            schema.tag=tag;
            schema.label=startLabel;
            if~isempty(icon)
                schema.icon=icon;
            end

            validSrcPortHs=...
            Simulink.sdi.internal.SignalObserverMenu.locGetValidSrcPortHandles(cbinfo);
            [~,IA]=unique(validSrcPortHs);
            validSrcPortHs=validSrcPortHs(IA);
            Simulink.sdi.internal.SignalObserverMenu.getSetLastSelectedPorts(validSrcPortHs);
            model=SignalObserverMenu.getModelName(cbinfo);






            schema.label=stopLabel;
            schema.userdata.action='disconnect';
            sigs=get_param(model,'InstrumentedSignals');
            for i=1:length(validSrcPortHs)
                if~SignalObserverMenu.hasVisuOnPort(validSrcPortHs(i),model,sigs)

                    schema.label=startLabel;
                    schema.userdata.action='connect';
                    break;
                end
            end

            if strcmp(get_param(model,'BlockDiagramType'),'library')
                schema.state='Hidden';
            elseif~isempty(validSrcPortHs)&&...
                ~SLStudio.Utils.isBlockDiagramCompiled(cbinfo)



                if isInsideLockedSSRefSystem(cbinfo)
                    schema.state='Disabled';
                else
                    schema.state='Enabled';
                end

                schema.userdata.portHs=validSrcPortHs;
                schema.userdata.model=model;
                schema.callback=@Simulink.sdi.internal.SignalObserverMenu.ConnectSignal;
            else
                schema.state='Disabled';
                schema.callback=@DAStudio.getDefaultCallback;
                schema.label=startLabel;
            end



            if~isempty(toggle)&&toggle&&SLStudio.Utils.selectionHasSegments(cbinfo)&&strcmpi(schema.userdata.action,'disconnect')
                schema.checked='Checked';
            end

            schema.autoDisableWhen='Busy';
        end

        function schema=getSchemaForStateActivity(cbinfo,objectType,mode,sfDialogInfo)

            import Simulink.sdi.internal.SignalObserverMenu;
            schema=sl_toggle_schema;
            if isempty(sfDialogInfo)
                sfDialogInfo=populateStateflowDialogInfo(cbinfo,objectType);
            end
            isChart=strcmpi(objectType,'chart')||strcmpi(objectType,'chartblock');
            if isChart
                schema.tag=sprintf('SDI:StreamChart%s',mode);
            else
                schema.tag=sprintf('SDI:StreamState%s',mode);
            end

            [desc,callback]=fetchStateActivityMode(mode);

            activity=getActivityFromMode(mode);

            uddHs=sf('IdToHandle',sfDialogInfo.selection);
            model=SignalObserverMenu.getModelName(cbinfo);



            if~isempty(uddHs)&&all(getObjectsLoggingActivity(model,...
                sfDialogInfo.chartBlkH,...
                uddHs,activity))
                schema.checked='Checked';


                sfDialogInfo.(activity)=false;
            else
                schema.checked='Unchecked';


                sfDialogInfo.(activity)=true;
            end

            if~SLStudio.Utils.showInToolStrip(cbinfo)
                schema.label=desc;
            end
            schema.callback=callback;
            schema.state=determineEnableStateForMode(sfDialogInfo,model,activity);
            schema.autoDisableWhen='Busy';

            function[desc,cb]=fetchStateActivityMode(mode)
                switch(mode)
                case 'ChildActivity'
                    desc=DAStudio.message('Stateflow:studio:SdiStreamingChildActivityMenu');
                    cb=@toggleChildActivityStream;
                case 'LeafActivity'
                    desc=DAStudio.message('Stateflow:studio:SdiStreamingLeafActivityMenu');
                    cb=@toggleLeafActivityStream;
                case 'SelfActivity'
                    desc=DAStudio.message('Stateflow:studio:SdiStreamingSelfActivityMenu');
                    cb=@toggleSelfActivityStream;
                end
            end


            function activity=getActivityFromMode(mode)
                switch(mode)
                case 'ChildActivity'
                    activity='Child';
                case 'LeafActivity'
                    activity='Leaf';
                case 'SelfActivity'
                    activity='Self';
                end
            end




            function toggleSelfActivityStream(varargin)
                selection=sfDialogInfo.selection;
                sfprivate('toggle_streaming_for_object',...
                sfDialogInfo.chartBlkH,...
                selection,...
                sfDialogInfo.Self,...
                'Self');
            end


            function toggleChildActivityStream(varargin)
                selection=removeAtomicSubcharts(sfDialogInfo.selection);
                sfprivate('toggle_streaming_for_object',...
                sfDialogInfo.chartBlkH,...
                selection,...
                sfDialogInfo.Child,...
                'Child');
            end

            function toggleLeafActivityStream(varargin)
                selection=removeAtomicSubcharts(sfDialogInfo.selection);
                sfprivate('toggle_streaming_for_object',...
                sfDialogInfo.chartBlkH,...
                selection,...
                sfDialogInfo.Leaf,...
                'Leaf');
            end


            function selection=removeAtomicSubcharts(selection)
                objHandles=sf('IdToHandle',selection);
                idx=arrayfun(@(obj)isa(obj,'Stateflow.AtomicSubchart'),objHandles);
                selection(idx)=[];
            end


            function activityLoggingArray=getObjectsLoggingActivity(model,blockH,uddHs,activity)
                instSigs=get_param(model,'InstrumentedSignals');
                blockSID=Simulink.ID.getSID(blockH);
                activityLoggingArray=zeros(1,length(uddHs));
                if~isempty(instSigs)
                    for idx=1:length(uddHs)
                        ssid=0;
                        if~isa(uddHs(idx),'Stateflow.Chart')&&...
                            ~isa(uddHs(idx),'Stateflow.StateTransitionTableChart')&&...
                            ~isa(uddHs(idx),'Stateflow.ReactiveTestingTableChart')&&...
                            ~isa(uddHs(idx),'Stateflow.Box')
                            ssid=uddHs(idx).SSIdNumber;
                        end
                        if instSigs.isGivenSFActivityObserved(blockSID,ssid,activity)
                            activityLoggingArray(idx)=true;
                        else
                            activityLoggingArray(idx)=false;
                        end
                    end
                end
            end


            function enableState=determineEnableStateForMode(sfDialogInfo,model,activity)
                enableState='Enabled';
                if sfDialogInfo.disableAllMenus
                    enableState='Disabled';
                    return;
                end

                uddHs=sf('IdToHandle',sfDialogInfo.selection);
                anyTurnedOn=any(getObjectsLoggingActivity(model,...
                sfDialogInfo.chartBlkH,...
                uddHs,activity));
                if anyTurnedOn
                    return;
                end

                multipleStateSelection=(~isChart&&length(sfDialogInfo.selection)>1);
                if~multipleStateSelection

                    atomicSubchart=isa(uddHs,'Stateflow.AtomicSubchart');
                    actionSate=isa(uddHs,'Stateflow.SimulinkBasedState');
                    parallelDecomp=~actionSate&&~atomicSubchart&&...
                    strcmpi(uddHs.Decomposition,'PARALLEL_AND');
                    isTSBlk=isa(uddHs,'Stateflow.ReactiveTestingTableChart');

                    disableChildren=atomicSubchart||actionSate||parallelDecomp||...
                    ~sfDialogInfo.hasChildren||isTSBlk;
                    disableLeaves=atomicSubchart||actionSate||parallelDecomp||...
                    ~sfDialogInfo.hasLeaves||isTSBlk;
                else
                    disableChildren=true;
                    disableLeaves=true;
                end

                switch(activity)
                case 'Child'
                    if disableChildren
                        enableState='Disabled';
                    end
                case 'Leaf'
                    if disableLeaves
                        enableState='Disabled';
                    end
                case 'Self'
                    if isChart
                        enableState='Disabled';
                    end
                end
            end
        end


        function schema=getStateflowSchema(cbinfo,objectType)


            import Simulink.sdi.internal.SignalObserverMenu;
            schema=sl_container_schema;
            schema.icon='Simulink:JetstreamMarkSelectedSignals';

            sfDialogInfo=populateStateflowDialogInfo(cbinfo,objectType);
            isChart=strcmpi(sfDialogInfo.selectionClass,'chart');

            if isChart
                schema.tag='SDI:ChartActivityStreaming';
            else
                schema.tag='SDI:StateActivityStreaming';
            end

            schema.label=sfDialogInfo.label;

            if isChart
                schema.childrenFcns={...
                @getChildStateActivitySchema,...
                @getLeafStateActivitySchema
                };
            else
                schema.childrenFcns={...
                @getChildStateActivitySchema,...
                @getLeafStateActivitySchema,...
                @getSelfActivitySchema
                };
            end

            schema.autoDisableWhen='Busy';

            if(sfDialogInfo.disableAllMenus)
                schema.state='disabled';
            end


            function schema=getSelfActivitySchema(cbinfo)

                schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,objectType,'SelfActivity',sfDialogInfo);
            end

            function schema=getChildStateActivitySchema(cbinfo)

                schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,objectType,'ChildActivity',sfDialogInfo);
            end


            function schema=getLeafStateActivitySchema(cbinfo)

                schema=Simulink.sdi.internal.SignalObserverMenu.getSchemaForStateActivity(cbinfo,objectType,'LeafActivity',sfDialogInfo);
            end

        end


        function success=ConnectSignal(cbinfo,~)












            import Simulink.sdi.internal.SignalObserverMenu;
            import Simulink.sdi.internal.ObserverInterface;


            portHs=cbinfo.userdata.portHs;
            numSelectedPorts=length(portHs);
            model=cbinfo.userdata.model;
            sigs=get_param(model,'InstrumentedSignals');
            signalSize=0;

            if strcmp(cbinfo.userdata.action,'connect')
                signals(numSelectedPorts)=Simulink.HMI.SignalSpecification;
                for i=1:numSelectedPorts
                    portH=portHs(i);
                    blkh=get_param(portH,'ParentHandle');
                    blk=Simulink.SimulationData.BlockPath.manglePath(get_param(portH,'Parent'));
                    portIdx=get_param(portH,'PortNumber');
                    sigName=get_param(portH,'Name');
                    if isempty(sigs)||~sigs.isGivenPortObserved(blkh,portIdx)
                        signalSize=signalSize+1;
                        signals(signalSize)=SignalObserverMenu.locGetSigSpec(blkh,portIdx,blk,sigName,portH);
                    end
                end
                signals=signals(:,1:signalSize);
                ObserverInterface.addObservers(model,signals);
            else
                signalSize=0;
                blockHandles=cell(1,numSelectedPorts);
                portIndices=cell(1,numSelectedPorts);
                uuids=cell(1,numSelectedPorts);
                portHandles=cell(1,numSelectedPorts);
                for i=1:numSelectedPorts
                    portH=portHs(i);
                    blkh=get_param(portH,'ParentHandle');
                    portIdx=get_param(portH,'PortNumber');
                    if~isempty(sigs)&&sigs.isGivenPortObserved(blkh,portIdx)
                        signalSize=signalSize+1;
                        blockHandles{signalSize}=blkh;
                        portIndices{signalSize}=portIdx;
                        portHandles{signalSize}=portH;
                        modelHandle=get_param(model,'Handle');
                        webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
                        if~isempty(webhmi)
                            widgetIds=webhmi.getWidgetIDListFromStreamingStore(blkh,portIdx,false);
                            if~isempty(widgetIds)
                                for index=1:length(widgetIds)
                                    widget=utils.getWidget(model,widgetIds{index});
                                    widget.unbind();
                                end
                            end
                        end
                        uuid=Simulink.HMI.InstrumentedSignals.getUUIDForBlock(blkh,portIdx,true);
                        if isempty(uuid)
                            uuid=sdi.Repository.generateUUID();
                        end
                        uuids{signalSize}=uuid;
                    else
                        locRemovePortLoggingFlag(portH);
                    end
                end
                blockHandles=blockHandles(:,1:signalSize);
                portIndices=portIndices(:,1:signalSize);
                uuids=uuids(:,1:signalSize);
                portHandles=portHandles(:,1:signalSize);
                signals=struct(...
                'BlockHandle',blockHandles,...
                'PortIndex',portIndices,...
                'PortHandle',portHandles,...
                'UUID',uuids);
                ObserverInterface.deleteObservers(model,signals);
            end
            success=isequal(numSelectedPorts,signalSize);






            if~slfeature('InstrumentedSignalsLogChangeEvents')
                timerObj=timer('Name','JetstreamBadgeDeferTimer','StartDelay',0.5);
                model=cbinfo.userdata.model;
                action=cbinfo.userdata.action;
                timerObj.TimerFcn=@(o,e)locDeferredActionTimerFcn(model,action,signals);
                timerObj.StopFcn=@(o,e)locClearTimer(o);
                start(timerObj);
            end
        end


        function has=hasVisuOnPort(sigOrPort,model,varargin)

            import Simulink.sdi.internal.SignalObserverMenu;
            has=false;


            try
                has=strcmp(get_param(sigOrPort,'DataLogging'),'on');
                if has
                    return;
                end
            catch me %#ok<NASGU>
            end


            if length(varargin)==1
                sigs=varargin{1};
            else
                sigs=get_param(model,'InstrumentedSignals');
            end
            if(isempty(sigs))
                return
            end


            if~isa(sigOrPort,'Simulink.HMI.SignalSpecification')
                blkh=get_param(sigOrPort,'ParentHandle');
                portIdx=get_param(sigOrPort,'PortNumber');
                if(isempty(portIdx))
                    return
                end
                has=sigs.isGivenPortObserved(blkh,portIdx);
            else
                has=sigs.isPortObserved(sigOrPort);
            end
        end


        function modelName=getModelName(cbinfo)

            modelName=cbinfo.editorModel.Name;
        end


        function valSrcPortsHdls=locGetValidSrcPortHandles(cbinfo)



            import Simulink.sdi.internal.SignalObserverMenu;

            if(cbinfo.isContextMenu)








                valSrcPortsHdls=...
                SignalObserverMenu.locGetContextMenuPort(cbinfo);

                if isempty(valSrcPortsHdls)


                    valSrcPortsHdls=...
                    SignalObserverMenu.locGetMultiSelectedPorts(cbinfo);
                end

            else
                valSrcPortsHdls=...
                SignalObserverMenu.locGetMultiSelectedPorts(cbinfo);
            end
        end


        function valSrcPortsHdls=locGetContextMenuPort(cbinfo)


            srcPortM3I=...
            Simulink.scopes.SignalMenus.GetViewerReadyPort(cbinfo);
            if~isempty(srcPortM3I)
                valSrcPortsHdls=srcPortM3I.handle;
            else
                valSrcPortsHdls=[];
            end
        end


        function valSrcPortsHdls=locGetMultiSelectedPorts(cbinfo)

            cbObj=cbinfo.uiObject;
            if isa(cbObj,'Simulink.BlockDiagram')||isa(cbObj,'Simulink.SubSystem')


                line=find_system(cbObj.handle,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'SearchDepth',1,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'FindAll','on',...
                'Type','line','Selected','on');
                if isempty(line)



                    line=find(cbObj,'Type','line','Selected','on','-depth',1);%#ok<GTARG>
                end
            else
                valSrcPortsHdls=[];
                return;
            end
            valSrcPortsHdls=zeros(length(line),1);
            for idx=1:length(line)
                if isa(line(idx),'Simulink.Line')
                    onePort=getSourcePort(line(idx));
                    if~isempty(onePort)&&strcmpi(get_param(onePort,'PortType'),'outport')
                        valSrcPortsHdls(idx)=onePort.Handle;
                    end
                else
                    onePort=get_param(line(idx),'SrcPortHandle');
                    if~isequal(-1,onePort)&&strcmpi(get_param(onePort,'PortType'),'outport')
                        valSrcPortsHdls(idx)=onePort;
                    end
                end
            end
            valSrcPortsHdls=valSrcPortsHdls(valSrcPortsHdls~=0);
        end


        function sig=locGetSigSpec(blkHandle,portIdx,blk,sigName,portH)
            sig=Simulink.HMI.SignalSpecification;



            sig=setPortHandle(sig,portH,false);
            sig.CachedPortIdx_=portIdx;
            sig.CachedBlockHandle_=blkHandle;
            sig.OutputPortIndex=portIdx;
            try
                sid=get_param(blkHandle,'SIDFullString');
            catch
                sid='';
            end
            if isempty(blk)
                blk='';
            end
            if isempty(sid)
                sid='';
            end
            sig.BlockPath_=blk;
            sig.SID_=sid;
            sig.SignalName_=sigName;
        end

        function ret=getSetLastSelectedPorts(varargin)
            persistent LastSelectedPorts
            if nargin>0
                LastSelectedPorts=varargin{1};
            end
            ret=LastSelectedPorts;
        end
    end

end



function sfDialogInfo=populateStateflowDialogInfo(cbinfo,objectType)



    selectedStateIds=[];
    sfDialogInfo.disableAllMenus=false;
    viewContainerId=0;
    if strcmpi(objectType,'chartblock')
        if SLStudio.Utils.objectIsValidBlock(SLStudio.Utils.getOneMenuTarget(cbinfo))
            block=SLStudio.Utils.getOneMenuTarget(cbinfo);
            viewContainerId=sfprivate('block2chart',block.handle);
            objectType='chart';
            sfDialogInfo.chartBlkH=block.handle;
        end
    elseif strcmpi(objectType,'chart')
        sfDialogInfo.chartBlkH=locGetChartBlockHandle(cbinfo);
        sfDialogInfo.selectionIsViewer=true;
        viewContainerId=locGetViewContainerIdForSF(cbinfo);
        if sf('get',viewContainerId,'.isa')~=1
            viewContainerId=sf('get',viewContainerId,'.chart');
        end
    end
    if viewContainerId==0
        sfDialogInfo.chartBlkH=locGetChartBlockHandle(cbinfo);
        sfDialogInfo.selectionIsViewer=true;
        viewContainerId=locGetViewContainerIdForSF(cbinfo);
        viewContainer=sf('IdToHandle',viewContainerId);
        if isa(viewContainer,'Stateflow.StateTransitionTableChart')
            chartId=SFStudio.Utils.getChartId(cbinfo);
            sttman=Stateflow.STT.StateEventTableMan(chartId);
            si=sttman.viewManager.CurrentSelectionInfo;
            numberSelectedObjects=0;
            if si.RowIndex~=-1&&si.ColumnIndex==1
                ce=sttman.getCellAtLocation(si.RowIndex,si.ColumnIndex);
                if~isempty(ce)
                    numberSelectedObjects=1;
                    selectedObjects=[ce.stateObjectId];
                end
            end
        else

            editorSelection=locGetEditorSelection(cbinfo);
            numberSelectedObjects=editorSelection.size();
            selectedObjects=zeros(1,numberSelectedObjects);
            for iter=1:numberSelectedObjects
                selectedObj=editorSelection.at(iter);
                try
                    id=double(selectedObj.backendId);
                catch
                    id=-1;
                end
                selectedObjects(iter)=id;
            end
        end

        selectedStateIds=zeros(1,numberSelectedObjects);
        allSelectedObjectsAreCommentedOut=true;
        for iter=1:numberSelectedObjects
            id=selectedObjects(iter);
            uddH=sf('IdToHandle',id);
            if sfprivate('is_loggable_graphical_object',uddH)
                allSelectedObjectsAreCommentedOut=allSelectedObjectsAreCommentedOut&&uddH.isCommented;
                selectedStateIds(iter)=id;
            end
        end

        sfDialogInfo.disableAllMenus=allSelectedObjectsAreCommentedOut;
        selectedStateIds(selectedStateIds==0)=[];
    end



    insideForEach=locIsChartInsideForEach(sfDialogInfo.chartBlkH);
    sfDialogInfo.disableAllMenus=sfDialogInfo.disableAllMenus|insideForEach;

    if length(selectedStateIds)==1
        [sfDialogInfo.hasChildren,sfDialogInfo.hasLeaves]=...
        locGetObjectChildrenAndLeaves(selectedStateIds(1));
    end


    if~isempty(selectedStateIds)

        sfDialogInfo.selectionIsViewer=false;
        sfDialogInfo.selection=selectedStateIds;
        sfDialogInfo.selectionClass='State';
        if length(selectedStateIds)==1
            sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForState',...
            sf('get',selectedStateIds,'.name'));
        else
            sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForSeletedStates');
        end
        return;
    elseif strcmpi(objectType,'state')&&viewContainerId~=0&&sf('get',viewContainerId,'.isa')==1


        sfDialogInfo.disableAllMenus=true;
        sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForSeletedStates');
        sfDialogInfo.selection=[];
        sfDialogInfo.selectionClass='State';
        return;
    end

    uddH=sf('IdToHandle',viewContainerId);
    sfDialogInfo.selection=0;

    if viewContainerId~=0

        if sf('get',viewContainerId,'.isa')==1&&...
            (strcmpi(objectType,'chart')||strcmpi(objectType,'chartblock'))

            sfDialogInfo.selection=viewContainerId;
            sfDialogInfo.selectionClass='Chart';
            name=get_param(sfDialogInfo.chartBlkH,'Name');
            switch(class(uddH))
            case 'Stateflow.Chart'
                sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForChart',name);
                sfDialogInfo.disableAllMenus=isempty(sf('SubstatesIn',uddH.Id))|...
                sfDialogInfo.disableAllMenus;
            case 'Stateflow.StateTransitionTableChart'
                sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForSTT',name);
                sfDialogInfo.disableAllMenus=isempty(sf('SubstatesIn',uddH.Id))|...
                sfDialogInfo.disableAllMenus;
            case 'Stateflow.TruthTableChart'
                sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForTT',name);
                sfDialogInfo.disableAllMenus=true;
            end

            if sfDialogInfo.disableAllMenus==false
                [sfDialogInfo.hasChildren,sfDialogInfo.hasLeaves]=...
                locGetObjectChildrenAndLeaves(uddH.Id);
            end
        else

            sfDialogInfo.selection=viewContainerId;
            sfDialogInfo.selectionClass='State';
            sfDialogInfo.label=DAStudio.message('Stateflow:studio:SdiStreamingOptionsForState',sf('get',viewContainerId,'.name'));
            if isa(class(uddH),'Stateflow.State')
                sfDialogInfo.disableAllMenus=sf('get',viewContainerId,'.isa')==1;
            else
                sfDialogInfo.disableAllMenus=true;
            end

            insideForEach=locIsChartInsideForEach(sfDialogInfo.chartBlkH);
            sfDialogInfo.disableAllMenus=sfDialogInfo.disableAllMenus|insideForEach;
        end
    end
end


function insideForEach=locIsChartInsideForEach(chartH)
    insideForEach=false;
    parent=get_param(chartH,'Parent');
    if getSimulinkBlockHandle(parent)>0
        blockType=get_param(parent,'BlockType');
        if strcmp(blockType,'SubSystem')
            insideForEach=length(find_system(parent,'SearchDepth',1,...
            'FirstResultOnly',true,'BlockType','ForEach'))==1;
        end
    end
end


function chartBlkH=locGetChartBlockHandle(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    chartBlkH=SLM3I.SLCommonDomain.getSLHandleForHID(editor.getHierarchyId);
end


function containerId=locGetViewContainerIdForSF(cbinfo)
    containerId=SFStudio.Utils.getSubviewerId(cbinfo);
end


function selection=locGetEditorSelection(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    selection=editor.getSelection;
end


function locDeferredActionTimerFcn(mdl,action,signals)


    try
        get_param(mdl,'Object');
    catch
        return;
    end

    if dig.isProductInstalled('DSP System Toolbox')||dig.isProductInstalled('SoC Blockset')
        Simulink.scopes.LAScope.connectSignals(mdl,action,signals);
    end
end


function locClearTimer(timerObj)
    delete(timerObj);
end


function[hasChildren,hasLeaves]=locGetObjectChildrenAndLeaves(objectid)
    hasChildren=false;
    hasLeaves=false;
    children=sf('SubstatesOf',objectid);
    if~isempty(children)
        hasChildren=true;



        leaves=ismember(sf('LeafstatesIn',objectid),children);
        leaves(leaves~=0)=[];

        if~isempty(leaves)
            hasLeaves=true;
        end
    end
end


function locRemovePortLoggingFlag(ports)
    set(ports,'DataLogging','off');
end


function result=isInsideLockedSSRefSystem(cbinfo)
    cbObj=cbinfo.uiObject;
    if isa(cbObj,'Simulink.BlockDiagram')||isa(cbObj,'Simulink.SubSystem')
        result=slInternal('isSRGraphLockedForEditing',cbObj.handle);
        return;
    end
    result=false;
end


