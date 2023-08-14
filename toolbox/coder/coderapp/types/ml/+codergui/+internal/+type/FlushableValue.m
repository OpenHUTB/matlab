classdef(Sealed)FlushableValue<handle



    properties
        Default=codergui.internal.undefined()
        Previous=codergui.internal.undefined()
        Next=codergui.internal.undefined()
    end

    properties(Dependent,SetAccess=immutable)
Current
IsUserSet
    end

    properties(SetAccess=private,Transient)
Annotations
        IsPending=false
    end

    properties(SetAccess=immutable)
        DebugName char=''
    end

    methods
        function this=FlushableValue(defaultValue,debugName)
            if nargin>0
                this.Default=defaultValue;
                if nargin>1
                    this.DebugName=debugName;
                end
            end
        end

        function flush(this)
            this=this([this.IsPending]);
            if isempty(this)
                return;
            end

            undefined=codergui.internal.undefined();
            for i=1:numel(this)
                this(i).Previous=this(i).Next;
                this(i).Next=undefined;
                this(i).Annotations=[];
            end
        end

        function clear(this)
            undefined=codergui.internal.undefined();
            for i=1:numel(this)
                this(i).Next=undefined;
                this(i).IsPending=false;
            end
        end

        function value=get.Current(this)
            if this.IsPending
                value=this.Next;
            else
                value=this.Previous;
                if codergui.internal.undefined(value)
                    value=this.Default;
                end
            end
        end

        function userSet=get.IsUserSet(this)
            userSet=this.IsPending||~codergui.internal.undefined(this.Previous);
        end

        function set.Next(this,next)
            legit=~isempty(next)||~codergui.internal.undefined(next);
            if legit
                [next,this.Annotations]=codergui.internal.deannotate(next);%#ok<MCSUP>
            else
                next=codergui.internal.undefined();
                this.Annotations=[];%#ok<MCSUP>
            end
            this.Next=next;
            this.IsPending=legit;%#ok<MCSUP>
        end

        function set.Previous(this,value)
            this.Previous=value;
            this.IsPending=false;%#ok<MCSUP>
        end
    end
end
