classdef(Sealed)InlineProducer<handle&coderapp.internal.config.AbstractProducer





    properties(SetAccess=immutable)
        Code{mustBeTextScalar(Code)}=''
    end

    methods
        function this=InlineProducer(matlabExpr)
            this.Code=matlabExpr;
        end

        function produce(this)
            this.Logger.debug('Evaluating logger expression: %s',this.Code);
            contribKeys=this.keys();
            this.Production=coderapp.internal.config.evalScopedExpr(this.Code,...
            [{this.Key},contribKeys],[{this.Production},this.value(contribKeys)]);
            this.ScriptModel=this.Code;
        end
    end
end