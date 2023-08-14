classdef FileMetadataNodeJava







    properties(GetAccess=private,SetAccess=private)
        JMetadataNode;
    end

    methods(Access=public)

        function obj=FileMetadataNodeJava(node)
            if(nargin<1)
                import com.mathworks.toolbox.slproject.project.matlab.api.applicationmetadata.FileMetadataNodeFacade;
                obj.JMetadataNode=FileMetadataNodeFacade;
                return
            end

            validateattributes(node,{...
            'com.mathworks.toolbox.slproject.project.matlab.api.applicationmetadata.FileMetadataNodeFacade',...
            },{'nonempty'});

            obj.JMetadataNode=node;
        end


        function value=get(obj,key)
            validateattributes(key,{'char','string'},{'nonempty'});

            value=string(obj.JMetadataNode.getValue(key));
        end

        function set(obj,key,value)
            validateattributes(key,{'char','string'},{'nonempty'});
            validateattributes(value,{'char','string'},{'nonempty'});
            obj.JMetadataNode.setValue(key,value);
        end

        function keys=getKeys(obj)
            keys=obj.JMetadataNode.getKeys();
            if isempty(keys)
                keys=[];
            else
                keys=string(cellstr(keys));
            end
        end

        function node=createChildNode(obj)

            jNewNode=obj.JMetadataNode.createChildNode();
            import matlab.internal.project.metadata.FileMetadataNodeJava;
            node=FileMetadataNodeJava(jNewNode);
        end

        function nodes=getChildNodes(obj)

            jChildNodes=obj.JMetadataNode.getChildNodes();

            import matlab.internal.project.util.convertJavaCollectionToCellArray;
            import matlab.internal.project.metadata.FileMetadataNodeJava;
            elementConverter=@(x)FileMetadataNodeJava(x);
            nodes=convertJavaCollectionToCellArray(jChildNodes,elementConverter);
            nodes=[nodes{:}];
        end

        function removeChildNode(obj,childToRemove)
            validateattributes(childToRemove,{'matlab.internal.project.metadata.FileMetadataNodeJava'},{'nonempty'});

            obj.JMetadataNode.removeChildNode(childToRemove.extractJNode());
        end

    end

    methods(Access=public,Hidden=true)
        function jNode=extractJNode(obj)
            jNode=obj.JMetadataNode;
        end
    end

end
