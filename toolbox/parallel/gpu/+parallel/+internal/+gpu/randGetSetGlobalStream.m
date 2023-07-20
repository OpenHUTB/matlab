function oldstream=randGetSetGlobalStream(stream)













    persistent globe;
mlock

    firstCall=isempty(globe);

    if firstCall
        globe=parallel.gpu.RandStream.createDefaultStream();


        callback=@(varargin)parallel.internal.gpu.randGetSetGlobalStream(...
        parallel.gpu.RandStream.create(varargin{:}));


        parallel.internal.cluster.setGpuGlobalRandStream([],callback);
    end

    oldstream=globe;

    if nargin>=1


        globe=iUpdateGlobeOrError(stream);
        if~firstCall&&parallel.internal.gpu.isLibraryLoaded()








            builtin('_gpu_cacheRandStreamHandle',stream);
        end
    end
end

function globe=iUpdateGlobeOrError(stream)
    if~isa(stream,'parallel.gpu.RandStream')||~isvalid(stream)
        errID='MATLAB:RandStream:setglobalstream:InvalidInput';
        me=MException(message(errID));
        throwAsCaller(me);
    end
    globe=stream;
end
