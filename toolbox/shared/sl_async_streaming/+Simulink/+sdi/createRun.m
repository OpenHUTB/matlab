function[runID,runIdx,sigIDs]=createRun(varargin)











































    [varargin{:}]=convertStringsToChars(varargin{:});
    inputNames=cell(nargin,1);
    for idx=1:nargin
        inputNames{idx}=inputname(idx);
    end


    if nargin==1&&~ischar(varargin{1})
        if isobject(varargin{1})&&isprop(varargin{1},'Name')&&(ischar(varargin{1}.Name)||isstring(varargin{1}.Name))
            runName=char(varargin{1}.Name);
        else
            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            runName=fw.getDefaultRunNameTemplate();
        end
        [runID,runIdx,sigIDs]=Simulink.sdi.createRun(...
        runName,'namevalue',inputNames(1),varargin(1));
        return
    end


    repo=sdi.Repository(1);
    Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


    try
        [runID,runIdx,sigIDs]=Simulink.sdi.internal.import.createRun(...
        inputNames,varargin{:});
    catch me
        throwAsCaller(me);
    end
end