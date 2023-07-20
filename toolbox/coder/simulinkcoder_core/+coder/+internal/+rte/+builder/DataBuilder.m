classdef DataBuilder<handle
    properties(Access=protected)
        Type;
        BaseType;
        BaseName;
        VarName;
        Dimension;
        Reader;
        Writer;
    end

    methods(Abstract)
        emit(this)
    end

    methods
        function this=DataBuilder(type,baseName)
            this.Type=type;
            this.BaseType=coder.internal.rte.builder.DataBuilder.getBaseType(this.Type);
            this.BaseName=baseName;
            this.VarName=this.getVarName(baseName);
        end

        function type=getTypeStr(this)
            type=this.BaseType;
            if~this.Type.isScalar
                type=[type,'*'];
            end
        end

        function type=getBaseTypeStr(this)
            type=this.BaseType.Identifier;
        end

        function assignReader(this,reader)
            this.Reader=reader;
        end

        function assignWriter(this,writer)
            this.Writer=writer;
        end

        function imp=getReaderImplementation(this)


            imp=getReaderCopyImplementation(this);
        end

        function imp=getWriterImplementation(this)


            imp=getWriterCopyImplementation(this);
        end
    end

    methods(Static)


        function type=getBaseType(aType)
            if aType.isScalar
                type=aType;
            elseif aType.isStructure
                type=aType;
            elseif aType.isComplex
                type=aType;
            else

                type=coder.internal.rte.builder.DataBuilder.getBaseType(aType.BaseType);
            end
        end
    end

    methods(Access=private)
        function output=isScalar(this)
            output=this.Type.isScalar;
        end



        function name=getVarName(~,baseName)
            name=baseName;
        end
    end

    methods(Static)
        function stmt=makeStmt(expr)
            stmt=[expr,';'];
        end

        function stmt=makeReturnStmt(expr)
            stmt=coder.internal.rte.builder.DataBuilder.makeStmt(['return ',expr]);
        end

        function stmts=makeLoop(size,lhs,op,rhs)





            lhsElem=[lhs,'[i]'];
            rhsElem=[rhs,'[i]'];
            expr=coder.internal.rte.builder.DataBuilder.makeStmt([lhsElem,op,rhsElem]);


            assert(size>0);
            stmts{1}='int32_T i;';


            stmts{end+1}=['for (i = 0; i < ',int2str(size),'; i=i+1) {'];
            stmts{end+1}=expr;
            stmts{end+1}='}';
        end

        function stmt=makeMemcopy(toVar,fromVar,sizeObj)
            stmt{1}=coder.internal.rte.builder.DataBuilder.makeStmt...
            (['memcpy(',toVar,', ',fromVar,', ','sizeof(',sizeObj,'))']);
        end

    end
end
