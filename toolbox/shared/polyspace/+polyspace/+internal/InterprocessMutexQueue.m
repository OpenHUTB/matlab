

classdef InterprocessMutexQueue<handle
    properties(Access=private,Constant=true)
        INTERPROCESS_MUTEX_QUEUE_OPEN=1;
        INTERPROCESS_MUTEX_QUEUE_CLOSE=2;
        INTERPROCESS_MUTEX_QUEUE_LOCK=3;
        INTERPROCESS_MUTEX_QUEUE_UNLOCK=4;
        INTERPROCESS_MUTEX_QUEUE_REMOVE=5;
    end

    properties(Access=private)
mutexName
mtx
closeOnly
    end

    methods(Access=public)
        function this=InterprocessMutexQueue(mutexName,varargin)
            this.mutexName=mutexName;
            openOnly=(nargin>=2)&&logical(varargin{1});
            this.closeOnly=openOnly;
            this.mtx=interprocess_mutex_queue_mex(polyspace.internal.InterprocessMutexQueue.INTERPROCESS_MUTEX_QUEUE_OPEN,...
            mutexName,varargin{:});
        end

        function delete(this)
            if~isempty(this.mtx)
                interprocess_mutex_queue_mex(polyspace.internal.InterprocessMutexQueue.INTERPROCESS_MUTEX_QUEUE_CLOSE,...
                this.mutexName,this.mtx,this.closeOnly);
            end
        end

        function lock(this)
            interprocess_mutex_queue_mex(polyspace.internal.InterprocessMutexQueue.INTERPROCESS_MUTEX_QUEUE_LOCK,this.mtx);
        end

        function unlock(this)
            interprocess_mutex_queue_mex(polyspace.internal.InterprocessMutexQueue.INTERPROCESS_MUTEX_QUEUE_UNLOCK,this.mtx);
        end

        function mutexName=saveobj(this)
            mutexName=this.mutexName;
        end
    end

    methods(Access=public,Static=true)
        function removeMutex(mutexName)
            interprocess_mutex_queue_mex(polyspace.internal.InterprocessMutexQueue.INTERPROCESS_MUTEX_QUEUE_REMOVE,...
            mutexName);
        end

        function this=loadobj(mutexName)
            this=polyspace.internal.InterprocessMutexQueue(mutexName,true);
        end
    end
end
