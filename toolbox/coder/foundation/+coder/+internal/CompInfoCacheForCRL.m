classdef CompInfoCacheForCRL<handle















    properties(Access=private)
        MexCompInfoForCRL;
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

        function cleanUpFcn=setMexCompInfoCache(mexCompInfo)

            h=coder.internal.CompInfoCacheForCRL(mexCompInfo);
            coder.internal.CompInfoCacheForCRL.getSetHandle(h);
            cleanUpFcn=onCleanup(@()coder.internal.CompInfoCacheForCRL.getSetHandle([]));

        end

        function mexCompInfo=getMexCompInfoCache

            h=coder.internal.CompInfoCacheForCRL.getSetHandle;
            if isempty(h)

                mexCompInfo=coder.make.internal.getMexCompilerInfo();
                if ispc&&isempty(mexCompInfo)
                    mexCompInfo=coder.make.internal.getMexCompInfoFromKey('LCC-x');
                end
            else
                mexCompInfo=h.MexCompInfoForCRL;
            end

        end

    end

    methods(Access=private)

        function this=CompInfoCacheForCRL(mexCompInfo)
            this.MexCompInfoForCRL=mexCompInfo;
        end

    end
end
