classdef L5XArrayValueElementEmitter<plccore.visitor.L5XValueEmitter



    methods
        function obj=L5XArrayValueElementEmitter(xml_writer,top_node)
            obj@plccore.visitor.L5XValueEmitter(xml_writer);
            obj.Kind='L5XArrayValueElementEmitter';
            obj.pushNode(top_node);
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret=[];
            top_node=obj.topNode;
            top_node.setAttribute('Value','0');
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=[];
            top_node=obj.topNode;
            top_node.setAttribute('Value','1');
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            ret=[];
            top_node=obj.topNode;
            top_node.setAttribute('Value',host.value);
        end

        function ret=visitStructValue(obj,host,input)%#ok<INUSD>
            import plccore.visitor.*;
            ret=[];
            ve=L5XValueEmitter(obj.emitter);
            ve.setTopNode(obj.topNode);
            host.accept(ve,[]);
        end

        function ret=visitArrayValue(obj,host,input)%#ok<INUSD>
            assert(false,'Rockwell does not allow array of array');
            ret=[];
        end
    end
end

