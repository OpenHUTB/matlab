classdef FileNodeMapJava





    properties(GetAccess=private,SetAccess=private)
        JavaNodeMap;
    end

    methods(Access=public)
        function obj=FileNodeMapJava(map)
            if(nargin<1)
                obj.JavaNodeMap=com.mathworks.toolbox.slproject.project.matlab.api.applicationmetadata.FileNodeMapFacade();
                return
            end
            obj.JavaNodeMap=map;
        end

        function files=listFiles(obj)
            jkeys=obj.JavaNodeMap.listKeys();
            if isempty(jkeys)
                files=[];
            else
                files=string(cellstr(jkeys));
            end
        end

        function node=getNode(obj,file)
            file=char(file);
            jnode=obj.JavaNodeMap.getNode(file);
            import matlab.internal.project.metadata.FileMetadataNodeJava;
            node=FileMetadataNodeJava(jnode);
        end

        function setNode(obj,file,node)
            file=char(file);
            obj.JavaNodeMap.setNode(file,node.extractJNode());
        end
    end

    methods(Access=public,Hidden=true)
        function value=getJavaNodeMap(obj)
            value=obj.JavaNodeMap;
        end
    end
end
