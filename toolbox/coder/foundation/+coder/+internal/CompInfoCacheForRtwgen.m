classdef CompInfoCacheForRtwgen<handle




    properties(Access=private)
        DefaultMexCompilerInfo;
        ResolvedMexCompilerKey;
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

        function cleanUpFcn=setRtwgenCompInfoCache(lDefaultMexCompInfo,lResolvedMexCompilerKey)

            cleanUpFcn=onCleanup(@()coder.internal.CompInfoCacheForRtwgen.getSetHandle([]));
            h=coder.internal.CompInfoCacheForRtwgen...
            (lDefaultMexCompInfo,lResolvedMexCompilerKey);
            coder.internal.CompInfoCacheForRtwgen.getSetHandle(h);

        end

        function[isRtwgenCall,lDefaultMexCompilerInfo,lResolvedMexCompilerKey]=...
getRtwgenCompInfoCache

            h=coder.internal.CompInfoCacheForRtwgen.getSetHandle;
            isRtwgenCall=~isempty(h);
            if isRtwgenCall
                lDefaultMexCompilerInfo=h.DefaultMexCompilerInfo;
                lResolvedMexCompilerKey=h.ResolvedMexCompilerKey;
            else
                lDefaultMexCompilerInfo=[];
                lResolvedMexCompilerKey='';
            end

        end

    end

    methods(Access=private)

        function this=CompInfoCacheForRtwgen(lDefaultMexCompilerInfo,lResolvedMexCompilerKey)
            this.DefaultMexCompilerInfo=lDefaultMexCompilerInfo;
            this.ResolvedMexCompilerKey=lResolvedMexCompilerKey;
        end

    end
end
