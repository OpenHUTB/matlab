classdef FileNodeMap





    properties(GetAccess=public,SetAccess=private,Hidden=true)
        Delegate;
    end

    methods(Access=public)
        function obj=FileNodeMap(delegate)
            if(nargin<1)
                if matlab.internal.project.util.useWebFrontEnd
                    obj.Delegate=matlab.internal.project.api.FileNodeMap;
                else
                    obj.Delegate=matlab.internal.project.metadata.FileNodeMapJava;
                end
                return
            end
            obj.Delegate=delegate;
        end

        function files=listFiles(obj)
            files=obj.Delegate.listFiles();
        end

        function node=getNode(obj,file)
            import matlab.internal.project.metadata.FileMetadataNode;
            node=FileMetadataNode(obj.Delegate.getNode(file));
        end

        function setNode(obj,file,node)
            obj.Delegate.setNode(file,node.Delegate);
        end
    end
end
