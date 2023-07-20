







classdef FunctionInfoRegistryCache

    properties(Constant,Access=private)
        cache containers.Map=containers.Map;
    end

    methods(Static,Access=private)
        function setCacheValuePriv(blockName,s)
            c=internal.ml2pir.FunctionInfoRegistryCache.cache;
            c(blockName)=s;%#ok<NASGU>
        end

        function s=getCacheValuePriv(blockName)
            c=internal.ml2pir.FunctionInfoRegistryCache.cache;

            assert(c.isKey(blockName))

            s=c(blockName);
        end
    end

    methods(Static,Access=public)
        function varargout=retrieveAndSetCacheValue(varargin)


            assert(nargin>=2);
            implFcn=varargin{1};
            blockName=varargin{2};
            [s,varargout{1:nargout}]=implFcn(varargin{2:nargin});
            internal.ml2pir.FunctionInfoRegistryCache.setCacheValuePriv(blockName,s);
        end

        function varargout=getCacheValue(blockName,implFcn)


            s=internal.ml2pir.FunctionInfoRegistryCache.getCacheValuePriv(blockName);
            [varargout{1:nargout}]=implFcn(s);
        end

        function clearCacheValues()


            c=internal.ml2pir.FunctionInfoRegistryCache.cache;
            c.remove(c.keys);
        end
    end
end
