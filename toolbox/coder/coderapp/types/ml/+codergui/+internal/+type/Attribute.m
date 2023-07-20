classdef(Sealed)Attribute<handle




    properties(SetAccess=immutable)
        Definition codergui.internal.type.AttributeDef
        Node codergui.internal.type.TypeMakerNode
    end

    properties(Dependent,SetAccess=immutable)
Key
Annotations
IsPending
HasPendingValue
HasNonDefaultValue
HasNonDefaultState
PendingProperties
    end

    properties(Dependent)
Value
IsVisible
IsEnabled
AllowedValues
Min
Max
    end

    properties(GetAccess=private,SetAccess=immutable)
ValueHolder
VisibleHolder
EnabledHolder
ValuesHolder
MinHolder
MaxHolder
Holders
NodeCallback
        Forceable=true
    end

    properties(Access=private)
CachedPending
    end

    properties(Access=?codergui.internal.type.TypeMakerNode)
        ForceNextValue=false
    end

    methods(Access=?codergui.internal.type.TypeMakerNode)
        function this=Attribute(node,attributeDefs,nodeCallback,forceable)
            if nargin==0
                return;
            end
            this(numel(attributeDefs))=codergui.internal.type.Attribute();
            if nargin<4
                hasForceable=false;
                if nargin<3
                    nodeCallback=[];
                end
            else
                hasForceable=true;
            end
            for i=1:numel(attributeDefs)
                def=attributeDefs(i);
                instance=this(i);
                instance.Node=node;
                instance.Definition=def;
                instance.ValueHolder=codergui.internal.type.FlushableValue(def.InitialValue,'attrValue');
                instance.VisibleHolder=codergui.internal.type.FlushableValue(def.InitialVisible,'attrVisible');
                instance.EnabledHolder=codergui.internal.type.FlushableValue(def.InitialEnabled,'attrEnabled');
                instance.ValuesHolder=codergui.internal.type.FlushableValue(def.InitialAllowedValues,'attrAllowedValues');
                instance.MinHolder=codergui.internal.type.FlushableValue(def.InitialMin,'attrMin');
                instance.MaxHolder=codergui.internal.type.FlushableValue(def.InitialMax,'attrMax');
                instance.Holders=[instance.ValueHolder,instance.VisibleHolder,instance.EnabledHolder...
                ,instance.ValuesHolder,instance.MinHolder,instance.MaxHolder];
                instance.NodeCallback=nodeCallback;
                if hasForceable
                    instance.Forceable=forceable(i);
                end
            end
        end

        function reset(this)
            this=this([this.IsPending]);
            for i=1:numel(this)
                this(i).Holders.clear();
                this(i).CachedPending=[];
            end
        end

        function applyChanges(this)
            this=this([this.IsPending]);
            for i=1:numel(this)
                this(i).Holders.flush();
                this(i).CachedPending=[];
            end
        end
    end

    methods
        function value=get.Value(this)
            value=this.ValueHolder.Current;
        end

        function set.Value(this,value)
            if~this.ForceNextValue
                validator=@this.validateValue;
                this.ForceNextValue=false;
            else
                validator=[];
            end
            this.tryChange(validator,true,this.ValueHolder,value);
        end

        function enabled=get.IsEnabled(this)
            enabled=this.EnabledHolder.Current;
        end

        function set.IsEnabled(this,enabled)
            this.tryChange(@(v)validateScalarLogical('IsEnabled',v),true,this.EnabledHolder,enabled);
        end

        function visible=get.IsVisible(this)
            visible=this.VisibleHolder.Current;
        end

        function set.IsVisible(this,visible)
            this.tryChange(@(v)validateScalarLogical('IsVisible',v),true,this.VisibleHolder,visible);
        end

        function values=get.AllowedValues(this)
            values=this.ValuesHolder.Current;
        end

        function set.AllowedValues(this,values)
            this.tryChange([],true,this.AllowedValues,values);
        end

        function min=get.Min(this)
            min=this.MinHolder.Current;
        end

        function set.Min(this,min)
            this.tryChange(@(v)validateScalarNumber('Min',v),true,this.MinHolder,min);
        end

        function max=get.Max(this)
            max=this.MaxHolder.Current;
        end

        function set.Max(this,max)
            this.tryChange(@(v)validateScalarNumber('Max',v),true,this.MaxHolder,max);
        end

        function set=get.HasNonDefaultValue(this)
            set=this.ValueHolder.IsUserSet&&~isequal(this.ValueHolder.Current,this.ValueHolder.Default);
        end

        function notDefault=get.HasNonDefaultState(this)
            notDefault=any([this.Holders.IsUserSet]);
        end

        function pending=get.IsPending(this)
            pending=this.CachedPending;
            if isempty(pending)
                pending=any([this.Holders.IsPending]);
                this.CachedPending=pending;
            end
        end

        function pending=get.HasPendingValue(this)
            pending=this.ValueHolder.IsPending;
        end

        function key=get.Key(this)
            key=this.Definition.Key;
        end

        function annotation=get.Annotations(this)
            annotation=this.ValueHolder.Annotations;
        end

        function set.ForceNextValue(this,force)
            if force&&~this.Forceable %#ok<MCSUP>
                error('Attribute "%s" is not forceable',this.Key);%#ok<MCSUP>
            end
            this.ForceNextValue=force;
        end

        function states=describe(this,full,externalizeValue,includeDefaults)
            if nargin<4
                includeDefaults=false;
                if nargin<3
                    externalizeValue=false;
                    if nargin<2
                        full=true;
                    end
                end
            end
            if includeDefaults
                undefines={};
            else
                undefined=codergui.internal.undefined();
                undefines={repmat({undefined},1,numel(this))};
            end

            mainValues=extractUserValues([this.ValueHolder],undefines{:});
            if externalizeValue
                for i=1:numel(mainValues)
                    if undefined~=mainValues{i}
                        mainValues{i}=this(i).Definition.valueToExternal(mainValues{i});
                    end
                end
            end
            if nargin<2||full
                states=struct(...
                'key',{this.Key},...
                'value',mainValues,...
                'isEnabled',extractUserValues([this.EnabledHolder],undefines{:}),...
                'isVisible',extractUserValues([this.VisibleHolder],undefines{:}),...
                'allowedValues',extractUserValues([this.ValuesHolder],undefines{:}),...
                'min',extractUserValues([this.MinHolder],undefines{:}),...
                'max',extractUserValues([this.MaxHolder],undefines{:}));
            else
                states=struct(...
                'key',{this.Key},...
                'value',mainValues);
            end
        end
    end

    methods(Access=?codergui.internal.type.TypeMakerNode)
        function changed=restore(this,states,wasExternalized)
            assert(numel(this)==numel(states));
            changed=false(1,numel(this));
            if isempty(this)
                return
            end

            full=isfield(states,'isEnabled');
            undefined=codergui.internal.undefined();

            for i=1:numel(this)
                attr=this(i);
                state=states(i);
                if undefined~=state.value
                    if wasExternalized
                        value=attr.Definition.externalToValue(state.value);
                    else
                        value=state.value;
                    end
                    if~isequal(value,attr.Value)
                        attr.Value=value;
                        changed(i)=true;
                    end
                end
                if~full
                    continue
                end
                if undefined~=state.isEnabled&&~isequal(attr.IsEnabled,state.isEnabled)
                    attr.IsEnabled=state.isEnabled;
                    changed(i)=true;
                end
                if undefined~=state.isVisible&&~isequal(attr.IsVisible,state.isVisible)
                    attr.IsVisible=state.isVisible;
                    changed(i)=true;
                end
                if undefined~=state.allowedValues&&~isequal(attr.AllowedValues,state.allowedValues)
                    attr.AllowedValues=state.allowedValues;
                    changed(i)=true;
                end
                if undefined~=state.min&&~isequal(attr.Min,state.min)
                    attr.Min=state.min;
                    changed(i)=true;
                end
                if undefined~=state.max&&~isequal(attr.Max,state.max)
                    attr.Max=state.max;
                    changed(i)=true;
                end
            end
        end
    end

    methods(Access=private)
        function value=validateValue(this,value)
            allowedValues=this.AllowedValues;
            value=this.Definition.validateValue(value,this.Node);
            if~isempty(allowedValues)&&~ismember(value,allowedValues)
                codergui.internal.util.throwInternal('Value "%s" is not in the set of allowed values',value);
            end
            if~isempty(this.NodeCallback)
                value=feval(this.NodeCallback,value);
            end
        end

        function tryChange(this,validator,stateCheck,holder,rawValue)
            if~stateCheck
                this.Node.revert('Attribute "%s" is not modifiable in the current state',this.Key);
                return
            end
            cleanup=this.Node.pushTrigger();%#ok<NASGU>                  

            try
                if~isempty(validator)
                    [trueValue,annotations]=codergui.internal.deannotate(rawValue);
                    trueValue=validator(trueValue);
                    if~isempty(annotations)
                        trueValue=codergui.internal.util.AnnotatedValue(trueValue,annotations);
                    end
                    nextValue=trueValue;
                else
                    nextValue=rawValue;
                end

                if this.Definition.ValueType==codergui.internal.ui.ValueTypes.Any
                    eq=builtin('isequal',nextValue,holder.Current);
                else
                    eq=isequal(nextValue,holder.Current);
                end

                if~eq||this.Node.TypeMaker.IsRestoring
                    holder.Next=nextValue;
                    this.CachedPending=[];
                end
            catch me
                this.Node.revert(me);
            end
        end
    end
end


function userValues=extractUserValues(holders,undefines)
    if nargin>1
        assert(numel(holders)==numel(undefines)&&iscell(undefines));
    else
        undefines={holders.Default};
    end
    userMask=[holders.IsUserSet];
    userValues=undefines;
    [userValues{userMask}]=holders(userMask).Current;
end


function value=validateScalarLogical(propName,value)
    if~isscalar(value)||~islogical(value)

        error('Value of "%s" must be a scalar logical',propName);
    end
end


function value=validateScalarNumber(propName,value)
    if~isscalar(value)||~isnumeric(value)||~isreal(value)

        error('Value of "%s" must be a scalar real number',propName);
    end
end
