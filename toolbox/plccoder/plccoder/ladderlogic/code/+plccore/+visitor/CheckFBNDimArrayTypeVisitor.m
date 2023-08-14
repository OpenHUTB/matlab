classdef CheckFBNDimArrayTypeVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=CheckFBNDimArrayTypeVisitor
            obj.Kind='CheckFBNDimArrayTypeVisitor';
        end

        function ret=visitArrayType(obj,host,input)
            if host.numDims>1
                ret=[true,host.numDims];
                return;
            end
            ret=host.elemType.accept(obj,input);
        end

        function ret=visitStructType(obj,host,input)
            ret=[false,0];
            for i=1:host.numFields
                ret_fd=host.fieldType(i).accept(obj,input);
                if~isempty(ret_fd)&&ret_fd(1)
                    ret=ret_fd;
                    return;
                end
            end
        end

        function ret=visitPOUType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitTIMEType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitBitFieldType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitNamedType(obj,host,input)
            ret=host.type.accept(obj,input);
        end

        function ret=visitBOOLType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitDINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitLINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitLREALType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitREALType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitSINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitUDINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitULINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end

        function ret=visitUSINTType(obj,host,input)%#ok<INUSD>
            ret=[false,0];
        end
    end
end

