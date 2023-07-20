
function[opts,varargout]=getOptions(protectedModelFile,varargin)








    protectedModelFile=convertStringsToChars(protectedModelFile);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    protectedModelFile=Simulink.ModelReference.ProtectedModel.getProtectedModelFileName(protectedModelFile);

    [isProtected,fullName]=slInternal('getReferencedModelFileInformation',protectedModelFile);
    if isempty(fullName)||~isProtected
        DAStudio.error('Simulink:protectedModel:unableToFindProtectedModelFile',protectedModelFile);
    end

    runConsistencyChecks='runAllConsistencyChecks';
    if nargin==2
        runConsistencyChecks=varargin{1};
    end

    if strcmp(runConsistencyChecks,'runAllConsistencyChecks')

        slInternal('runConsistencyChecks',fullName);
    elseif strcmp(runConsistencyChecks,'runConsistencyChecksNoPlatform')


        slInternal('runConsistencyChecksNoPlatform',fullName);
    else
        assert(strcmp(runConsistencyChecks,'runNoConsistencyChecks'),...
        'Incorrect parameter value provided to getOptions');
    end

    try

        opts=slInternal('getProtectedModelExtraInformation',fullName);
    catch
        opts=[];
    end

    varargout{1}=fullName;
end
