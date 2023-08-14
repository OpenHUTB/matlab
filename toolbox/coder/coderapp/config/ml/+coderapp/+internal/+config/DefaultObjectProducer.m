classdef(Sealed)DefaultObjectProducer<handle&coderapp.internal.config.AbstractProducer



    properties(SetAccess=immutable)
Factory
        FactoryArgs cell={}
    end

    methods
        function this=DefaultObjectProducer(factory,varargin)
            narginchk(1,Inf);
            if~isa(factory,'function_handle')
                if isempty(which(factory))
                    error('Could not resolve function/constructor "%s"',factory);
                end
                factory=str2func(factory);
            end
            this.Factory=factory;
            this.FactoryArgs=varargin;
        end

        function defaultObj=produce(this)
            defaultObj=feval(this.Factory,this.FactoryArgs{:});
        end
    end
end