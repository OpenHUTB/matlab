classdef(Sealed)TypeApplet<codergui.internal.type.TypeView





    properties(Constant,Hidden)
        IdPrefix='typeApplet'
    end

    properties(Dependent)
MetaTypeSchema
    end

    properties(Dependent,SetAccess=immutable)
CustomEditTypes
CustomEditAttributes
    end

    properties(Dependent,SetAccess=private,SetObservable)
Showing
Ready
Busy
    end

    properties
        Model codergui.internal.type.TypeMaker
    end

    properties(SetAccess=immutable)
        StateTracker coderapp.internal.undo.StateTracker
    end

    properties(SetAccess=private)
        Views codergui.internal.type.TypeView=codergui.internal.type.TypeView.empty()
    end

    properties(GetAccess=private,SetAccess=immutable)
CustomTypeEditorFactories
CustomAttributeEditorFactories
    end

    properties(Access=private)
ModelListener
        ViewListeners={}
        Started=false
        Frozen=false
        IdCounter=0
        BusyDisabled=false
        UserEnabled=true
CustomTypeEdit
CustomAttributeEdit
    end

    methods
        function this=TypeApplet(varargin)
            ip=inputParser();
            ip.addParameter('MetaTypeSchema',[],@(v)isa(v,'codergui.internal.type.MetaTypeSchema'));
            ip.addParameter('StateTracker',[],@(v)isa(v,'coderapp.internal.undo.StateTracker'));
            ip.addParameter('AttributeEditorFactories',{},@validateAttributeEditorFactories);
            ip.addParameter('TypeEditorFactories',{},@validateTypeEditorFactories);
            ip.addParameter('Views',[],@(v)isa(v,'codergui.internal.type.TypeView'));
            ip.parse(varargin{:});
            opts=ip.Results;

            if isempty(opts.StateTracker)
                this.StateTracker=coderapp.internal.undo.StateTracker();
            else
                this.StateTracker=opts.StateTracker;
            end
            if~isempty(opts.MetaTypeSchema)
                this.MetaTypeSchema=opts.MetaTypeSchema;
            end
            if~isempty(ip.Results.TypeEditorFactories)
                this.CustomTypeEditorFactories=processTypeEditorFactorySpecs(ip.Results.TypeEditorFactories);
            end
            if~isempty(ip.Results.AttributeEditorFactories)
                this.CustomAttributeEditorFactories=processAttributeEditorFactorySpecs(ip.Results.AttributeEditorFactories);
            end

            this.ViewId='';

            if~isempty(opts.Views)
                arrayfun(@this.addView,opts.Views);
            end
        end

        function addView(this,view)
            assert(view~=this);
            if~isempty(view.Owner)
                if view.Owner~=this
                    error('Cannot add owned view');
                end
                return;
            elseif isa(view,class(this))
                error('TypeApplet should only be used as a root TypeView');
            end

            this.Views(end+1)=view;
            this.ViewListeners{end+1}={...
            view.listener('Busy','PostSet',@(~,~)this.updateEnabledStatus())...
            ,view.listener('ObjectBeingDestroyed',@(~,~)this.removeView(view))...
            };
            view.Owner=this;
            this.IdCounter=this.IdCounter+1;
            view.ViewId=sprintf('%s%d',view.IdPrefix,this.IdCounter);

            if this.Started
                this.startViews(view);
            end
        end

        function removeView(this,view)
            filter=arrayfun(@(v)v==view,this.Views);

            if any(filter)
                this.Views(filter)=[];
                this.ViewListeners(filter)=[];
                if~isempty(this.CustomTypeEdit)&&view==this.CustomTypeEdit.view
                    view.stopEditing(true);
                    this.CustomTypEdit=[];
                    if~isempty(this.CustomAttributeEdit)
                        this.removeView(this.CustomAttributeEdit.view);
                    end
                elseif~isempty(this.CustomAttributeEdit)&&view==this.CustomAttributeEdit.view
                    view.stopEditing(true);
                    this.CustomAttributeEdit=[];
                end
                view.delete();
            end
        end

        function start(this)
            if this.Started
                return;
            end
            this.startViews(this.Views);
            this.Started=true;
        end

        function delete(this)
            this.stopEditing(true);
            arrayfun(@this.removeView,this.Views);
            this.Model=codergui.internal.type.TypeMaker.empty();
        end

        function show(this)
            this.start(this);
            hiddenViews=this.Views(~[this.Views.Showing]);
            for i=1:numel(hiddenViews)
                hiddenViews(i).show();
            end
            if~codergui.internal.util.poll(@()all([hiddenViews.Showing]),'Timeout',300)
                error('Timeout during display of type applet views');
            end
        end

        function hide(this)
            if~this.Started
                return;
            end
            openViews=this.Views([this.Views.Showing]);
            for i=1:numel(openViews)
                openViews(i).hide();
            end
            if~codergui.internal.util.poll(@()all(~[openViews.Showing]),'Timeout',120)
                error('Timeout during closing of type applet views');
            end
        end

        function focus(this)
            this.show();
            openViews=this.Views([this.Views.Showing]);
            for i=1:numel(openViews)
                openViews(i).focus();
            end
        end

        function open=get.Showing(this)
            open=any([this.Views.Showing]);
        end

        function ready=get.Ready(this)
            ready=all([this.Views.Ready]);
        end

        function busy=get.Busy(this)
            busy=any([this.Views.Busy]);
        end

        function schema=get.MetaTypeSchema(this)
            model=this.Model;
            if~isempty(model)
                schema=model.MetaTypeSchema;
            else
                schema=codergui.internal.type.MetaTypeSchema.empty();
            end
        end

        function set.MetaTypeSchema(this,schema)
            this.Model=codergui.internal.type.TypeMaker(schema,this.StateTracker);
        end

        function set.Model(this,typeMaker)
            if~isempty(typeMaker)
                validateattributes(typeMaker,{'codergui.internal.type.TypeMaker'},{'scalar'});
            else
                typeMaker=codergui.internal.type.TypeMaker.empty();
            end
            this.Model=typeMaker;
            this.swapModel(typeMaker);
        end

        function ids=get.CustomEditTypes(this)
            ids=unique(this.CustomTypeEditorFactories(:,1));
        end

        function idPairs=get.CustomEditAttributes(this)
            idPairs=this.CustomAttributeEdit(:,1:2);
        end

        function setEnabled(this,enabled)
            this.UserEnabled=enabled;
            this.updateEnabledStatus();
        end

        function customEditor=editType(this,typeNode)
            if~isequal(this.Model,typeNode.TypeMaker)
                error('Type node must be owned by this applet''s model');
            elseif this.Model.IsPending
                error('This method should only be invoked when the model is in a committed state');
            end
            this.start();

            if~isempty(this.CustomTypeEdit)
                if this.CustomTypeEdit.typeNode==typeNode
                    customEditor=this.CustomTypeEdit.view;
                    customEditor.focus();
                    return
                else
                    this.disposeTargetedEditors();
                end
            end

            customEditor=this.getCustomTypeEditor();
            if~isempty(customEditor)
                this.CustomTypeEdit=struct('typeNode',typeNode,'view',customEditor);
                customEditor.editType(typeNode);
            else
                for view=this.Views
                    view.editType(typeNode);
                end
            end
        end

        function customEditor=editTypeAttribute(this,typeNode,attribute)
            if nargin<3&&isa(typeNode,'codergui.internal.type.Attribute')
                attribute=typeNode;
                typeNode=attribute.Node;
            elseif isa(attribute,'codergui.internal.type.Attribute')&&typeNode~=attribute.Node
                error('Attribute not owned by the specified node');
            else
                attribute=typeNode.attr(attribute);
            end
            this.editType(typeNode);

            if~isempty(this.CustomAttributeEdit)
                if this.CustomAttributeEdit.attribute==attribute
                    customEditor=this.CustomAttributeEdit.view;
                    customEditor.focus();
                    return
                else
                    this.CustomAttributeEdit.view.stopEditing(true);
                    this.CustomAttributeEdit.view.delete();
                    this.CustomAttributeEdit=[];
                end
            end

            customEditor=this.getCustomAttributeEditor(attribute);
            if~isempty(customEditor)
                this.CustomAttributeEdit=struct('typeNode',typeNode,'attribute',attribute,'view',customEditor);
                customEditor.editTypeAttribute(typeNode,attribute);
            else
                for view=this.Views
                    view.editTypeAttribute(typeNode);
                end
            end
        end

        function stopEditing(this,cancel)
            this.disposeTargetedEditors();
            for view=this.Views
                view.stopEditing(cancel);
            end
        end
    end

    methods(Access=private)
        function swapModel(this,model)
            this.ModelListener=[];
            if~isempty(model)
                this.ModelListener=model.listener('ModelChanged',@(~,evt)this.applyModelChanges(evt));
            end
            if this.Started
                this.applyModel(model);
            end
        end

        function updateEnabledStatus(this)
            views=this.Views;
            enabled=this.UserEnabled&&this.Busy;
            for i=1:numel(views)
                view=views(i);
                if enabled~=view.Enabled
                    view.Enabled=enabled;
                end
            end
            if enabled~=this.Enabled
                this.Enabled=enabled;
            end
        end

        function clearFrozen(this)
            this.Frozen=false;
        end

        function startViews(this,views)
            for i=1:numel(views)
                views(i).applyModel(this.Model);
                views(i).start();
            end
            if~codergui.internal.util.poll(@()this.Ready,'Timeout',120)
                error('Timeout during startup of type views.');
            end
            this.updateEnabledStatus();
        end

        function typeEditor=getCustomTypeEditor(this,typeNode)
            typeEditor=[];
            if isempty(this.CustomTypeEditorFactories)||isempty(typeNode.MetaType)
                return;
            end

            factories=this.CustomTypeEditorFactories;
            factories=factories(strcmp(factories(:,1),typeNode.MetaType.Id),2);

            for i=1:numel(factories)
                typeEditor=feval(factories{i},typeNode);
                if~isempty(typeEditor)&&this.handleCustomEditorFactoryOutput(typeEditor)
                    break;
                end
            end
        end

        function attrEditor=getCustomAttributeEditor(this,attr)
            factories=this.CustomAttributeEditorFactories;

            factories=factories(strlength(factories(:,1))==0|strcmp(factories(:,1),attr.Node.MetaType),3);

            factories=factories(strcmp(factories,attr.Key));

            attrEditor=[];
            for i=1:numel(factories)
                attrEditor=feval(factories{i},attr);
                if~isempty(attrEditor)&&this.handleCustomEditorFactoryOutput(attrEditor)
                    break;
                end
            end
        end

        function success=handleCustomEditorFactoryOutput(this,typeEditor)
            if isa(typeEditor,'codergui.internal.type.TypeView')&&isscalar(typeEditor)
                this.addView(typeEditor);
                success=true;
            else
                warning('Type and attribute editor factories should only return scalar TypeView objects');
                success=false;
            end
        end

        function disposeTargetedEditors(this)
            if~isempty(this.CustomTypeEdit)
                this.removeView(this.CustomTypeEdit.view);
            end
        end
    end

    methods(Access={?codergui.internal.type.TypeView,?codergui.internal.type.TypeApplet})
        function applyModel(this,model)
            for i=1:numel(this.Views)
                this.Views(i).applyModel(model);
            end
        end

        function applyModelChanges(this,changeEvent)
            if this.Frozen
                error('Model should not be modified during synchronous processing of prior changes');
            end
            cleanup=onCleanup(@this.clearFrozen);
            this.Frozen=true;
            for i=1:numel(this.Views)
                this.Views(i).applyModelChanges(changeEvent);
            end
        end
    end
