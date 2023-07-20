classdef Node<handle&xmlcomp.internal.NodeAccessor




    properties(GetAccess=public,SetAccess={?xmlcomp.internal.NodeAccessor},Dependent)


Children
Edited
Name
Parameters
Parent
Partner
    end

    properties(Access={?xmlcomp.internal.NodeAccessor})
        BaseNode;
    end

    methods

        function node=Node(varargin)

            if(nargin<1)
                return
            end

            node.BaseNode=varargin{1};
        end

        function children=get.Children(node)
            children=node.BaseNode.Children;
        end

        function edited=get.Edited(node)
            edited=node.BaseNode.Edited;
        end

        function name=get.Name(node)
            name=node.BaseNode.Name;
        end

        function pars=get.Parameters(node)
            pars=node.BaseNode.Parameters;
        end

        function parent=get.Parent(node)
            parent=node.BaseNode.Parent;
        end

        function partner=get.Partner(node)
            partner=node.BaseNode.Partner;
        end


        function set.Parent(node,value)
            node.BaseNode.Parent=value;

            if~isempty(value)
                value.BaseNode.addChild(node);
            end
        end

        function set.Partner(node,value)
            node.BaseNode.Partner=value;
        end

    end


end
