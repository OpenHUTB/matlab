


classdef NamedMutex<handle
    properties(Access=private,Constant=true)
        NAMEDMUTEX_OPEN=1;
        NAMEDMUTEX_CLOSE=2;
        NAMEDMUTEX_LOCK=3;
        NAMEDMUTEX_UNLOCK=4;
        NAMEDMUTEX_REMOVE=5;
    end

    properties(Access=private)
mutexName
mtx
closeOnly
    end

    methods(Access=public)
        function this=NamedMutex(mutexName,varargin)
            this.mutexName=mutexName;
            openOnly=(nargin>=2)&&logical(varargin{1});
            this.closeOnly=openOnly;
            this.mtx=namedmutex_mex(polyspace.internal.NamedMutex.NAMEDMUTEX_OPEN,...
            mutexName,varargin{:});
        end

        function delete(this)
            if~isempty(this.mtx)
                namedmutex_mex(polyspace.internal.NamedMutex.NAMEDMUTEX_CLOSE,...
                this.mutexName,this.mtx,this.closeOnly);
            end
        end

        function lock(this)
            namedmutex_mex(polyspace.internal.NamedMutex.NAMEDMUTEX_LOCK,this.mtx);
        end

        function unlock(this)
            namedmutex_mex(polyspace.internal.NamedMutex.NAMEDMUTEX_UNLOCK,this.mtx);
        end
    end

    methods(Access=public,Static=true)
        function removeMutex(mutexName)
            namedmutex_mex(polyspace.internal.NamedMutex.NAMEDMUTEX_REMOVE,...
            mutexName);
        end
    end
end