end


function valid=validateAttributeEditorFactories(value)
    if~isempty(value)
        validateattributes(value,{'cell'},{'ncols',3});
    end
    valid=true;
end


function valid=validateTypeEditorFactories(value)
    if~isempty(value)
        validateattributes(value,{'cell'},{'ncols',2});
        assert(iscellstr(value(:,1:2)));%#ok<ISCLSTR>
    end
    valid=true;
end


function typeEditorFactories=processTypeEditorFactorySpecs(typeEditorFactories)
    for i=1:size(typeEditorFactories,1)
        if isa(typeEditorFactories{i,1},'codergui.internal.type.MetaType')
            typeEditorFactories{i,1}=typeEditorFactories{i,1}.Id;
        else
            typeEditorFactories{i,1}=strtrim(typeEditorFactories{i,1});
        end
    end
end


function attrEditorFactories=processAttributeEditorFactorySpecs(raw)
    attrEditorFactories=[processTypeEditorFactorySpecs(raw(:,1:2)),raw(:,3)];
    for i=1:size(raw,1)
        rawVal=raw{i,3};
        if isa(rawVal,'codergui.internal.type.Attribute')||isa(rawVal,'codergui.internal.type.AttributeDef')
            attrEditorFactories{i,3}=rawVal.Key;
        end
    end
end
