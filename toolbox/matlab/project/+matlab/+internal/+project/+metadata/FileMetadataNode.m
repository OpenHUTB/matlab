classdef FileMetadataNode







    properties(GetAccess=public,SetAccess=private,Hidden=true)
        Delegate;
    end

    methods(Access=public)

        function obj=FileMetadataNode(delegate)
            if(nargin<1)
                if matlab.internal.project.util.useWebFrontEnd
                    obj.Delegate=matlab.internal.project.api.FileMetadataNode();
                else
                    obj.Delegate=matlab.internal.project.metadata.FileMetadataNodeJava();
                end
                return
            end
            obj.Delegate=delegate;
        end


        function value=get(obj,key)
            value=obj.Delegate.get(key);
        end

        function set(obj,key,value)
            obj.Delegate.set(key,value);
        end

        function keys=getKeys(obj)
            keys=obj.Delegate.getKeys();
        end

        function node=createChildNode(obj)
            import matlab.internal.project.metadata.FileMetadataNode;
            node=FileMetadataNode(obj.Delegate.createChildNode());
        end

        function nodes=getChildNodes(obj)
            import matlab.internal.project.metadata.FileMetadataNode;
            delegateChildren=obj.Delegate.getChildNodes();
            numChildren=length(delegateChildren);
            if numChildren==0
                nodes=FileMetadataNode.empty;
                return
            end
            nodes(numChildren)=FileMetadataNode(delegateChildren(numChildren));
            for idx=1:(numChildren-1)
                nodes(idx)=FileMetadataNode(delegateChildren(idx));
            end
        end

        function removeChildNode(obj,childToRemove)
            obj.Delegate.removeChildNode(childToRemove.Delegate);
        end

    end

end
