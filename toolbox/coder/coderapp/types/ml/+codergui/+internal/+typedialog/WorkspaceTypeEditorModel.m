

classdef(Sealed)WorkspaceTypeEditorModel<handle
    properties(Constant,Hidden)
        INVALID_TIMESTAMP_CODE=-1
    end

    properties(Constant,Access=private)
        REF_TABLE_ID=1
        MAP_FILES={'coder/helptargets.map','fixedpoint/fixedpoint.map'}
    end

    properties(SetAccess=immutable)
        TypeMaker codergui.internal.type.TypeMaker
        StateTracker coderapp.internal.undo.StateTracker
    end

    properties(SetAccess=private,SetObservable)
        WorkspaceEntities=codergui.internal.typedialog.WorkspaceEntity.empty()
        TypeCode=struct('node',{},'code',{},'codeMap',{})
        DirtyNodeIds=[]
        CanCreateEntities logical=false
        Locked logical=false
        CanUndo logical=false
        CanRedo logical=false
        Started logical=false
    end

    properties(SetAccess=private)
        TypeCodeChanges struct
    end

    properties(SetAccess=immutable,GetAccess=private)
WorkspaceStrategy
    end

    properties(Access=private)
        WorkspaceTimestamp double=0
PendingWorkspaceUpdate
        Lock double=0
        TaskQueue=struct('func',{},'args',{},'promise',{},'resolve',{},'reject',{})
        EntityCounter=uint32(0)
        SuppressWorkspaceEvent=false
        ForceCheckValues=false
        Handles={}
        HandlingChangeEvent=false
        TypeObjectCache containers.Map
        IsProcessingReferences=false
    end

    properties(Dependent,SetAccess=immutable)
