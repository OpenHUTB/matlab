classdef SLAliasTypeVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=SLAliasTypeVisitor
            obj.Kind='SLAliasTypeVisitor';
        end

        function ret=visitArrayType(obj,host,input)
            ret=host.elemType.accept(obj,input);
        end

        function ret=visitStructType(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitPOUType(obj,host,input)%#ok<INUSL,INUSD>
            ret=sprintf('Bus: %s',host.pou.name);
        end

        function ret=visitTIMEType(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitBitFieldType(obj,host,input)%#ok<INUSD>
            ret='BOOL';
        end

        function ret=visitNamedType(obj,host,input)%#ok<INUSL,INUSD>
            ret=sprintf('Bus: %s',host.name);
        end

        function ret=visitBOOLType(obj,host,input)%#ok<INUSD>
            ret='BOOL';
        end

        function ret=visitDINTType(obj,host,input)%#ok<INUSD>
            ret='DINT';
        end

        function ret=visitINTType(obj,host,input)%#ok<INUSD>
            ret='INT';
        end

        function ret=visitLINTType(obj,host,input)%#ok<INUSD>
            ret='LINT';
        end

        function ret=visitLREALType(obj,host,input)%#ok<INUSD>
            ret='LREAL';
        end

        function ret=visitREALType(obj,host,input)%#ok<INUSD>
            ret='REAL';
        end

        function ret=visitSINTType(obj,host,input)%#ok<INUSD>
            ret='SINT';
        end

        function ret=visitUDINTType(obj,host,input)%#ok<INUSD>
            ret='UDINT';
        end

        function ret=visitULINTType(obj,host,input)%#ok<INUSD>
            ret='ULDINT';
        end

        function ret=visitUSINTType(obj,host,input)%#ok<INUSD>
            ret='USINT';
        end
    end
end


