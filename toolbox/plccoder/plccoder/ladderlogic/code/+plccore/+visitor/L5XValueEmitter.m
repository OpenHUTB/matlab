classdef L5XValueEmitter<plccore.visitor.AbstractVisitor



    properties(Access=protected)
XmlWriter
node_stack
    end

    methods
        function beginGenAOIVarValue(obj)
            node=obj.emitter.beginGenAOIVarValue;
            obj.pushNode(node);
        end

        function endGenVarValue(obj)
            obj.clearNodeStack;
        end

        function beginGenProgVarValue(obj)
            node=obj.emitter.beginGenProgVarValue;
            obj.pushNode(node);
        end

        function beginGenGlobalVarValue(obj)
            obj.beginGenProgVarValue;
        end

        function setTopNode(obj,node)
            assert(obj.isNodeStackEmpty);
            obj.pushNode(node);
        end
    end

    methods(Access=protected)
        function ret=emitter(obj)
            ret=obj.XmlWriter;
        end

        function pushNode(obj,node)
            obj.node_stack{end+1}=node;
        end

        function ret=topNode(obj)
            assert(~obj.isNodeStackEmpty);
            ret=obj.node_stack{end};
        end

        function popNode(obj)
            assert(~obj.isNodeStackEmpty);
            obj.node_stack(end)=[];
        end

        function ret=isNodeStackEmpty(obj)
            ret=isempty(obj.node_stack);
        end

        function clearNodeStack(obj)
            obj.node_stack={};
        end

        function ret=arrayDims(obj,dim_list)%#ok<INUSL>
            ret=cell2mat(join(arrayfun(@(x)num2str(x),dim_list,'UniformOutput',false),','));
        end

        function genStructMember(obj,field_name,field_value)
            import plccore.visitor.*;
            field_emitter=L5XStructValueMemberEmitter(obj.emitter,obj.topNode);
            field_value.accept(field_emitter,field_name);
        end

        function genArrayElement(obj,num_dim,dim_list,idx,elem)
            import plccore.visitor.*;
            idx_list=[];
            for i=num_dim:-1:1
                dim=dim_list(i);
                idx_i=mod(idx,dim);
                idx_list=[idx_i,idx_list];%#ok<AGROW>
                idx=fix(idx/dim);
            end



            idx_list_txt=sprintf('%d,',idx_list);
            idx_list_txt=idx_list_txt(1:end-1);
            elem_node=obj.emitter.genArrayElem(obj.topNode,sprintf('[%s]',idx_list_txt));
            elem_emitter=L5XArrayValueElementEmitter(obj.emitter,elem_node);
            elem.accept(elem_emitter,[]);
        end

        function[name_list,value_list]=processDataValueParamList(obj,name_list,value_list)%#ok<INUSL>
        end

        function[name_list,value_list]=processStructValueParamList(obj,name_list,value_list)%#ok<INUSL>
        end

        function[name_list,value_list]=processArrayValueParamList(obj,name_list,value_list)%#ok<INUSL>
        end

        function genDataValue(obj,name_list,value_list)
            obj.emitter.genDataValue(obj.topNode,name_list,value_list);
        end

        function ret=beginGenStructValue(obj,name_list,value_list)
            ret=obj.emitter.beginGenStructValue(obj.topNode,name_list,value_list);
        end

        function ret=beginGenArrayValue(obj,name_list,value_list)
            ret=obj.emitter.beginGenArrayValue(obj.topNode,name_list,value_list);
        end
    end

    methods
        function obj=L5XValueEmitter(xml_writer)
            obj.Kind='L5XValueEmitter';
            obj.XmlWriter=xml_writer;
            obj.node_stack={};
        end

        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret=[];
            name_list={'DataType','Value'};
            value_list={'BOOL','0'};
            [name_list,value_list]=obj.processDataValueParamList(name_list,value_list);
            obj.genDataValue(name_list,value_list);
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=[];
            name_list={'DataType','Value'};
            value_list={'BOOL','1'};
            [name_list,value_list]=obj.processDataValueParamList(name_list,value_list);
            obj.genDataValue(name_list,value_list);
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSD>
            import plccore.util.*;
            import plccore.type.*;
            ret=[];
            name_list={'DataType','Value'};
            if TypeTool.isRealType(host.type)
                value=host.value;
                if~contains(value,'.')
                    value=sprintf('%s.0',value);
                end
                value_list={GetL5XTypeName(host.type),value};
            else
                value_list={GetL5XTypeName(host.type),host.value};
            end
            [name_list,value_list]=obj.processDataValueParamList(name_list,value_list);
            obj.genDataValue(name_list,value_list);
        end

        function ret=visitStructValue(obj,host,input)%#ok<INUSD>
            import plccore.type.*;
            ret=[];
            type=host.type;
            if TypeTool.isNamedStructType(type)
                type_name=type.name;
            else
                assert(TypeTool.isPOUType(type));
                type_name=type.pou.name;
            end
            name_list={'DataType'};
            value_list={type_name};
            [name_list,value_list]=obj.processStructValueParamList(name_list,value_list);
            struct_node=obj.beginGenStructValue(name_list,value_list);
            obj.pushNode(struct_node);
            field_name_list=host.fieldNameList;
            field_value_list=host.fieldValueList;
            assert(length(field_name_list)==length(field_value_list));
            for i=1:length(field_name_list)
                field_name=field_name_list{i};
                field_value=field_value_list{i};
                obj.genStructMember(field_name,field_value);
            end
            obj.popNode;
        end

        function ret=visitArrayValue(obj,host,input)%#ok<INUSD>
            import plccore.util.*;
            import plccore.type.*;
            ret=[];
            type=host.type;
            assert(isa(type,'plccore.type.ArrayType'));
            name_list={'DataType','Dimensions'};
            value_list={GetL5XTypeName(type.elemType),obj.arrayDims(type.dims)};
            [name_list,value_list]=obj.processArrayValueParamList(name_list,value_list);
            array_node=obj.beginGenArrayValue(name_list,value_list);
            obj.pushNode(array_node);
            elem_list=host.elemValueList;
            assert(length(elem_list)==type.numElem);
            dim_list=type.dims;
            for i=1:length(elem_list)
                elem=elem_list{i};
                obj.genArrayElement(type.numDims,dim_list,i-1,elem);
            end
            obj.popNode;
        end
    end
end


