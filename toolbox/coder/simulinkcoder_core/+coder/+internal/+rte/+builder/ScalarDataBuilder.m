classdef ScalarDataBuilder<coder.internal.rte.builder.DataBuilder
    methods
        function this=ScalarDataBuilder(type,baseName)
            this@coder.internal.rte.builder.DataBuilder(type,baseName);
        end

        function def=emit(this)
            def=coder.internal.rte.builder.DataBuilder.makeStmt(['static ',this.getBaseTypeStr,' ',this.VarName]);
        end

        function impl=getReaderCopyImplementation(this)
            impl=this.getReaderBody;
        end

        function impl=getWriterCopyImplementation(this)
            impl=this.getWriterBody;
        end

        function impl=getInitialization(this)
            impl=this.getInitializationBody;
        end
    end

    methods(Access=private)
        function impl=getReaderBody(this)
            impl{1}=coder.internal.rte.builder.DataBuilder.makeReturnStmt(this.VarName);
        end

        function impl=getWriterBody(this)

            assert(~isempty(this.Writer));
            impl{1}=coder.internal.rte.builder.DataBuilder.makeStmt([this.VarName,' = ',this.Writer.Name]);
        end

        function impl=getInitializationBody(this)
            impl=[this.VarName,' = 0;'];
        end
    end
end
