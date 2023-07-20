function sigIDs=addToRun(varargin)

























    narginchk(3,inf);


    [varargin{:}]=convertStringsToChars(varargin{:});
    inputNames=cell(nargin,1);
    for idx=1:nargin
        inputNames{idx}=inputname(idx);
    end


    repo=sdi.Repository(1);
    Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


    try
        sigIDs=Simulink.sdi.internal.import.addToRun(inputNames,varargin{:});
    catch me
        throwAsCaller(me);
    end
end