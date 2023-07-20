classdef(Sealed)CodeViewManager<handle






    properties(GetAccess=public,SetAccess=immutable)
ViewId
    end

    properties(GetAccess=public,SetAccess=immutable,Hidden)
MessageService
SudId
    end

    properties(SetAccess=private,Hidden)
CodeView
    end

    properties(Access=private)
activeBlock
handles
mlfbHandles
childrenHandles
listeners
subscriptions
blockListeners
variantTarget
hierarchy
pendingSubsystems
pendingBlockOps
busyCompiling
ignoreScriptChange
ready
readyCallbacks
modelName
mlfbHandlesSorted
disposing
attemptReopen
lastBusy
    end

    methods(Access=private)
        function this=CodeViewManager(codeView)
            assert(isa(codeView,'com.mathworks.toolbox.coder.mlfb.MtCodeView'));
            this.CodeView=codeView;

            this.MessageService=coder.internal.gui.MessageService.getInstance(codeView.getMessageBus());
            coder.internal.mlfb.gui.CodeViewManager.registerMessagingTypeAdapters(this.MessageService);

            this.ViewId=codeView.getViewId();
            this.SudId=coder.internal.mlfb.idForBlock(codeView.getSudInfo().getBlockId());
            this.hierarchy=codeView.getBlockHierarchy();
            this.busyCompiling=false;
            this.ignoreScriptChange=false;
            this.disposing=false;
            this.attemptReopen=false;
            this.lastBusy=false;

            this.pendingSubsystems={};
            this.pendingBlockOps=containers.Map();
            this.listeners={};
            this.subscriptions={};
            this.blockListeners=coder.internal.mlfb.createBlockMap();
            this.mlfbHandles=[];
            this.mlfbHandlesSorted=false;
            this.readyCallbacks={};
            this.handles=containers.Map('KeyType','double','ValueType','any');
            this.childrenHandles=containers.Map('KeyType','double','ValueType','any');

            this.attachMessaging();
            this.attachSimulink();
            this.attachAllBlockListeners();
            this.attachFixedPointTool();

            assert(isa(this.hierarchy,'com.mathworks.toolbox.coder.mlfb.BlockHierarchyBuilder$BlockHierarchyImpl'));
        end

        function attachMessaging(this)
            import coder.internal.mlfb.gui.MessageTopics;
            this.subscribeToTopic(MessageTopics.CodeViewStateChange,@this.handleCodeViewStateChange);
            this.subscribeToTopic(MessageTopics.FixedPointParamChange,@this.handleFixedPointParamChange);
            this.subscribeToTopic(MessageTopics.ActionTrigger,@this.handleActionTrigger);
        end

        function onReadOnlyChanged(this,evt)





            try
                if strcmp(evt.Type,'ReadonlyChangedEvent')&&isManagedFunctionBlock(evt.Source)

                    this.publish(coder.internal.mlfb.gui.MessageTopics.StateflowUpdate,...
                    'blockLockedStateChanged',coder.internal.mlfb.idForBlock(evt.Source),...
                    ~coder.internal.mlfb.gui.MlfbUtils.isChartEnabled(evt.Source));
                end
            catch me

                coder.internal.gui.asyncDebugPrint(me);
            end

            function managed=isManagedFunctionBlock(chart)
                managed=false;
                if~isa(chart,'Stateflow.EMChart')
                    return;
                end
                blockHandle=sfprivate('chart2block',chart.Id);
                if isempty(blockHandle)
                    return;
                end

                if~this.mlfbHandlesSorted

                    this.mlfbHandles=sort(this.mlfbHandles);
                    this.mlfbHandlesSorted=true;
                end

                low=int32(1);
                high=int32(numel(this.mlfbHandles));
                while low<=high
                    mid=(low+high)/2;
                    mlfbHandle=this.mlfbHandles(mid);
                    if mlfbHandle==blockHandle
                        managed=true;
                        break;
                    elseif mlfbHandle<blockHandle
                        low=mid+1;
                    else
                        high=mid-1;
                    end
                end
            end
        end

        function attachSimulink(this)
            modelObj=get_param(this.SudId.ModelHandle,'Object');


            this.modelName=this.SudId.ModelName;
            saveCallbackId=sprintf('CoderF2FCodeViewManagerSaveCallback%d',this.ViewId);
            modelObj.addCallback('PostSave',saveCallbackId,@modelSaved);
            this.appendListener(onCleanup(@cleanupCallbackIfValid));

            addUddListener(modelObj,'EnginePostCompStart',@(~,~)modelCompiling(true));
            addUddListener(modelObj,'EngineCompPassed',@(~,~)modelCompiled(true));
            addUddListener(modelObj,'EngineCompFailed',@(~,~)modelCompiled(false));
            addUddListener(modelObj,'EngineSimulationBegin',@(~,~)this.updateBusyState());
            addUddListener(modelObj,'EngineSimStatusStopped',@simEnded);
            addUddListener(modelObj,'EngineSimStatusTerminating',@simEnded);

            function cleanupCallbackIfValid()
                try
                    modelObj.removeCallback('PostSave',saveCallbackId);%#ok<MOCUP>
                catch

                end
            end

            function simEnded(~,~)
                this.updateBusyState();
            end

            function modelSaved()
                if~strcmp(this.modelName,this.SudId.ModelName)
                    oldName=this.modelName;
                    this.modelName=this.SudId.ModelName;
                    this.publishSimulinkUpdate('modelRenamed',oldName,this.modelName);
                end
            end

            function modelCompiling(compiling)
                this.busyCompiling=compiling;
                this.updateBusyState();
            end

            function modelCompiled(success)
                modelCompiling(false);
                simulating=strcmpi(get_param(this.SudId.ModelName,'SimulationStatus'),'initializing');
                this.publishSimulinkUpdate('modelCompiled',success,simulating);
            end

            function addUddListener(obj,event,callback)
                if isa(obj,"DAStudio.EventDispatcher")
                    this.appendListener(handle.listener(obj,event,@(~,e)callback(e)));
                else
                    this.appendListener(Simulink.listener(obj,event,@(~,e)callback(e)));
                end
            end
        end

        function attachFixedPointTool(this)
            fpt=coder.internal.mlfb.FptFacade.getInstance();
            assert(fpt.isLive(),'Fixed-Point Tool is not open');


            this.appendListener(fpt.onSudChanged(@this.closeAndReopen));

            this.appendListener(fpt.onDisposed(@this.close));


            import coder.internal.mlfb.FptSetting;
            this.appendListener(fpt.onSettingChanged(@publishSettingChange,...
            FptSetting.WordLength,...
            FptSetting.FractionLength,...
            FptSetting.SafetyMargin,...
            FptSetting.ProposeSignedness,...
            FptSetting.ProposeWordLength));

            function publishSettingChange(setting,value)
                import coder.internal.mlfb.FptSetting;
                switch setting
                case FptSetting.WordLength
                    pushMethod='fptWordLengthChanged';
                case FptSetting.FractionLength
                    pushMethod='fptFractionLengthChanged';
                case FptSetting.SafetyMargin
                    pushMethod='fptSafetyMarginChanged';
                case FptSetting.ProposeSignedness
                    pushMethod='fptProposeSignednessChanged';
                case FptSetting.ProposeWordLength
                    pushMethod='fptProposeWordLengthChanged';
                otherwise
                    error('Unhandled FPTSetting change for %s',setting);
                end

                try
                    this.notifyCodeView(pushMethod,value);
                catch me
                    coder.internal.gui.asyncDebugPrint(me);
                end
            end
        end

        function attachAllBlockListeners(this)
            ids=this.CodeView.getSudBlockIds();
            coder.internal.mlfb.gui.MlfbUtils.walkSidHierarchy(this.SudId,@visitNode);

            function cue=visitNode(nodeId)
                if coder.internal.mlfb.gui.MlfbUtils.isFunctionBlock(nodeId)
                    [~,fixptSid]=coder.internal.mlfb.getMlfbVariants(nodeId.SID);
                    assert(strcmp(fixptSid,nodeId.SID)||ids.contains(nodeId.toJava()),...
                    'MLFB list should still be in sync with the Java side: ''%s'' is missing.',nodeId);
                    this.blockListeners(nodeId)=this.attachMlfbBlockListeners(nodeId);
                    cue=0;
                else
                    nodeObject=nodeId.Block;
                    if nodeObject.isHierarchical()
                        this.blockListeners(nodeId)=this.attachSimulinkBlockListeners(nodeId);
                    end
                    cue=1;
                end
            end
        end

        function listeners=attachMlfbBlockListeners(this,blockId)


            assert(blockId.isFunctionBlock());
            this.mlfbHandles(end+1)=blockId.Handle;
            this.mlfbHandlesSorted=false;

            chart=blockId.getChart();
            listeners={};

            addPropListener('Iced',@onEnabledStateChange);
            addPropListener('Locked',@onEnabledStateChange);
            addPropListener('Script',@onCodeChange);
            chartLis=Simulink.listener(chart,'ReadonlyChangedEvent',@(src,evt)this.onReadOnlyChanged(evt));
            slListeners=this.attachSimulinkBlockListeners(blockId);
            this.blockListeners(blockId)={listeners(:),slListeners(:),chartLis};

            function onCodeChange(chart)
                if~this.ignoreScriptChange
                    topic=com.mathworks.toolbox.coder.mlfb.FunctionBlockConstants.STATEFLOW_UI_UPDATE_TOPIC;
                    this.publish(topic,'blockCodeChanged',blockId,chart.Script);
                end
            end

            function onEnabledStateChange(chart)
                this.publish(coder.internal.mlfb.gui.MessageTopics.StateflowUpdate,...
                'blockLockedStateChanged',blockId,~coder.internal.mlfb.gui.MlfbUtils.isChartEnabled(chart));
            end

            function addPropListener(propName,callback)
                assert(exist('chart','var')&&~isempty(chart));
                prop=findprop(chart,propName);
                assert(~isempty(prop));

                eventName="PostSet";
                listener=Simulink.listener(chart,prop,eventName,...
                @(~,~)callback(chart));
                listeners{end+1}=listener;
            end
        end

        function listeners=attachSimulinkBlockListeners(this,blockId)
            blockObj=blockId.Block;
            this.handles(blockId.Handle)=blockId;
            listeners={};

            parentId=blockId.getParent();
            if~isempty(parentId)
                if this.childrenHandles.isKey(parentId.Handle)
                    current=this.childrenHandles(parentId.Handle);
                    current(end+1)=blockId.Handle;
                    this.childrenHandles(parentId.Handle)=current;
                else
                    this.childrenHandles(parentId.Handle)=blockId.Handle;
                end
            end

            addBlockUddListener('NameChangeEvent',@objectRenamed);
            if isa(blockObj,'Simulink.SubSystem')
                addBlockUddListener('ReadonlyChangedEvent',@this.onReadOnlyChanged);
            end

            if blockObj.isHierarchical()&&~blockId.isFunctionBlock()
                addBlockUddListener('ObjectChildAdded',@childAdded);
                addBlockUddListener('ObjectChildRemoved',@childRemoved);
            end

            function objectRenamed(e)
                if this.isApplying()

                    return;
                end

                sourceId=coder.internal.mlfb.idForBlock(e.Source);
                name=sourceId.Name;
                javaId=sourceId.toJava();
                this.hierarchy.setBlockName(javaId,name);
                this.publishSimulinkUpdate('blockRenamed',javaId,name);
            end

            function childAdded(e)
                if isprop(e,'Child')
                    this.internalAddBlock(e.Source,e.Child);
                end
            end

            function childRemoved(e)
                if isprop(e,'Child')
                    this.internalRemoveBlock(e.Child);
                end
            end

            function addBlockUddListener(event,callback)
                listener=Simulink.listener(blockObj,event,@(~,e)callback(e));
                listeners{end+1}=listener;
            end
        end

        function closeAndReopen(this)
            if~isempty(this.variantTarget)


                return;
            end

            try
                this.attemptReopen=coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled();
                this.close();
            catch me
                coder.internal.gui.asyncDebugPrint(me);
            end
        end

        function detachStateflowFromBlock(this,blockId)
            this.blockListeners.remove(blockId);
        end

        function applying=isApplying(this)
            applying=~isempty(this.variantTarget);
        end

        function publish(this,topic,method,varargin)
            if~this.disposing
                assert(ischar(method));
                this.MessageService.publish(topic,method,varargin{:});
            end
        end

        function publishSimulinkUpdate(this,method,varargin)
            this.publish(coder.internal.mlfb.gui.MessageTopics.SimulinkUpdate,...
            method,varargin{:});
        end

        function subscribeToTopic(this,topic,fcnHandle)
            assert(isa(fcnHandle,'function_handle'));
            this.subscriptions{end+1}=this.MessageService.subscribe(fcnHandle,topic);
        end

        function beginDisposing(this)
            if~this.disposing

                this.blockListeners.remove(this.blockListeners.keys());
                coder.internal.mlfb.gui.CodeViewManager.removeInstance(this);
                coder.internal.MLFcnBlock.Float2FixedManager.reset(this.SudId);
                this.listeners={};
                this.disposing=true;
            end
        end

        function finishDisposing(this)

            this.subscriptions={};
            this.MessageService.terminate();


            if this.attemptReopen&&coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled()
                try
                    coder.internal.mlfb.gui.fxptToolOpenCodeView();
                catch
                end
            else
                this.CodeView=[];
            end
            this.attemptReopen=false;
        end

        function appendListener(this,listener)
            this.listeners{end+1}=listener;
        end

        function internalAddBlock(this,parentObj,blockObj)
            import coder.internal.mlfb.gui.MlfbUtils;

            if~MlfbUtils.isRelevantBlock(blockObj)
                return;
            end

            parentId=coder.internal.mlfb.idForBlock(parentObj);
            childId=coder.internal.mlfb.idForBlock(blockObj);
            blockType=MlfbUtils.getJavaBlockType(blockObj);
            applyInAction=this.isApplying();

            if~this.handles.isKey(blockObj.handle)

                if applyInAction
                    if this.pendingBlockOps.isKey(this.variantTarget)
                        queuedOps=this.pendingBlockOps(this.variantTarget);
                    else
                        queuedOps={};
                    end

                    queuedOps{end+1}=@()this.hierarchy.add(parentId.toJava(),childId.toJava(),childId.Name,blockType);
                    this.pendingBlockOps(this.variantTarget)=queuedOps;
                else
                    this.hierarchy.add(parentId.toJava(),childId.toJava(),childId.Name,blockType);
                end
            end

            mlfbInfo=[];
            mlfbCode=[];
            convMlfbInfo=[];
            convMlfbCode=[];

            if childId.isFunctionBlock()

                [mlfbInfo,mlfbCode]=getFunctionBlockInfo(childId);
                this.blockListeners(childId)=this.attachMlfbBlockListeners(childId);
                managed=false;walk=false;
            else

                this.blockListeners(childId)=this.attachSimulinkBlockListeners(childId);
                managed=applyInAction||MlfbUtils.isManagedVariantSubsystem(childId);
                walk=true;
            end

            if~applyInAction
                if managed


                    [orig,fixpt]=coder.internal.mlfb.getMlfbVariants(childId.SID);
                    assert(~isempty(orig)&&~isempty(fixpt));
                    [orig,fixpt]=coder.internal.mlfb.idForBlock(orig,fixpt);
                    [mlfbInfo,mlfbCode]=getFunctionBlockInfo(orig);
                    [convMlfbInfo,convMlfbCode]=getFunctionBlockInfo(fixpt);

                    this.blockListeners(orig)=this.attachMlfbBlockListeners(orig);
                    this.blockListeners(fixpt)=this.attachMlfbBlockListeners(fixpt);

                    blockType=MlfbUtils.getJavaBlockType(orig);
                    this.hierarchy.add(childId.toJava(),orig.toJava(),orig.Name,blockType);
                    this.hierarchy.add(childId.toJava(),fixpt.toJava(),fixpt.Name,blockType);
                end
            else


                return;
            end

            this.publishSimulinkUpdate(...
            'blockAdded',...
            this.SudId,...
            childId,...
            mlfbInfo,...
            mlfbCode,...
            convMlfbInfo,...
            convMlfbCode);

            if walk
                MlfbUtils.walkSidHierarchy(childId,@visitNode);
            end

            function[info,code]=getFunctionBlockInfo(id)
                [info,code]=coder.internal.mlfb.gui.MlfbUtils.getFunctionBlockInfoAndCode(id);
            end

            function cue=visitNode(parentId,nodeId)
                if isempty(parentId)
                    cue=1;
                    return;
                end

                if coder.internal.mlfb.gui.MlfbUtils.isFunctionBlock(nodeId)
                    this.internalAddBlock(parentId,nodeId.Block);
                    cue=0;
                else
                    nodeObject=nodeId.Block;
                    if nodeObject.isHierarchical()
                        this.internalAddBlock(parentId,nodeObject);
                    end
                    cue=1;
                end
            end
        end

        function allRemoved=internalRemoveBlock(this,blockObj,broadcast)
            allRemoved={};

            if isnumeric(blockObj)
                blockHandle=blockObj;
            else
                blockHandle=blockObj.handle;
            end

            if~this.handles.isKey(blockHandle)
                return;
            elseif this.isApplying()


                return;
            end

            id=this.handles(blockHandle);
            this.handles.remove(blockHandle);
            this.blockListeners.remove(id);
            allRemoved={id.toJava()};

            if ismember(blockHandle,this.mlfbHandles)

                this.mlfbHandles=this.mlfbHandles(this.mlfbHandles(:)~=blockHandle);
            elseif this.childrenHandles.isKey(blockHandle)
                subRemoved=arrayfun(@(b)this.internalRemoveBlock(b,false),...
                this.childrenHandles(blockHandle),'UniformOutput',false);
                for i=1:numel(subRemoved)
                    allRemoved=[allRemoved,subRemoved{i}];%#ok<AGROW>
                end
                this.childrenHandles.remove(blockHandle);
            end

            if nargin<3||broadcast
                this.publishSimulinkUpdate('blocksRemoved',this.SudId,...
                java.util.Arrays.asList(allRemoved));
            end

            this.hierarchy.remove(id.toJava());
        end

        function updateBusyState(this)
            simStatus=get_param(this.SudId.ModelName,'SimulationStatus');
            busy=~strcmpi(simStatus,'stopped')||this.busyCompiling||...
            ~coder.internal.mlfb.gui.CodeViewUpdater.isGloballyEnabled();

            changed=busy~=this.lastBusy;
            this.lastBusy=busy;

            if changed
                this.publishSimulinkUpdate('modelBusyStateChanged',busy);
            end
        end
    end


    methods(Access=private)
        function handleCodeViewStateChange(this,message)
            switch message.type
            case 'editorCodeChanged'
                if message.data.propagate
                    this.ignoreScriptChange=true;
                    try
                        coder.internal.gui.GuiUtils.setBlockScript(...
                        message.data.block,...
                        message.data.code);
                    catch

                    end
                    this.ignoreScriptChange=false;
                end
            case 'codeViewBlockChanged'
                this.activeBlock=coder.internal.mlfb.idForBlock(message.data.currentBlockId);
            case 'codeViewReady'
                assert(message.data.success);
                this.ready=true;
                runReadyTasks();
            case 'codeViewClosing'
                this.beginDisposing();
            case 'codeViewClosed'
                this.finishDisposing();
            end

            function runReadyTasks()
                for i=1:numel(this.readyCallbacks)
                    this.runReadyTask(this.readyCallbacks{i});
                end
                this.readyCallbacks={};
            end
        end

        function runReadyTask(this,callback)
            validateattributes(callback,{'function_handle','char'},{});
            if ischar(callback)
                callback=str2func(callback);
            end

            try
                if nargin(callback)==0
                    callback();
                else
                    callback(this);
                end
            catch me
                coder.internal.gui.asyncDebugPrint(me);
            end
        end

        function handleFixedPointParamChange(this,message)
            if isempty(this.activeBlock)
                return;
            end

            import coder.internal.mlfb.FptFacade;
            import coder.internal.MLFcnBlock.Float2FixedManager;

            switch message.type
            case 'fimathChanged'
                Float2FixedManager.setSudFimath(this.SudId,message.data.fimath);
            case 'wordLengthChanged'
                FptFacade.invoke('setAutoscalerWordLength',int32(message.data.wordLength));
            case 'fractionLengthChanged'
                FptFacade.invoke('setAutoscalerFractionLength',int32(message.data.fractionLength));
            case 'safetyMarginChanged'
                FptFacade.invoke('setAutoscalerSafetyMargin',message.data.safetyMargin);
            case 'proposeSignednessChanged'
                FptFacade.invoke('setAutoscalerProposeSignedness',message.data.proposeSignedness);
            case 'proposeFractionLengthChanged'
                FptFacade.invoke('setAutoscalerProposeWordLength',~message.data.proposeFractionLength);
            case 'blockReplacementsChanged'
                Float2FixedManager.setBlockFunctionReplacements(message.data.block,message.data.replacements);
            case 'sudReplacementsChanged'
                Float2FixedManager.setSudFunctionReplacements(this.SudId,message.data.replacements);
            case 'proposedTypeAnnotated'
                handleProposedTypeAnnotation(message.data);
            case 'fixedPointParamChanged'

            otherwise
                coder.internal.gui.asyncPrint('Unhandled param change: %s',message.type);
            end

            function handleProposedTypeAnnotation(data)
                import coder.internal.MLFcnBlock.Float2FixedManager;

                adjustedSpecId=max(data.varSpecialization,1);
                success=Float2FixedManager.setProposedType(data.mlfb,data.run,data.functionId,...
                data.varName,adjustedSpecId,data.proposedType);
                if success




                    this.notifyCodeView('typesProposed',true);
                else

                    this.publish(coder.internal.mlfb.gui.MessageTopics.BackendPush,...
                    'fptProposedTypeAnnotated',data.functionId,data.varName,...
                    data.varSpecialization,data.oldType,false);
                end
            end
        end

        function handleActionTrigger(~,message)
            switch message.type
            case 'codeViewApplyTypes'
                actionFuncName='mlfbApply';
            case 'codeViewProposeTypes'
                actionFuncName='mlfbProposeTypes';
            otherwise
                error('Unrecognized action trigger: %s',message.type);
            end

            emlcprivate(actionFuncName,message.data.runName);
        end
    end

    methods(Hidden)
        function close(this)
            if~isempty(this.CodeView)
                this.beginDisposing();
                this.CodeView.dispose();
            end
        end

        function show(this)
            this.CodeView.bringToFront();
        end

        function whenReady(this,callback)
            validateattributes(callback,{'function_handle','char'},{});
            if this.ready
                this.runReadyTask(callback);
            else
                this.readyCallbacks{end+1}=callback;
            end
        end

        function publishToCodeView(this,topic,methodName,varargin)
            validateattributes(topic,{'com.mathworks.toolbox.coder.mb.MessageTopic','coder.internal.mlfb.gui.MessageTopics'},{});
            validateattributes(methodName,{'char'},{});
            this.publish(topic,methodName,varargin{:});
        end

        function notifyCodeView(this,pushMethodName,varargin)
            this.publishToCodeView(coder.internal.mlfb.gui.MessageTopics.BackendPush,pushMethodName,varargin{:});
        end

        function markVariantCreationStart(this,blockSid)
            assert(isempty(this.variantTarget));
            this.variantTarget=blockSid;
        end

        function markVariantCreationEnd(this,mlfbSid,sysSid,newCreation)
            if newCreation
                assert(strcmp(this.variantTarget,mlfbSid)&&...
                coder.internal.mlfb.gui.MlfbUtils.isManagedVariantSubsystem(sysSid));
                this.pendingSubsystems{end+1}=sysSid;
            end
            this.variantTarget=[];
        end

        function markTypesApplied(this,success)
            assert(isempty(this.variantTarget));


            sud=coder.internal.mlfb.FptFacade.invoke('getSud');
            if isempty(sud)||this.SudId~=coder.internal.mlfb.idForBlock(sud)

                this.closeAndReopen();
                return;
            end

            cellfun(@processSubsystem,this.pendingSubsystems);
            this.pendingSubsystems={};
            this.pendingBlockOps=containers.Map();

            this.notifyCodeView('typesApplied',success);

            function processSubsystem(sysSid)
                import coder.internal.mlfb.gui.MlfbUtils;

                [origVariant,fixptVariant]=coder.internal.mlfb.getMlfbVariants(sysSid);
                assert(~isempty(origVariant)&&~isempty(fixptVariant));
                [origVariant,fixptVariant]=coder.internal.mlfb.idForBlock(origVariant,fixptVariant);
                [fixptInfo,fixptCode]=MlfbUtils.getFunctionBlockInfoAndCode(fixptVariant);
                sysId=coder.internal.mlfb.idForBlock(sysSid);

                if this.pendingBlockOps.isKey(origVariant.SID)
                    cellfun(@(fh)fh(),this.pendingBlockOps(origVariant.SID));
                end
                this.hierarchy.remap(origVariant.toJava(),sysId.toJava());
                this.hierarchy.setBlockName(sysId.toJava(),sysId.Name);

                this.blockListeners(fixptVariant)=this.attachMlfbBlockListeners(fixptVariant);
                this.notifyCodeView('outputVariantChanged',origVariant,fixptInfo,fixptCode);
            end
        end

        function fptGlobalActionStateChanged(this,~)
            this.updateBusyState();
        end

        function setCodeViewData(~,~,data)
            assert(isa(data,'com.mathworks.toolbox.coder.mlfb.CodeViewBlockData'));
        end

        function getCodeViewData(~,~)

        end
    end

    methods(Static)
        function open=isActive()
            map=coder.internal.mlfb.gui.CodeViewManager.getInstanceMap();
            open=~isempty(map);
        end

        function closeActive()
            active=coder.internal.mlfb.gui.CodeViewManager.getActiveCodeView();
            if~isempty(active)
                active.close();
            end
        end
    end

    methods(Static,Hidden)
        function instance=manage(codeView)
            instance=coder.internal.mlfb.gui.CodeViewManager.get(codeView.getViewId());

            if isempty(instance)
                instance=coder.internal.mlfb.gui.CodeViewManager(codeView);
                coder.internal.mlfb.gui.CodeViewManager.addInstance(instance);

                try
                    callback=coder.internal.mlfb.gui.CodeViewManager.debuggingCallback();
                    if~isempty(callback)
                        callback(instance);
                    end
                catch me
                    coder.internal.gui.asyncDebugPrint(me);
                end
            end
        end

        function clear()
            instances=coder.internal.mlfb.gui.CodeViewManager.getInstanceMap();
            instances.remove(instances.keys());
        end

        function instance=getActiveCodeView()
            map=coder.internal.mlfb.gui.CodeViewManager.getInstanceMap();
            keys=map.keys();

            if~isempty(keys)
                instance=map(keys{end});
            else
                instance=[];
            end
        end

        function instance=get(viewId)
            map=coder.internal.mlfb.gui.CodeViewManager.getInstanceMap();
            if map.isKey(viewId)
                instance=map(viewId);
            else
                instance=[];
            end
        end

        function varargout=debuggingCallback(callback)
            persistent debuggingCallback;
            if nargin>0
                debuggingCallback=callback;
                varargout={};
            else
                varargout={debuggingCallback};
            end
        end
    end

    methods(Static,Access=private)
        function map=getInstanceMap()
            mlock;
            persistent instances;

            if isempty(instances)
                instances=containers.Map('KeyType','double','ValueType','any');
            end

            map=instances;
        end

        function addInstance(instance)
            instances=coder.internal.mlfb.gui.CodeViewManager.getInstanceMap();
            instances(instance.ViewId)=instance;%#ok<NASGU>
        end

        function removeInstance(instance)
            instances=coder.internal.mlfb.gui.CodeViewManager.getInstanceMap();
            instances.remove(instance.ViewId);
        end

        function match=checkMessageType(message,messageType)
            assert(isstruct(message));
            match=strcmp(message.data.type,messageType);
        end

        function messageService=registerMessagingTypeAdapters(messageService)
            assert(isa(messageService,'coder.internal.gui.MessageService'));
            messageService.withTypeAdapter(@(blockId)blockId.toJava(),'coder.internal.mlfb.BlockIdentifier');
            messageService.withTypeAdapter(@coder.internal.mlfb.idForBlock,'com.mathworks.toolbox.coder.mlfb.BlockId');
        end
    end
end
