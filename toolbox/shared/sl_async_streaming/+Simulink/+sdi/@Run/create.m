function ret=create(varargin)


    ret=Simulink.sdi.Run.empty();
    try

        [varargin{:}]=convertStringsToChars(varargin{:});
        inputNames=cell(nargin,1);
        for idx=1:nargin
            inputNames{idx}=inputname(idx);
        end


        if nargin==1&&~ischar(varargin{1})
            if isprop(varargin{1},'Name')&&(ischar(varargin{1}.Name)||isstring(varargin{1}.Name))
                runName=char(varargin{1}.Name);
            else
                fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                runName=fw.getDefaultRunNameTemplate();
            end
            ret=Simulink.sdi.Run.create(runName,'namevalue',inputNames(1),varargin(1));
            return
        end


        repo=sdi.Repository(1);
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


        runIDs=Simulink.sdi.internal.import.createRun(inputNames,varargin{:});


        for idx=1:length(runIDs)
            ret(idx)=Simulink.sdi.Run(repo,runIDs(idx));
        end
    catch me
        throwAsCaller(me);
    end
end
