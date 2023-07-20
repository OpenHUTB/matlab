classdef StructDataBuilder<coder.internal.rte.builder.DataBuilder
    properties
        DataBuilders{};
    end

    methods
        function this=StructDataBuilder(type,baseName)
            this=this@coder.internal.rte.builder.DataBuilder(type,baseName);

            assert(this.Type.BaseType.isStructure);

            for i=1:length(this.Type.BaseType.Elements)
                e=this.Type.BaseType.Elements(i);
                this.DataBuilders{i}=coder.internal.rte.builder.AccessMethodBuilder.constructDataBuilder(e.Type,e.Identifier);
            end
        end

        function def=emit(this)
            def=coder.internal.rte.builder.DataBuilder.makeStmt(...
            ['static ',this.Type.BaseType.Identifier,' ',this.VarName]);
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
        function dim=getDimension(this)
            if this.Type.isPointer
                dim=this.Type.BaseType.Dimensions(1);
            elseif this.Type.isMatrix
                dim=this.Type.Dimensions(1);
            else
                assert(false,'incorrect type to get dimensions');
            end
        end

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