TypeRoots
    end

    methods
        function this=WorkspaceTypeEditorModel(varargin)
            persistent ip;
            if isempty(ip)
                ip=inputParser();
                ip.addParameter('MetaTypeSchema',[],@(v)isa(v,'codergui.internal.type.MetaTypeSchema'));
                ip.addParameter('TypeMaker',[],@(v)isa(v,'codergui.internal.type.TypeMaker'));
                ip.addParameter('WorkspaceStrategy',[],@(v)isa(v,'codergui.internal.typedialog.WorkspaceStrategy'));
                ip.addParameter('AutoStart',true,@islogical);
            end
            ip.parse(varargin{:});
            if~isempty(ip.Results.MetaTypeSchema)&&~isempty(ip.Results.TypeMaker)
                error('Only one of MetaTypeSchema and TypeMaker parameters may be used at a time');
            end

            this.StateTracker=coderapp.internal.undo.StateTracker();
            this.TypeObjectCache=containers.Map('KeyType','uint32','ValueType','any');

            if~isempty(ip.Results.TypeMaker)
                this.TypeMaker=ip.Results.TypeMaker;
                this.TypeMaker.StateTracker=this.StateTracker;
                this.initializeToTypeMaker();
            else
                this.TypeMaker=codergui.internal.type.TypeMaker(ip.Results.MetaTypeSchema,...
                'StateTracker',this.StateTracker);
            end
            if isempty(ip.Results.WorkspaceStrategy)
                this.WorkspaceStrategy=codergui.internal.typedialog.RealWorkspaceStrategy();
            else
                this.WorkspaceStrategy=ip.Results.WorkspaceStrategy;
            end

            if ip.Results.AutoStart
                this.start();
            end
        end

        function start(this)
            if this.Started
                return
            end
            this.Started=true;
            this.Handles{end+1}=listener(this.WorkspaceStrategy,'WorkspaceChanged',...
            @this.handleWorkspaceEvent);
            this.Handles{end+1}=listener(this.TypeMaker,'ModelChanged',...
            @(~,evt)this.applyTypeMakerChanges(evt));
            this.Handles{end+1}=listener(this.StateTracker,'StateChanged',...
            @(~,evt)this.updateUndoRedoState());
            this.updateWorkspace();
        end

        function promise=updateWorkspace(this)
            promise=this.runWithLock('doUpdateWorkspace',this);
        end

        function promise=newType(this,typeVarName,example,exampleType)
            narginchk(2,intmax);
            if nargin>1&&~isempty(typeVarName)
                validateVariableName(typeVarName);
            else
                typeVarName='';
            end
            if nargin<4
                exampleType='value';
                if nargin<3
                    example=coder.typeof(0);
                end
            else
                exampleType=validatestring(exampleType,{'expression','variable','value'});
            end
            promise=this.runWithLock('doNewType',this,typeVarName,example,exampleType);
        end

        function promise=cloneType(this,typeVarName,nodeId)
            promise=this.runWithLock('doCloneType',this,typeVarName,nodeId);
        end

        function promise=newChildFrom(this,parentId,codeOrNodeId,childName)
            args={parentId,codeOrNodeId};
            if nargin>3
                args{end+1}=childName;
            end
            promise=this.runWithLock('doNewChildFrom',this,args{:});
        end

        function promise=deleteTypes(this,typeRootArg)
            if nargin<2
                typeRootArg={};
            else
                typeRootArg={typeRootArg};
            end
            promise=this.runWithLock('doDeleteTypes',this,typeRootArg{:});
        end

        function promise=promoteFromWorkspace(this,varNames,typeVarNames,constant)
            narginchk(2,4);
            varNames=cellstr(varNames);
            if nargin<3||isempty(typeVarNames)
                typeVarNames={};
            else
                typeVarNames=cellstr(typeVarNames);
                cellfun(@validateVariableName,typeVarNames);
            end
            if nargin<4||isempty(constant)
                constant=false;
            end
            promise=this.runWithLock('doPromoteVariables',this,varNames,typeVarNames,constant);
        end

        function promise=defineNodeByExample(this,nodeId,code)
            promise=this.runWithLock('doDefineNodeByExample',this,nodeId,code);
        end

        function promise=evalInWorkspace(this,code)
            promise=this.runWithLock('readInWorkspace',this.WorkspaceStrategy,code).then(@(r)r.value);
        end

        function promise=modifyTypes(this,modifierFunc,varargin)
            promise=this.runWithLock('doModifyTypes',this,modifierFunc,varargin);
        end

        function promise=setReference(this,sourceNodeIds,refTargetNodeId)
            promise=this.runWithLock('doSetReference',this,sourceNodeIds,refTargetNodeId);
        end

        function promise=flushTypes(this,nodeIds)
            if nargin>1
                args={nodeIds};
            else
                args={};
            end
            promise=this.runWithLock('doFlushTypes',this,args{:});
        end

        function promise=loadTypes(this,nodeIds)
            if nargin>1
                args={nodeIds};
            else
                args={};
            end
            promise=this.runWithLock('doLoadTypes',this,args{:});
        end

        function promise=exportScript(this,file,nodeIds)
            switch nargin
            case 1
                args={''};
            case 2
                args={file};
            otherwise
                args={file,nodeIds};
            end
            promise=this.runWithLock('doExportScript',this,args{:});
        end

        function promise=exportMatFile(this,file,nodeIds)
            if nargin>2
                args={nodeIds};
            else
                args={};
            end
            promise=this.runWithLock('doExportMatFile',this,file,args{:});
        end

        function promise=undo(this,n)
            if nargin>2
                args={n};
            else
                args={};
            end
            promise=this.runWithLock('doUndoRedo',this,true,args{:});
        end

        function promise=redo(this,n)
            if nargin>2
                args={n};
            else
                args={};
            end
            promise=this.runWithLock('doUndoRedo',this,false,args{:});
        end

        function promise=openDocPage(this,anchorId)
            if nargin<2
                anchorId='';
            end
            promise=this.runWithLock('doOpenDocPage',this,anchorId);
        end

        function promise=openTypeReferencePage(this,nodeId)
            promise=this.runWithLock('doOpenTypeReferencePage',this,nodeId);
        end

        function promise=runWithLock(this,task,varargin)
            if~this.Started
                this.start();
            end

            taskDesc.func=task;
            taskDesc.args=varargin;
            [taskDesc.promise,taskDesc.resolve,taskDesc.reject]=codergui.internal.util.Promise.taskless();
            promise=taskDesc.promise;

            if this.Lock==0
                this.execLockedTask(taskDesc);
            else
                this.TaskQueue(end+1)=taskDesc;
            end
        end

        function delete(this)
            this.Handles={};
            this.WorkspaceStrategy.delete();
        end

        function roots=get.TypeRoots(this)
            roots=this.TypeMaker.Roots;
        end
    end

    methods(Access=private)
        function promise=doUpdateWorkspace(this)
            if isempty(this.PendingWorkspaceUpdate)
                [updateTracker.promise,updateTracker.resolve,updateTracker.reject]=...
                codergui.internal.util.Promise.taskless();
                this.PendingWorkspaceUpdate=updateTracker;
                this.WorkspaceStrategy.requestWorkspaceUpdate();
                promise=updateTracker.promise;
            else
                promise=this.PendingWorkspaceUpdate.promise;
            end
        end

        function promise=revalidateWorkspace(this,whosInfo,stack,major)
            validateWhosInfo(whosInfo);
            major=nargin<3||major;
            this.WorkspaceTimestamp=now();

            if~isempty(this.PendingWorkspaceUpdate)
                promise=this.applyWorkspaceChange(whosInfo,stack,major);
            else
                promise=this.runWithLock('applyWorkspaceChange',this,whosInfo,stack,major);
            end
        end

        function promise=applyWorkspaceChange(this,whosInfo,stack,major)
            this.TypeMaker.begin();

            [nextEntities,checkValues,hasAddsOrRemoves]=this.resolveEntities(whosInfo,major);
            if checkValues||this.ForceCheckValues
                this.ForceCheckValues=false;
                promise=this.applyEntityChanges(nextEntities,whosInfo);
                promise=codergui.internal.util.when(promise,'then',@finish,@abort,'alwayspromise');
            else
                promise=codergui.internal.util.when(finish(struct('entities',nextEntities)),'alwayspromise');
            end
            promise=promise.then(@(~)this.flushPendingWorkspaceUpdate(this.WorkspaceEntities,[]),...
            @(err)this.flushPendingWorkspaceUpdate([],err));

            function entities=finish(result)
                entities=result.entities;
                if hasAddsOrRemoves||diffEntityIntersection(this.WorkspaceEntities,entities)
                    sortGrid=[{entities.Name}',reshape(num2cell(entities),[],1)];
                    if~isempty(sortGrid)
                        sortGrid=sortrows(sortGrid,1);
                        this.WorkspaceEntities=reshape([sortGrid{:,2}],[],1);
                    else
                        this.WorkspaceEntities=codergui.internal.typedialog.WorkspaceEntity.empty();
                    end
                end







                definitelyNotStaticWorkspace=all(cellfun('isempty',...
                regexp({stack.name},'^@|\/','once')));
                if definitelyNotStaticWorkspace~=this.CanCreateEntities
                    this.CanCreateEntities=definitelyNotStaticWorkspace;
                end

                this.TypeMaker.finish();
                if isfield(result,'dirtyNodeIds')
                    this.DirtyNodeIds=result.dirtyNodeIds;
                end
            end

            function abort(err)
                this.TypeMaker.cancel();
                codergui.internal.util.throwInternal(err);
            end
        end

        function[entities,needsValueCheck,hasAddsOrRemoves]=resolveEntities(this,bInfos,major)
            aEntities=this.WorkspaceEntities;
            aNames={aEntities.Name};
            bNames={bInfos.name};


            [~,aInterIdx,bInterIdx]=intersect(aNames,bNames);

            [~,aRemoveIdx]=setdiff(aNames,bNames);

            [~,bAddIdx]=setdiff(bNames,aNames);

            if~isempty(aInterIdx)


                aNesting=[aEntities(aInterIdx).WhosInfo];
                aNesting=[aNesting.nesting];
                bNesting=[bInfos(bInterIdx).nesting];
                moveSelect=~strcmp({aNesting.function},{bNesting.function});
                aRemoveIdx=[aRemoveIdx;aInterIdx(moveSelect)];
                bAddIdx=[bAddIdx;bInterIdx(moveSelect)];
            end

            aEntities(aRemoveIdx)=[];
            newInfos=bInfos(bAddIdx);
            entities=[aEntities;this.createEntities(numel(newInfos))];
            needsValueCheck=major||~isempty(newInfos);
            hasAddsOrRemoves=~isempty(aRemoveIdx)||~isempty(newInfos);
        end

        function result=applyEntityChanges(this,entities,varInfos)
            typeSchema=this.TypeMaker.MetaTypeSchema;
            for i=1:numel(entities)
                varInfo=varInfos(i);
                entities(i).Name=varInfo.name;
                entities(i).WhosInfo=rmfield(varInfo,'isBase');
                entities(i).IsBaseWorkspace=varInfo.isBase;
                entities(i).CoderTypeObject=[];
                entities(i).Promotable=~strcmp(varInfo.class,'coder.Constant')&&...
                (entities(i).IsCoderType||~isempty(typeSchema.getMetaType(varInfo.class)));
            end

            entityIsType=[entities.IsCoderType];
            if any(entityIsType)
                result=this.createValidatingPromise(@updateWithValues);
            else
                result.entities=entities;
                result.dirtyNodeIds=this.determineDirtyState(entities);
            end

            function result=updateWithValues(resolve,reject,isValidState)
                checked=entities(entityIsType);
                this.WorkspaceStrategy.readInWorkspace({checked.Name}).then(@useVariableValues);

                function useVariableValues(results)
                    if~isValidState()
                        reject();
                        return
                    end

                    eIndices=find(entityIsType);
                    tempTypeObjects=cell(size(entities));

                    for ii=1:numel(results)
                        if~isempty(results(ii).error)
                            continue
                        end
                        ei=eIndices(ii);
                        resultValue=results(ii).value;

                        if isa(resultValue,'coder.Type')
                            tempTypeObjects{ei}=resultValue;
                            if isCacheableTypeObject(resultValue)
                                entities(ei).CoderTypeObject=resultValue;
                            else
                                tempTypeObjects{ei}=resultValue;
                            end
                        elseif isa(resultValue,'coder.type.Base')
                            entities(ei).CoderTypeObject=resultValue;
                        end
                    end

                    result.entities=entities;
                    result.dirtyNodeIds=this.determineDirtyState(entities,tempTypeObjects);
                    resolve(result);
                end
            end
        end

        function[dirtyNodeIds,ambiguous]=determineDirtyState(this,entities,freshValues)





            hasFreshValues=nargin>2&&~isempty(freshValues);
            ambiguous=false;
            typeRoots=this.TypeRoots;
            typeRootNames={typeRoots.Address};
            isDirty=false(size(typeRoots));

            [~,missIdx]=setdiff(typeRootNames,{entities.Name});
            isDirty(missIdx)=true;
            [~,tAlign,eAlign]=intersect(typeRootNames,{entities.Name});

            for i=1:numel(tAlign)
                tIdx=tAlign(i);
                eIdx=eAlign(i);
                if~entities(eIdx).IsCoderType
                    isDirty(tIdx)=true;
                    continue
                end

                testVal=[];
                if hasFreshValues
                    testVal=freshValues{eIdx};
                end
                if isempty(testVal)
                    testVal=entities(eIdx).CoderTypeObject;
                end

                dirty=false;
                if~isempty(testVal)
                    dirty=~isequal(testVal,this.getCoderTypeForNode(typeRoots(tIdx)));
                elseif~hasFreshValues&&~isempty(entities(eIdx).WhosInfo)
                    info=entities(eIdx).WhosInfo;
                    if~strcmp(info.class,typeRoots(tIdx).Class)
                        dirty=true;
                    else
                        trType=this.getCoderTypeForNode(typeRoots(tIdx));%#ok<NASGU>
                        trTypeInfo=whos('trType');
                        dirty=~isequal(info.size,trTypeInfo.size)||info.bytes~=trTypInfo.bytes;
                        if~dirty
                            ambiguous=true;
                        end
                    end
                end
                isDirty(tIdx)=dirty;
            end

            dirtyNodeIds=[typeRoots(isDirty).Id];
        end

        function promise=doNewType(this,typeVarName,example,exampleType)
            switch exampleType
            case 'expression'
                if~isempty(example)
                    promise=this.WorkspaceStrategy.readInWorkspace(example).then(@processValue);
                else
                    promise=codergui.internal.util.when(coder.typeof(0),'alwayspromise');
                end
            case 'variable'
                if isempty(typeVarName)
                    [~,eIdx]=intersect({this.WorkspaceEntities.Name},typeVarName);
                    if isempty(eIdx)||~this.WorkspaceEntities(eIdx).IsCoderType||...
                        isempty(regexp(example,'((_t|T))ype\d*$','once'))
                        typeVarName=[example,'Type'];
                    else
                        typeVarName=example;
                    end
                end
                promise=this.WorkspaceStrategy.readInWorkspace(example).then(@processValue);
            otherwise
                promise=codergui.internal.util.when(coder.typeof(example),'alwayspromise');
            end
            promise=codergui.internal.util.when(promise,'then',...
            @(v)this.createTypeRoot(typeVarName,true,v),'alwayspromise');

            function type=processValue(result)
                if~isempty(result.error)
                    error(result.error);
                end
                type=result.value;

                if~isa(type,'coder.type.Base')
                    if~isa(type,'coder.Type')
                        type=coder.typeof(type);

                        if~isa(type,'coder.type.Base')
                            type.ValueConstructor=example;
                        end
                    elseif isa(type,'coder.Constant')
                        error(message('coderApp:typeMaker:unsupportedClass',class(type)));
                    end
                end
            end
        end

        function promise=doCloneType(this,typeVarName,nodeId)
            node=this.TypeMaker.getNodes(nodeId);
            if isempty(typeVarName)
                typeVarName=node.Address;
            end
            if~isvarname(typeVarName)
                typeVarName='newType';
            end
            promise=codergui.internal.util.when(...
            this.createTypeRoot(typeVarName,true,node.getCoderType()),'alwayspromise');
        end

        function promise=doNewChildFrom(this,parentId,codeOrNodeId,childAddr)
            if ischar(codeOrNodeId)||isstring(codeOrNodeId)
                promise=this.WorkspaceStrategy.readInWorkspace(codeOrNodeId).then(@afterEval);
            else
                coderType=this.TypeMaker.getNodes(codeOrNodeId).getCoderType();
                promise=codergui.internal.util.when(...
                afterEval(struct('value',coderType,'error',[])),...
                'alwayspromise');
            end

            function result=afterEval(evalResult)
                if~isempty(evalResult.error)
                    error(evalResult.error);
                end
                typeMaker=this.TypeMaker;
                typeMaker.begin();
                child=typeMaker.getNodes(parentId).append();
                if nargin>3&&~isempty(childAddr)
                    child.Address=childAddr;
                end
                child.setCoderType(evalResult.value);
                typeMaker.finish();
                result=child;
            end
        end

        function promise=doPromoteVariables(this,varNames,typeVarNames,~)
            promise=this.WorkspaceStrategy.readInWorkspace(varNames);
            promise=promise.then(@(r)this.finishPromoteVariables(varNames,typeVarNames,r));
        end

        function next=finishPromoteVariables(this,varNames,typeVarNames,readResults)
            if isempty(typeVarNames)
                typeVarNames=repmat({''},size(varNames));
            end

            [~,eIdx,vIdx]=intersect({this.WorkspaceEntities.Name},varNames);
            errIdx=[];
            typeRoots=cell(1,numel(vIdx));
            this.TypeMaker.begin();

            for i=1:numel(vIdx)
                varIdx=vIdx(i);
                readResult=readResults(varIdx);
                entity=this.WorkspaceEntities(eIdx(i));
                if~entity.Promotable||~isempty(readResult.error)
                    errIdx(end+1)=varIdx;%#ok<AGROW>
                    typeRoots{varIdx}=codergui.internal.type.TypeMakerNode.empty();
                    continue
                end

                typeVarName=typeVarNames{varIdx};
                if isempty(typeVarName)
                    uniqify=true;

                    if isa(readResult.value,'coder.type.Base')
                        if~coder.type.Base.isEnabled('GUI')
                            readResult.value=readResult.value.getCoderType();
                        end

                        entity.CoderTypeObject=readResult.value;
                    end

                    if(isa(readResult.value,'coder.Type')...
                        ||isa(readResult.value,'coder.type.Base'))...
                        &&entity.IsCoderType
                        typeVarName=varNames{varIdx};
                        [~,matchIdx]=intersect({this.TypeRoots.Address},typeVarName);
                        if~isempty(matchIdx)
                            matchingTypeRoot=this.TypeRoots(matchIdx);
                            matchingTypeRoot.setCoderType(readResult.value);
                            typeRoots{varIdx}=matchingTypeRoot;
                            continue
                        else
                            uniqify=false;
                        end
                    else
                        typeVarName=[entity.Name,'Type'];
                    end
                else
                    uniqify=false;
                end

                typeVal=readResult.value;

                if coder.type.Base.isEnabled('GUI')
                    if~isa(typeVal,'coder.type.Base')
                        typeVal=coder.type.Base.applyCustomCoderType(typeVal);
                    end
                end

                try
                    typeRoots{varIdx}=this.createTypeRoot(typeVarName,uniqify,typeVal);
                catch me %#ok<NASGU>
                    errIdx(end+1)=varIdx;%#ok<AGROW>
                end
            end

            this.TypeMaker.finish();

            if~isempty(errIdx)
                if isscalar(errIdx)
                    tderror('VariableNotPromotable',varNames{errIdx});
                else
                    tderror('VariablesNotPromotable',strjoin(varNames(errIdx),', '));
                end
            elseif numel(vIdx)~=numel(varNames)
                [~,errIdx]=setdiff(varNames,{this.WorkspaceEntities.Name});
                if isscalar(errIdx)
                    tderror('VariableNotFound',varNames{errIdx});
                else
                    tderror('VariablesNotFound',strjoin(varNames(errIdx),', '));
                end
            end

            next=codergui.internal.util.when([typeRoots{:}],'alwayspromise');
        end

        function promise=doDefineNodeByExample(this,nodeOrId,code)
            if~isa(nodeOrId,'codergui.internal.type.TypeMakerNode')
                typeNode=this.TypeMaker.getNodes(nodeOrId);
            else
                typeNode=nodeOrId;
            end
            promise=this.WorkspaceStrategy.readInWorkspace(code).then(@finishDefineByExample);

            function finishDefineByExample(result)
                if~isempty(result.error)
                    tderror(result.error);
                end
                if isa(result.value,'coder.Type')
                    type=result.value;
                else
                    type=coder.typeof(result.value);
                end
                typeNode.setCoderType(type);
            end
        end

        function result=doDeleteTypes(this,typeRootArg)
            if nargin>1
                if isnumeric(typeRootArg)
                    [~,ri]=intersect([this.TypeRoots.Id],typeRootArg);
                else
                    [~,ri]=intersect({this.TypeRoots.Address},cellstr(typeRootArg));
                end
            else
                ri=1:numel(this.TypeRoots);
            end

            this.TypeMaker.begin();
            arrayfun(@(r)this.TypeMaker.removeRoot(r),this.TypeMaker.Roots(ri));
            this.TypeMaker.finish();
            result=codergui.internal.util.when(true,'alwayspromise');
        end

        function handleWorkspaceEvent(this,~,event)
            if this.SuppressWorkspaceEvent
                return
            end
            this.SuppressWorkspaceEvent=true;
            this.revalidateWorkspace(event.WorkspaceInfo,event.Stack,event.IsMajorChange).finally(...
            @(~)this.cleanupSuppressFlag());
        end

        function applyTypeMakerChanges(this,event)
            assert(this.Locked,...
            'TypeMaker modifications should only occur synchronously within modifyTypes');
            if this.HandlingChangeEvent
                return
            end
            this.HandlingChangeEvent=true;
            flagCleanup=onCleanup(@this.clearHandlingChangeEvent);

            if isempty(event.NodeChanges)&&isempty(event.RootChanges)
                return
            end

            nodes=[event.NodeChanges.node];
            if~isempty(event.RootChanges)
                addedRoots=[event.RootChanges([event.RootChanges.type]==codergui.internal.type.ChangeType.RootAdded).node];
                removedRoots=[event.RootChanges([event.RootChanges.type]==codergui.internal.type.ChangeType.RootRemoved).node];
                nodes=[nodes,addedRoots];
            else
                removedRoots=[];
                addedRoots=[];
            end
            nodes=unique(nodes);
            if isempty(nodes)
                nodes=codergui.internal.type.TypeMakerNode.empty();
            end
            if~isempty(nodes)
                roots=setdiff(unique([nodes.Root]),removedRoots);
            else
                roots=codergui.internal.type.TypeMakerNode.empty();
            end

            if~isempty(roots)||~isempty(removedRoots)
                this.updateTypeToCode(roots,addedRoots,removedRoots);
            end


            rootIds=[roots.Id];
            removedRoots=[event.RootChanges([event.RootChanges.type]==...
            codergui.internal.type.ChangeType.RootRemoved).node];
            if~isempty(removedRoots)
                rootIds=unique([rootIds,removedRoots.Id]);
            end
            rootIds=num2cell(rootIds);
            this.TypeObjectCache.remove(rootIds(this.TypeObjectCache.isKey(rootIds)));


            [dirtyNodeIds,ambiguous]=this.determineDirtyState(this.WorkspaceEntities);
            if ambiguous
                this.doUpdateWorkspace();
            else
                this.DirtyNodeIds=dirtyNodeIds;
            end
        end

        function initializeToTypeMaker(this)
            this.updateTypeToCode(this.TypeMaker.Roots,this.TypeMaker.Roots,[]);
            this.TypeCodeChanges=struct('node',{},'empty',{},'removed',{});
        end

        function typeRoot=createTypeRoot(this,typeName,uniqify,typeVal)


            if~isa(typeVal,'coder.Type')&&~isa(typeVal,'coder.type.Base')
                typeVal=coder.typeof(typeVal);
            end

            if isempty(typeName)
                typeName='newType';
                uniqify=true;
            end
            if uniqify
                nameTokens=regexp(typeName,'^(.*)(((_t)|T)ype)(\d*)$','tokens','once');
                initCount=1;
                if~isempty(nameTokens)
                    if~isempty(nameTokens{3})
                        initCount=str2double(nameTokens{3})+1;
                    elseif~isempty(nameTokens{2})
                        initCount=2;
                    end
                    typeName=[nameTokens{1:2}];
                end
                typeName=deriveUniqueVariableName(typeName,...
                union({this.TypeMaker.Roots.Address},{this.WorkspaceEntities.Name}),initCount);
            end

            wasPending=this.TypeMaker.IsPending;
            this.TypeMaker.begin();

            typeRoot=this.TypeMaker.addRoot();
            typeRoot.setCoderType(typeVal);
            typeRoot.Address=typeName;

            if~wasPending
                this.TypeMaker.finish();
            end
        end

        function clearHandlingChangeEvent(this)
            this.HandlingChangeEvent=false;
        end

        function promise=doFlushTypes(this,rootIds)
            if nargin>1
                rootNodes=this.TypeRoots(ismember([this.TypeRoots.Id],rootIds));
            else
                rootNodes=this.TypeRoots;
            end

            typePromises=cell(1,numel(rootNodes));
            for i=1:numel(rootNodes)
                typeObj=rootNodes(i).getCoderType();
                typePromises{i}=this.WorkspaceStrategy.writeVariable(...
                rootNodes(i).Address,false,typeObj);
            end

            this.SuppressWorkspaceEvent=true;
            promise=codergui.internal.util.Promise.all(typePromises{:}).then(@afterPush);

            function next=afterPush(~)
                this.cleanupSuppressFlag();
                this.ForceCheckValues=true;
                next=this.doUpdateWorkspace();
            end
        end

        function promise=doLoadTypes(this,rootIds)
            entities=this.WorkspaceEntities;
            eNames={entities.Name};
            roots=this.TypeRoots;
            if nargin<2
                rootIds=[roots.Id];
            end
            rNames={roots.Address};

            [~,eCommonIdx,rCommonIdx]=intersect(eNames,rNames(ismember([roots.Id],rootIds)));
            rIsClean=~ismember([roots(rCommonIdx).Id],this.DirtyNodeIds);
            rCommonIdx(rIsClean)=[];
            eCommonIdx(rIsClean)=[];
            roots=roots(rCommonIdx);
            [~,eNewIdx]=setdiff(eNames,rNames);
            eNewIdx(~[entities(eNewIdx).IsCoderType])=[];

            if~isempty(eCommonIdx)||~isempty(eNewIdx)
                promise=this.WorkspaceStrategy.readInWorkspace(eNames([eCommonIdx;eNewIdx])).then(@withBatchedValues);
            else
                promise=codergui.internal.util.when([],'alwayspromise');
            end

            function result=withBatchedValues(results)
                updateVals=results(1:numel(eCommonIdx));
                newVals=results(numel(eCommonIdx)+1:end);

                for i=1:numel(updateVals)
                    if isempty(updateVals(i).error)
                        try
                            roots(i).setCoderType(updateVals(i).value);
                        catch
                        end
                    end
                end
                promoteMask=true(size(newVals));
                for i=1:numel(newVals)
                    if~isempty(newVals(i).error)||(~isa(newVals(i).value,'coder.Type')&&~isa(newVals(i).value,'coder.type.Base'))
                        promoteMask(i)=false;
                    end
                end
                result=codergui.internal.type.TypeMakerNode.empty();
                if any(promoteMask)
                    promotes=eNames(eNewIdx);
                    promotes(~promoteMask)=[];
                    result=this.finishPromoteVariables(promotes,[],newVals(promoteMask)).then(@(nr)[roots,nr]);
                end
            end
        end

        function updateTypeToCode(this,rootNodes,addedRoots,removedRoots)
            nextCode=this.TypeCode;

            if~isempty(removedRoots)
                nextCode(ismember([nextCode.node],[removedRoots.Id]))=[];
            end
            if~isempty(addedRoots)
                addedIds={addedRoots.Id};
                idxRange=numel(nextCode)+1:numel(nextCode)+numel(addedRoots);
                [nextCode(idxRange).node]=addedIds{:};
                tempVal=repmat({''},1,numel(addedRoots));
                [nextCode(idxRange).code]=tempVal{:};
                tempVal=repmat({{}},size(tempVal));
                [nextCode(idxRange).codeMap]=tempVal{:};
            end

            [~,ri]=ismember([rootNodes.Id],[nextCode.node]);
            changeMask=false(1,numel(nextCode));
            changedRanges=repmat(struct('node',{[]},'added',{{}},'removed',{{}}),1,numel(changeMask));

            for i=1:numel(ri)
                [code,codeMap]=rootNodes(i).toCode(rootNodes(i).Address);
                oldCodeContext=nextCode(ri(i));
                changed=isempty(oldCodeContext)||~strcmp(oldCodeContext.code,code);
                if~changed
                    continue
                end
                changeMask(i)=true;

                codeContext.node=rootNodes(i).Id;
                codeContext.code=code;
                codeContext.codeMap=codeMap;
                changedRanges(i).node=rootNodes(i).Id;

                if~isempty(oldCodeContext)
                    [changedRanges(i).added,changedRanges(i).removed]=getNewOrChangedRanges(code,oldCodeContext.code);
                elseif~isempty(code)
                    changedRanges(i).added=struct('start',1,'end',numel(code));
                    changedRanges(i).removed=struct('start',{},'end',{});
                end
                nextCode(ri(i))=codeContext;
            end

            this.TypeCodeChanges=changedRanges(changeMask);
            if~isempty(removedRoots)||any(changeMask)
                this.TypeCode=nextCode;
            end
        end

        function result=doExportMatFile(this,file,nodeIds)
            if nargin>2
                typeRoots=this.TypeRoots(ismember([this.TypeRoots.Id],nodeIds));
            else
                typeRoots=this.TypeRoots;
            end
            types=cell2struct(arrayfun(@(r)r.getCoderType(),typeRoots,'UniformOutput',false),...
            {typeRoots.Address},2);
            save(file,'-struct','types');
            result=which(file);
        end

        function result=doExportScript(this,file,nodeIds)
            if nargin>2
                [~,cIdx]=intersect([this.TypeCode.node],nodeIds);
                sections={this.TypeCode(cIdx).code};
            else
                sections={this.TypeCode.code};
            end
            text=strjoin(sections,repmat(newline,1,2));

            if~isempty(file)
                [~,filename,ext]=fileparts(file);
                if isempty(ext)
                    file=[filename,'.m'];
                end

                fid=fopen(file,'w');
                fprintf(fid,'%s',text);
                fclose(fid);
                result=which(file);
            else
                matlab.desktop.editor.newDocument(text);
                result='';
            end
        end

        function cleanupSuppressFlag(this)
            if isvalid(this)
                this.SuppressWorkspaceEvent=false;
            end
        end

        function cleanupReferenceFlag(this)
            this.IsProcessingReferences=false;
        end

        function promise=createValidatingPromise(this,task)
            timestamp=this.WorkspaceTimestamp;
            promise=codergui.internal.util.Promise(@taskWrapper);

            function taskWrapper(resolve,reject)
                isValidState=@()timestamp==this.WorkspaceTimestamp;
                task(@resolveWrapper,@rejectWrapper,isValidState);

                function resolveWrapper(varargin)
                    if isvalid(this)
                        if~isValidState()
                            reject(this.INVALID_TIMESTAMP_CODE);
                        else
                            resolve(varargin{:});
                        end
                    end
                end

                function rejectWrapper(varargin)
                    if isvalid(this)
                        if~isValidState()
                            reject(this.INVALID_TIMESTAMP_CODE);
                        else
                            reject(varargin{:});
                        end
                    end
                end
            end
        end

        function incrementLock(this)
            this.Lock=this.Lock+1;
            if this.Lock~=0&&~this.Locked
                this.Locked=true;
            end
        end

        function this=decrementLock(this)
            this.Lock=this.Lock-1;
            assert(this.Lock>=0);
            if this.Lock==0&&~isempty(this.TaskQueue)
                task=this.TaskQueue(1);
                this.TaskQueue(1)=[];
                this.execLockedTask(task);
            elseif this.Lock==0
                this.Locked=false;
            end
        end

        function execLockedTask(this,task)
            this.incrementLock();
            task.promise.then(@cleanupAndPassthrough,@cleanup);

            try
                task.resolve(feval(task.func,task.args{:}));
            catch me
                task.reject(me);
            end

            function result=cleanupAndPassthrough(result)
                this.decrementLock();
            end

            function cleanup(err)
                coder.internal.gui.asyncDebugPrint(err);
                this.decrementLock();
            end
        end

        function entities=createEntities(this,n)
            ids=this.EntityCounter+1:this.EntityCounter+n;
            this.EntityCounter=this.EntityCounter+n;
            entities=repmat(codergui.internal.typedialog.WorkspaceEntity(0),n,1);
            for i=1:n
                entities(i)=codergui.internal.typedialog.WorkspaceEntity(ids(i));
            end
        end

        function typeMaker=doModifyTypes(this,task,taskArgs)
            typeMaker=this.TypeMaker;
            typeMaker.begin();
            feval(task,typeMaker,taskArgs{:});
            typeMaker.finish();
        end

        function promise=doOpenTypeReferencePage(this,nodeId)
            type=this.getCoderTypeForNode(this.TypeMaker.getNodes(nodeId));
            if~isempty(type)
                doc(class(type));
                pass=true;
            else
                pass=false;
            end
            promise=codergui.internal.util.when(pass,'alwayspromise');
        end

        function promise=doOpenDocPage(this,anchorId)
            if nargin<2||isempty(anchorId)
                anchorId='help_button_codertypeeditor';
            end
            pass=false;
            curDocRoot=docroot();
            for i=1:numel(this.MAP_FILES)
                mapFile=fullfile(curDocRoot,this.MAP_FILES{i});
                if isfile(mapFile)
                    helpview(mapFile,anchorId);
                    pass=true;
                    break
                end
            end
            promise=codergui.internal.util.when(pass,'alwayspromise');
        end

        function coderType=getCoderTypeForNode(this,node)
            if this.TypeObjectCache.isKey(node.Id)
                coderType=this.TypeObjectCache(node.Id);
            else
                coderType=node.getCoderType();
                if isCacheableTypeObject(coderType)
                    this.TypeObjectCache(node.Id)=coderType;
                end
            end
        end

        function entities=flushPendingWorkspaceUpdate(this,entities,err)
            if isempty(this.PendingWorkspaceUpdate)
                return
            end
            updateTracker=this.PendingWorkspaceUpdate;
            this.PendingWorkspaceUpdate=[];
            if isempty(err)
                updateTracker.resolve(entities);
            else
                updateTracker.reject(err);
                codergui.internal.util.throwInternal(err);
            end
        end

        function promise=updateAndRetrieve(this,name)
            promise=this.doUpdateWorkspace().then(@(~)this.WorkspaceEntities(strcmp({this.WorkspaceEntities.Name},name)));
        end

        function result=doUndoRedo(this,isUndo,count)
            tracker=this.StateTracker;
            if nargin<3||isempty(count)
                count=1;
            end
            if isUndo
                tracker.previous(count);
            else
                tracker.next(count);
            end
            result=[];
        end

        function updateUndoRedoState(this)
            this.CanUndo=this.StateTracker.HasPrevious;
            this.CanRedo=this.StateTracker.HasNext;
        end
    end
end


function[added,deleted]=getNewOrChangedRanges(new,old)
    [oldAlign,newAlign]=codergui.internal.util.alignMatlabCode(old,new,'IgnoreLiteralValues',false);
    ocTree=oldAlign.setIX(~oldAlign.getIX());
    deleted=cell2struct(num2cell([ocTree.lefttreepos(),ocTree.righttreepos()]),{'start','end'},2);
    ncTree=newAlign.setIX(~newAlign.getIX());
    added=cell2struct(num2cell([ncTree.lefttreepos(),ncTree.righttreepos()]),{'start','end'},2);
end


function validateVariableName(varName)
    if~isvarname(varName)
        tderror('InvalidVariableName',varName);
    end
end


function validateWhosInfo(whosInfo)
    if~all(ismember({
        'name','size','bytes','class','global','sparse',...
        'complex','nesting','persistent'},fieldnames(whosInfo)))
        codergui.internal.util.throwInternal('whosInfo argument should be a valid "whos" output struct');
    end
    if~isfield(whosInfo,'isBase')
        codergui.internal.util.throwInternal('whosInfo argument should have an extra "isBase" field');
    end
end


function cacheable=isCacheableTypeObject(typeObj)
    persistent whichBuiltInSuffix;

    if builtin('isa',typeObj,'coder.Constant')
        if builtin('isa',typeObj.Value,'embedded.fi')||builtin('isa',typeObj.Value,'gpuArray')
            cacheable=true;
        elseif builtin('isobject',typeObj.Value)
            if isempty(whichBuiltInSuffix)
                whichBuiltInSuffix=message(...
                'MATLAB:ClassText:whichBuiltinMethod','').getString();
            end

            classDefPath=which(builtin('class',typeObj.Value));
            cacheable=endsWith(classDefPath,whichBuiltInSuffix)||...
            startsWith(classDefPath,matlabroot());
        else
            cacheable=true;
        end
        if cacheable
            constantValue=typeObj.Value;%#ok<NASGU>
            valueInfo=whos('constantValue');
            cacheable=valueInfo.bytes/1e6<20;
        end
    else
        cacheable=true;
    end
end


function different=diffEntityIntersection(a,b)
    [~,aIdx,bIdx]=intersect([a.EntityId],[b.EntityId]);
    different=false;
    for i=1:numel(aIdx)
        if~isequal(a(aIdx(i)),b(bIdx(i)))
            different=true;
            break
        end
    end
end