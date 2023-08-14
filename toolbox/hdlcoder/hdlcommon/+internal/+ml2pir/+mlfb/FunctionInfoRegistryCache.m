




classdef FunctionInfoRegistryCache

    methods(Static,Access=public)
        function varargout=retrieveAndSetCacheValue(varargin)

            implFcn=eval(['@',mfilename('class'),'.setImplFcn']);
            [varargout{1:nargout}]=...
            internal.ml2pir.FunctionInfoRegistryCache.retrieveAndSetCacheValue(implFcn,varargin{:});
        end

        function varargout=getCacheValue(blockName)

            implFcn=eval(['@',mfilename('class'),'.getImplFcn']);
            [varargout{1:nargout}]=...
            internal.ml2pir.FunctionInfoRegistryCache.getCacheValue(blockName,implFcn);
        end
    end

    methods(Static,Access=private)
        function[s,fcnInfoRegistry,exprMap,designNames,messages]=setImplFcn(blockName,chartData)
            report=internal.ml2pir.mlfb.fetchReport(blockName);
            [fcnInfoRegistry,exprMap,designNames,messages]=...
            internal.mtree.createFunctionInfoRegistry(report,chartData);

            s=struct;
            s.fcnInfoRegistry=fcnInfoRegistry;
            s.exprMap=exprMap;
            s.designNames=designNames;
        end

        function[fcnInfoRegistry,exprMap,designNames]=getImplFcn(s)
            fcnInfoRegistry=s.fcnInfoRegistry;
            exprMap=s.exprMap;
            designNames=s.designNames;
        end
    end
end
