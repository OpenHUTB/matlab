function add(this,varargin)


    try

        [varargin{:}]=convertStringsToChars(varargin{:});
        inputNames=cell(nargin,1);
        for idx=1:nargin
            inputNames{idx}=inputname(idx);
        end


        if nargin==2&&~ischar(varargin{1})
            this.add('namevalue',inputNames(2),varargin(1));
            return
        end


        repo=sdi.Repository(1);
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


        Simulink.sdi.internal.import.addToRun(inputNames,this.id,varargin{:});
    catch me
        throwAsCaller(me);
    end
end
