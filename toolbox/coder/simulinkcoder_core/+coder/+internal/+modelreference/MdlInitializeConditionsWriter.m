




classdef MdlInitializeConditionsWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods
        function this=MdlInitializeConditionsWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            assert(false);
        end

        function writeFunctionHeader(this,~)
            assert(false,'Should not be called.');
            this.Writer.writeLine('\n#define  MDL_INITIALIZE_CONDITIONS\n');
            this.Writer.writeLine('static void mdlInitializeConditions(SimStruct *S) {')
        end

        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end

        function writeFunctionCall(this,functionInterface)
            this.Writer.writeLine('%s;',functionInterface.getFunctionCall);
            for i=1:this.ModelInterface.NumPeriodicContStates
                this.Writer.writeLine('ssSetPeriodicContState(S, %d, %d, %.17g, %.17g);',...
                i-1,...
                this.ModelInterface.PeriodicCStateIndices(i),...
                this.ModelInterface.PeriodicCStateRanges(2*i-1),...
                this.ModelInterface.PeriodicCStateRanges(2*i));
            end
        end
    end
end
