classdef(Sealed)ReplacementTypesProducer<coderapp.internal.config.util.CompositeProducer


    methods
        function this=ReplacementTypesProducer()
            this@coderapp.internal.config.util.CompositeProducer('coder.ReplacementTypes');
        end
    end

    methods(Access=protected)
        function reuse=canReuse(this)
            boundConfig=this.value('boundConfig');
            reuse=isempty(boundConfig)||(isa(boundConfig,'coder.EmbeddedCodeConfig')&&...
            ~isempty(boundConfig.ReplacementTypes));
        end

        function instance=instantiate(this)
            if this.useReplacementTypes()
                instance=instantiate@coderapp.internal.config.util.CompositeProducer(this);
            else
                instance=coder.ReplacementTypes.empty();
            end
        end

        function updateScript(this)
            if this.useReplacementTypes()
                this.ScriptHelper.setInstantiator('');
            else
                this.ScriptHelper.setInstantiator('coder.ReplacementTypes.empty()');
            end
        end

        function[mappedKeys,mappedProps]=keysToProperties(this,varargin)
            if this.useReplacementTypes()
                [mappedKeys,mappedProps]=keysToProperties@coderapp.internal.config.util.CompositeProducer(this,varargin{:});
            else
                mappedKeys={};
                mappedProps={};
            end
        end
    end

    methods(Access=private)
        function yes=useReplacementTypes(this)
            yes=this.canReuse()||any(this.isUserModified());
        end
    end
end

