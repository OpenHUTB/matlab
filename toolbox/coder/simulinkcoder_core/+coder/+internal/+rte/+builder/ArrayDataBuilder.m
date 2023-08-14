classdef ArrayDataBuilder<coder.internal.rte.builder.DataBuilder
    methods
        function this=ArrayDataBuilder(type,baseName)
            this=this@coder.internal.rte.builder.DataBuilder(type,baseName);
            this.Dimension=this.getDimension;
            assert(this.Dimension>0);
        end

        function def=emit(this)
            def=coder.internal.rte.builder.DataBuilder.makeStmt(...
            ['static ',this.getBaseTypeStr,' ',this.VarName,'[',int2str(this.Dimension),']']);
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

                impl{1}=coder.internal.rte.builder.DataBuilder.makeReturnStmt(this.VarName);
            else
                impl=this.makeLoopRead;
            end
        end

        function impl=getWriterBody(this)
            if(isempty(this.Writer))

                impl{1}=coder.internal.rte.builder.DataBuilder.makeReturnStmt(this.VarName);
            else
                impl=this.makeLoopWrite;
            end
        end

        function impl=makeLoopRead(this)
            impl=coder.internal.rte.builder.DataBuilder.makeLoop(this.Dimension,this.Reader.Name,'=',this.VarName);
        end

        function impl=makeLoopWrite(this)
            impl=coder.internal.rte.builder.DataBuilder.makeLoop(this.Dimension,this.VarName,'=',this.Writer.Name);
        end

        function impl=getInitializationBody(this)
            impl=['memset(',this.VarName,', 0, ',int2str(this.Dimension),'U',' * sizeof(',this.getBaseTypeStr,'));'];
        end
    end
end
