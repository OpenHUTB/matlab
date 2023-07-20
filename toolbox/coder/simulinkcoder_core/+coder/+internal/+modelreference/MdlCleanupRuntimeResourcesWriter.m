




classdef MdlCleanupRuntimeResourcesWriter<coder.internal.modelreference.FunctionInterfaceWriter
    methods(Access=public)
        function this=MdlCleanupRuntimeResourcesWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end
    methods(Access=public)
        function write(this)
            this.writeFunctionHeader;
            if~isempty(this.FunctionInterfaces)
                this.writeFunctionBody(this.FunctionInterfaces);
            end
            this.writeDeepLearningDestruction;
            this.writeFunctionTrailer;
        end
    end

    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlCleanupRuntimeResources(SimStruct *S)';
        end

        function writeFunctionHeader(this,~)
            this.Writer.writeLine('\n#define MDL_CLEANUP_RUNTIME_RESOURCES\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this);
        end

        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end

        function writeDeepLearningDestruction(this)


            dwIsNotDefined=isempty(this.FunctionInterfaces);
            if isfield(this.ModelInterface,'CoderDataGroups')
                coderDataGroups=this.ModelInterface.CoderDataGroups;
                numCoderDataGroups=numel(coderDataGroups.CoderDataGroup);
                for i=1:numCoderDataGroups
                    if numCoderDataGroups==1
                        coderDataGroup=coderDataGroups.CoderDataGroup;
                    else
                        coderDataGroup=coderDataGroups.CoderDataGroup{i};
                    end



                    if strcmp(coderDataGroup.SynthesizedNamePrefix,'_DeepLearning')&&...
                        coderDataGroup.Depth==0

                        if dwIsNotDefined
                            this.declareMultiInstanceVariables;
                            dwIsNotDefined=false;
                        end

                        this.Writer.writeLine('delete dw->%s;',coderDataGroup.SelfPath);
                    end
                end
            end
        end

    end
end
