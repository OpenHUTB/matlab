classdef node<handle

    properties(Access=protected)
in_node
in_count
out_node
out_count
    end
    properties(SetAccess=protected)
name
    end

    methods
        function obj=node(name,varargin)

            obj.name=name;
            obj.in_node={};
            obj.in_count=0;
            obj.out_node={};
            obj.out_count=0;
        end
    end
    methods
        function setOutPropertyPropagation(obj,index,val)

            obj.out_node{index}{4}=val;
        end
    end
    methods(Sealed,Access={?handle})

        function addInConnection(obj,source_block,source_port,destination_port)
            obj.in_node(end+1)={{source_block,source_port,destination_port}};
            obj.in_count=obj.in_count+1;
        end

        function addOutConnection(obj,source_port,destination_block,destination_port,varargin)

            if isempty(varargin)
                obj.out_node(end+1)={{source_port,destination_block,destination_port,true}};
            else
                obj.out_node(end+1)={{source_port,destination_block,destination_port,varargin{1}}};

            end
            obj.out_count=obj.out_count+1;
        end

        function n=getOutCount(obj)
            n=obj.out_count;
        end

        function n=getInCount(obj)
            n=obj.in_count;
        end

        function[source_port,destination_name,destination_port,property_propagation]=...
            getOutConnection(obj,index)
            if index<=obj.out_count
                source_port=obj.out_node{index}{1};
                destination_name=obj.out_node{index}{2};
                destination_port=obj.out_node{index}{3};
                property_propagation=obj.out_node{index}{4};
            else

            end
        end

        function[source_block,source_port,destination_port]=getInConnection(obj,index)
            if index<=obj.in_count
                source_block=obj.in_node{index}{1};
                source_port=obj.in_node{index}{2};
                destination_port=obj.in_node{index}{3};
            else

            end
        end

    end
end

