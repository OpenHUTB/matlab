classdef ComplexDataBuilder<coder.internal.rte.builder.DataBuilder
    properties
        DataBuilders{};
    end

    methods
        function this=ComplexDataBuilder(type,baseName)
            this=this@coder.internal.rte.builder.DataBuilder(type,baseName);
            assert(this.Type.BaseType.isComplex);
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
            if(isempty(this.Reader))

                impl{1}=coder.internal.rte.builder.DataBuilder.makeReturnStmt(['&',this.VarName]);
            else
                impl=this.makeMemcopyRead;
            end
        end

        function impl=getWriterBody(this)
            if(isempty(this.Writer))

                impl{1}=coder.internal.rte.builder.DataBuilder.makeReturnStmt(['&',this.VarName]);
            else
                impl=this.makeMemcopyWrite;
            end
        end

        function impl=makeMemcopyRead(this)
            impl=coder.internal.rte.builder.DataBuilder.makeMemcopy(this.Reader.Name,['&(',this.VarName,')'],this.Type.BaseType.Identifier);
        end

        function impl=makeMemcopyWrite(this)
            impl=coder.internal.rte.builder.DataBuilder.makeMemcopy(['&(',this.VarName,')'],this.Reader.Name,this.Type.BaseType.Identifier);
        end

        function impl=getInitializationBody(this)
            impl=['memset(&',this.VarName,', 0, sizeof(',this.getBaseTypeStr,'));'];
        end
    end
end
