function varargout=fihelper(varargin)








    [varargin,isMultipleEntryPoints,isF2FOnly]=coder.internal.handleFloat2FixedConversion('fiaccel',varargin);




    if isMultipleEntryPoints&&isF2FOnly
        fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',1);
        c=onCleanup(@()fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel',0));
    end

    report=emlcprivate('callfcn','emlckernel','fiaccel',varargin{:});
    if nargout>0
        varargout{1}=report;
    else
        coder.internal.emcError('fiaccel',report);
    end

