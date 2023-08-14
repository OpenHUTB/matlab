classdef WebTypeView<codergui.internal.type.TypeView




    properties(Hidden,Constant)
        IdPrefix='webTypeEditor'

        STANDALONE_PAGE='toolbox/coder/coder/web/typeDialog'
        ENABLEDNESS_CHANGED='enabled'
        STATE_UPDATED='uiStateUpdate'
        MODEL_CHANGED='modelChange'
        SELECT_NODE_TO_EDIT_SIGNAL='selectNodeToEdit'
        STOP_SIGNAL='cancel'
        GET_WORKSPACE_VARS_REQUEST='getWorkspace/request'
        GET_WORKSPACE_VARS_RESPONSE='getWorkspace/reply'
        TYPE_EDITOR_REQUEST='customTypeEditor/request'
        TYPE_EDITOR_RESPONSE='customTypeEditor/reply'
        ATTR_EDITOR_REQUEST='customAttrEditor/request'
        ATTR_EDITOR_RESPONSE='customAttrEditor/reply'
        EDIT_REQUEST='edit/request'
        EDIT_RESPONSE='edit/reply'
        STATE_REQUEST='getState/request'
        STATE_RESPONSE='getState/reply'
    end

    properties(Dependent,SetAccess=private)
Showing
    end

    properties(SetAccess=private,SetObservable)
        Busy=false
    end

    properties(SetAccess=private)
        Ready=false
TypeMaker
    end

    properties(Transient)
        HoldUpdates=false
    end

    properties(Hidden,SetAccess=immutable,Transient)
WebClient
    end

    properties(SetAccess=immutable)
IsEmbedded
ReadOnly
    end

    properties(Dependent,SetAccess=immutable)
ChannelRoot
    end

    properties(GetAccess=private,SetAccess=immutable,Transient)
ByExampleHandler
    end

    properties(Access=private,Transient)
