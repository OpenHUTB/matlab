classdef L5XStructValueMemberEmitter<plccore.visitor.L5XValueEmitter



    properties(Access=protected)
data_name
array_name
struct_name
    end

    methods
        function obj=L5XStructValueMemberEmitter(xml_writer,top_node)
            obj@plccore.visitor.L5XValueEmitter(xml_writer);
            obj.Kind='L5XStructValueMemberEmitter';
            obj.pushNode(top_node);
        end
    end

    methods(Access=protected)
        function[name_list,value_list]=processDataValueParamList(obj,name_list,value_list)
            name_list{end+1}='Name';
            value_list{end+1}=obj.data_name;
        end

        function[name_list,value_list]=processStructValueParamList(obj,name_list,value_list)
            name_list{end+1}='Name';
            value_list{end+1}=obj.struct_name;
        end

        function[name_list,value_list]=processArrayValueParamList(obj,name_list,value_list)
            name_list{end+1}='Name';
            value_list{end+1}=obj.array_name;
        end

        function genDataValue(obj,name_list,value_list)
            obj.emitter.genDataValueMember(obj.topNode,name_list,value_list);
        end

        function ret=beginGenStructValue(obj,name_list,value_list)
            ret=obj.emitter.beginGenStructValueMember(obj.topNode,name_list,value_list);
        end

        function ret=beginGenArrayValue(obj,name_list,value_list)
            ret=obj.emitter.beginGenArrayValueMember(obj.topNode,name_list,value_list);
        end
    end

    methods
        function ret=visitConstFalse(obj,host,input)
            obj.data_name=input;
            ret=visitConstFalse@plccore.visitor.L5XValueEmitter(obj,host,input);
        end

        function ret=visitConstTrue(obj,host,input)
            obj.data_name=input;
            ret=visitConstTrue@plccore.visitor.L5XValueEmitter(obj,host,input);
        end

        function ret=visitConstValue(obj,host,input)
            obj.data_name=input;
            ret=visitConstValue@plccore.visitor.L5XValueEmitter(obj,host,input);
        end

        function ret=visitStructValue(obj,host,input)
            obj.struct_name=input;
            ret=visitStructValue@plccore.visitor.L5XValueEmitter(obj,host,input);
        end

        function ret=visitArrayValue(obj,host,input)
            obj.array_name=input;
            ret=visitArrayValue@plccore.visitor.L5XValueEmitter(obj,host,input);
        end
    end
end
