classdef MF0NodeWrapper<handle&xmlcomp.internal.NodeAccessor



    properties(GetAccess=public,SetAccess=?xmlcomp.internal.NodeAccessor)
        Children xmlcomp.Node
Edited
Name
Parameters
        Parent xmlcomp.Node
        Partner xmlcomp.Node
    end

    methods(Access=?xmlcomp.internal.NodeAccessor)
        function addChild(obj,child)
            obj.Children(end+1)=child;
        end
    end

    methods(Access=public)
        function obj=MF0NodeWrapper(varargin)
            if nargin==0
                return
            end

            mf0Node=varargin{1};
            obj.Name=mf0Node.name;
        end
    end
end