MessagingHelper
        Suppress=false
        PendingUpdates={}
    end

    methods
        function this=WebTypeView(existingClient,varargin)
            ip=inputParser();
            ip.KeepUnmatched=true;
            ip.addRequired('ExistingClient',@(v)isempty(v)||isa(v,'codergui.WebClient'));
            ip.addParameter('Page',this.STANDALONE_PAGE,@ischar);
            ip.addParameter('ReadOnly',false,@islogical);
            ip.addParameter('ByExampleHandler',@this.byExample,@(v)isempty(v)||isa(v,'function_handle'));
            ip.addParameter('UseMinifiedRtc',coder.internal.gui.globalconfig('WebDebugMode'),@islogical);
            ip.addParameter('CloseHandler',[],@(v)isempty(v)||isa(v,'function_handle'));
            ip.parse(existingClient,varargin{:});

            if~isempty(ip.Results.ExistingClient)
                this.WebClient=ip.Results.ExistingClient;
                this.IsEmbedded=true;
            else
                this.WebClient=codergui.ReportServices.WebClientFactory.run(...
                ip.Results.Page,rmfield(ip.Results,'Page'),...
                'IdPrefix','typeview','RemoteControl',true,...
                'CustomCloseCallback',ip.Results.CloseHandler);
                this.WebClient.WindowSize=[900,760];
                if ip.Results.UseMinifiedRtc
                    this.WebClient.ClientParams.minrtc=getDebugRtcArch();
                end
                this.IsEmbedded=false;
            end
            this.ReadOnly=ip.Results.ReadOnly;
            this.ByExampleHandler=ip.Results.ByExampleHandler;
        end


        function start(this)
            this.Ready=true;
            this.addlistener('Enabled','PostSet',@(~,~)this.pushViewState());
            this.setupMessaging();
            if~this.IsEmbedded
                this.show();
            end
            this.pushViewState();
            this.pushStateUpdate('model',this.getModelState());
        end


        function show(this)
            this.WebClient.show();
        end


        function hide(this)
            this.WebClient.hide();
        end


        function focus(this)
            this.WebClient.bringToFront();
        end

        function stopEditing(this,cancel)
            this.MessagingHelper.publish(this.STOP_SIGNAL,cancel);
        end

        function delete(this)
            if~isempty(this.MessagingHelper)
                this.MessagingHelper.delete();
            end


            if~this.IsEmbedded&&~this.WebClient.Disposed
                this.WebClient.delete();
            end
        end

        function showing=get.Showing(this)
            showing=this.WebClient.isVisible();
        end

        function set.HoldUpdates(this,hold)
            if hold==this.HoldUpdates
                return;
            end
            this.HoldUpdates=hold;
            if~hold
                this.flushUpdates();
            end
        end

        function setBusy(this,busy)
            this.Busy=busy;
        end

        function root=get.ChannelRoot(this)
            root=this.MessagingHelper.AbsoluteChannelRoot;
        end

        function editType(this,typeNode)
            this.MessagingHelper.prefixPublish(this.SELECT_NODE_TO_EDIT_SIGNAL,typeNode.Id);
        end
    end

    methods(Hidden)
        function results=applyTypeEdits(this,edits)
            if~iscell(edits)
                edits=num2cell(edits);
            end
            typeMaker=this.TypeMaker;
            newTransaction=~typeMaker.IsPending;
            if newTransaction
                typeMaker.begin();
            end
            prevNode=[];
            results=repmat({struct()},1,numel(edits));

            for i=1:numel(edits)
                edit=edits{i};
                if isfield(edit,'node')&&~isempty(edit.node)
                    node=typeMaker.getNodes(edit.node);
                    prevNode=node;
                else
                    node=prevNode;
                end
                if isempty(node)
                    typeMaker.rollback();
                    codergui.internal.util.throwInternal('Node not resolved for edit #%d',i);
                end

                switch edit.editType
                case 'addChild'
                    child=node.append(1);
                    if isfield(edit,'address')&&~isempty(edit.address)
                        child.Address=edit.address;
                    end
                    if isfield(edit,'fromNode')&&~isempty(edit.fromNode)
                        fromNode=typeMaker.getNodes(edit.fromNode);
                        child.setCoderType(fromNode.getCoderType());
                    end
                    prevNode=child;
                    results{i}.child=child.Id;
                case 'removeChildren'
                    if isfield(edit,'removal')
                        node.remove(edit.removal+1);
                    else
                        node.clearChildren();
                    end
                case 'set'
                    attrDef=node.attr(edit.key).Definition;
                    value=attrDef.ValueType.fromDecodedJson(edit.value);
                    if isfield(edit,'property')
                        node.set(edit.key,edit.property,value);
                    else
                        node.set(edit.key,value);
                    end
                case 'byExample'
                    feval(this.ByExampleHandler,node,edit.code);
                case 'toConstant'
                    node.asConstant();
                case 'toOutputRef'
                    node.Class='coder.OutputType';
                case 'applyType'
                    fromNode=typeMaker.getNodes(edit.fromNode);
                    if isfield(edit,'key')&&~isempty(edit.key)
                        node.set(edit.key,fromNode.get(edit.key));
                    else
                        node.setCoderType(fromNode.getCoderType());
                    end
                case 'move'
                    child=typeMaker.getNodes(edit.childId);
                    child.Parent.moveChild(child,edit.index);
                otherwise
                    codergui.internal.util.throwInternal('Unrecognized edit type "%s"',edit.editType);
                end
            end

            if newTransaction
                typeMaker.finish();
            end
        end
    end

    methods(Access={?codergui.internal.type.TypeView,?codergui.internal.type.TypeApplet})
        function applyModel(this,typeMaker)
            this.TypeMaker=typeMaker;
            if this.Ready
                this.pushStateUpdate('model',this.getModelState());
            end
        end

        function applyModelChanges(this,changeEvent)
            if this.Ready
                this.MessagingHelper.prefixPublish(this.MODEL_CHANGED,prepareTypeModelForJson(changeEvent));
            end
        end
    end

    methods(Access=private)
        function setupMessaging(this)
            this.MessagingHelper=codergui.internal.MessagingHelper(...
            'WebClient',this.WebClient,'BindTo',this,'ChannelPrefix',['type/',this.ViewId]);
            this.MessagingHelper.multiMap({...
            'generic',this.TYPE_EDITOR_REQUEST,this.TYPE_EDITOR_RESPONSE,@this.startExternalEditor;...
            'generic',this.ATTR_EDITOR_REQUEST,this.ATTR_EDITOR_RESPONSE,@this.startExternalEditor;...
            'output',this.EDIT_REQUEST,this.EDIT_RESPONSE,@this.handleTypeEdit;...
            'output',this.STATE_REQUEST,this.STATE_RESPONSE,@this.handleStateRequest;...
            'output',this.GET_WORKSPACE_VARS_REQUEST,this.GET_WORKSPACE_VARS_RESPONSE,@this.sendWorkspaceVariables;...
            });
            this.MessagingHelper.attach();
        end

        function pushStateUpdate(this,varargin)
            if~this.Suppress
                this.flushUpdates(varargin);
            end
        end

        function pushViewState(this)
            this.pushStateUpdate('busy',this.Busy,'enabled',this.Enabled);
        end

        function flushUpdates(this,update)
            if this.HoldUpdates
                if nargin>1
                    this.PendingUpdates{end+1}=update;
                end
                return;
            end
            updates=this.PendingUpdates;
            if nargin>1
                updates{end+1}=update;
            end
            this.PendingUpdates={};

            for i=1:numel(updates)
                next=updates{i};
                this.MessagingHelper.prefixPublish(this.STATE_UPDATED,cell2struct(next(2:2:end),next(1:2:end),2));
            end
        end

        function state=getModelState(this)
            if isempty(this.TypeMaker)
                state=[];
                return
            end
            state=prepareTypeModelForJson(this.TypeMaker);

        end

        function node=startExternalEditor(this,msg)
            node=this.TypeMaker.getNodes(msg.nodeId);
            if~isempty(node)
                this.Suppress=true;
                cleanup=onCleanup(@this.clearSuppression);
                if isfield(msg,'attribute')
                    customEditor=this.owner.editTypeAttribute(node,msg.attribute);
                else
                    customEditor=this.Owner.editType(node);
                end
                if~isempty(customEditor)
                    customEditor.addlistener('ObjectBeingDestroyed',@(~,~)this.clearBusyFlag());
                    this.Busy=true;
                end
                cleanup=[];%#ok<NASGU>
                this.pushViewState();
            else
                error('Not a valid node ID: %d',msg.nodeId);
            end
        end

        function response=handleTypeEdit(this,msg)
            if this.ReadOnly
                error('WebTypeView is in read-only mode');
            end
            this.applyTypeEdits(msg.edits);
            response.success=true;
        end

        function state=handleStateRequest(this,msg)
            stateType=validatestring(msg.stateType,{'model','view','all'});
            if stateType~="view"
                modelState=this.getModelState();
                state.model=modelState.model;
            end
            if stateType~="model"
                state.view=struct('busy',this.Busy,'enabled',this.Enabled);
            end
        end

        function vars=sendWorkspaceVariables(~)
            vars=whos();
            vars=struct('name',{vars.name},'size',{vars.size},'class',{var.class});
        end

        function clearBusyFlag(this)
            this.Busy=false;
        end

        function clearSuppression(this)
            this.Suppress=false;
        end
    end

    methods(Static,Access=private)
        function byExample(node,code)
            coderType=evalin('base',code);
            if~isa(coderType,'coder.Type')
                coderType=coder.typeof(coderType);
            end
            node.setCoderType(coderType);
        end
    end
end


function layerArch=getDebugRtcArch()
    if ispc()
        arches={'win64','glnxa64','maci64'};
    elseif ismac()
        arches={'maci64','glnxa64','win64'};
    else
        arches={'glnxa64','win64','maci64'};
    end
    layerArch='';
    for i=1:numel(arches)
        if isfolder(fullfile(matlabroot(),sprintf('derived/%s/toolbox/coder/coderapp/types/web/codertypedialog',arches{i})))
            layerArch=arches{i};
            break
        end
    end
end
