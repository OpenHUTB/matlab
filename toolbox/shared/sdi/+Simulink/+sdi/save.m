function save(filename,varargin)












    if nargin>0
        filename=convertStringsToChars(filename);
    end

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if Simulink.HMI.isSessionSaveOrLoadInProgress()
        error(getString(message('SDI:sdi:MLDATXSaveLoadInProgress')));
    end

    [~,~,extension]=fileparts(filename);
    if~isempty(extension)&&~strcmp(extension,'.mldatx')&&~strcmp(extension,'.mat')




        filename=[filename,'.mldatx'];
        Simulink.sdi.internal.warning(message('SDI:sdi:SessionSaveInvalidExtension',extension,filename));
    end

    Simulink.sdi.internal.flushStreamingBackend();
    Simulink.sdi.Instance.engine.save(filename,'',true,varargin{:});
end