classdef SLTypeVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=SLTypeVisitor
            obj.Kind='SLTypeVisitor';
        end

        function ret=visitArrayType(obj,host,input)
            ret=host.elemType.accept(obj,input);
        end

        function ret=visitStructType(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitPOUType(obj,host,input)%#ok<INUSL,INUSD>
            ret=host.pou.name;
        end

        function ret=visitTIMEType(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitBitFieldType(obj,host,input)%#ok<INUSD>
            ret='boolean';
        end

        function ret=visitNamedType(obj,host,input)%#ok<INUSL,INUSD>
            ret=host.name;
        end

        function ret=visitBOOLType(obj,host,input)%#ok<INUSD>
            ret='boolean';
        end

        function ret=visitDINTType(obj,host,input)%#ok<INUSD>
            ret='int32';
        end

        function ret=visitINTType(obj,host,input)%#ok<INUSD>
            ret='int16';
        end

        function ret=visitLINTType(obj,host,input)%#ok<INUSD>
            ret='int64';
        end

        function ret=visitLREALType(obj,host,input)%#ok<INUSD>
            ret='double';
        end

        function ret=visitREALType(obj,host,input)%#ok<INUSD>
            ret='single';
        end

        function ret=visitSINTType(obj,host,input)%#ok<INUSD>
            ret='int8';
        end

        function ret=visitUDINTType(obj,host,input)%#ok<INUSD>
            ret='uint32';
        end

        function ret=visitULINTType(obj,host,input)%#ok<INUSD>
            ret='uint64';
        end

        function ret=visitUSINTType(obj,host,input)%#ok<INUSD>
            ret='uint8';
        end
    end
end

