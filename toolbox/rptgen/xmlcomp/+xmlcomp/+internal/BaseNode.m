classdef BaseNode<handle&xmlcomp.internal.NodeAccessor



    properties(GetAccess=public,SetAccess=protected)
        Children=[];
        Edited=false;
        Name='';
        Parameters=[];
    end

    properties(GetAccess=public,SetAccess={?xmlcomp.Node})
        Parent=[];
        Partner=[];
    end

    methods(Access={?xmlcomp.Node})
        function addChild(obj,child)
            obj.Children=[obj.Children,child];
        end
    end

    methods(Access=protected)

        function addParameter(obj,jParameter)
            parameter.Name=char(jParameter.getName());
            parameter.Value=char(jParameter.getValue());
            obj.Parameters=[obj.Parameters,parameter];
        end

    end

end
