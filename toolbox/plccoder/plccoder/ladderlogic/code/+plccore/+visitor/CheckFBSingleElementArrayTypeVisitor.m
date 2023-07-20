classdef CheckFBSingleElementArrayTypeVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=CheckFBSingleElementArrayTypeVisitor
            obj.Kind='CheckFBSingleElementArrayTypeVisitor';
        end

        function ret=visitArrayType(obj,host,input)
            if host.numElem==1
                ret=true;
                return;
            end
            ret=host.elemType.accept(obj,input);
        end

        function ret=visitStructType(obj,host,input)
            ret=false;
            for i=1:host.numFields
                if host.fieldType(i).accept(obj,input)
                    ret=true;
                    return;
                end
            end
        end

        function ret=visitPOUType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitTIMEType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitBitFieldType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitNamedType(obj,host,input)
            ret=host.type.accept(obj,input);
        end

        function ret=visitBOOLType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitDINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitLINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitLREALType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitREALType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitSINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitUDINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitULINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end

        function ret=visitUSINTType(obj,host,input)%#ok<INUSD>
            ret=false;
        end
    end
end
