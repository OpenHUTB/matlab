classdef CompInfoCacheForAutosar<handle




    properties(Access=private)
        ModelMexCompilerKeyForAutosar;
    end

    methods(Access=private,Static=true)

        function varargout=getSetHandle(varargin)
            persistent handle;
            if~isempty(varargin)
                handle=varargin{1};
            else
                if isempty(handle)
                    handle=[];
                end
                varargout{1}=handle;
            end
        end

    end

    methods(Access=public,Static=true)

        function cleanUpFcn=setModelMexCompilerKeyCache(lMexCompilerKey)

            h=coder.internal.CompInfoCacheForAutosar(lMexCompilerKey);
            coder.internal.CompInfoCacheForAutosar.getSetHandle(h);
            cleanUpFcn=onCleanup(@()coder.internal.CompInfoCacheForAutosar.getSetHandle([]));

        end

        function lMexCompilerKey=getModelMexCompilerKeyCache

            h=coder.internal.CompInfoCacheForAutosar.getSetHandle;
            assert(~isempty(h),'No cached data for mex compiler key')
            lMexCompilerKey=h.ModelMexCompilerKeyForAutosar;

        end

    end

    methods(Access=private)

        function this=CompInfoCacheForAutosar(lMexCompilerKey)
            this.ModelMexCompilerKeyForAutosar=lMexCompilerKey;
        end

    end
end
