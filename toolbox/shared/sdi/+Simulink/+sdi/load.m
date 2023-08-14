function isValidSDIMatFile=load(filename,varargin)








    try
        if nargin>0
            filename=convertStringsToChars(filename);
        end

        if Simulink.HMI.isSessionSaveOrLoadInProgress()
            error(getString(message('SDI:sdi:MLDATXSaveLoadInProgress')));
        end

        Simulink.HMI.synchronouslyFlushWorkerQueue();
        isValidSDIMatFile=Simulink.sdi.Instance.engine.load(filename,true,varargin{:});
    catch ex
        throwAsCaller(ex);
    end
end