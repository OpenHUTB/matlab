function varargout=unpack(model,mode,varargin)







    import Simulink.ModelReference.ProtectedModel.unpackProtectedModelSimTargetArtifactsIfNecessary
    import Simulink.ModelReference.ProtectedModel.unpackProtectedModelCodeGenerationTargetIfNecessary
    import Simulink.ModelReference.ProtectedModel.unpackProtectedModelSimTargetArtifactsForCodegenIfNecessary
    import Simulink.ModelReference.ProtectedModel.unpackWebviewIfNecessary
    import Simulink.ModelReference.ProtectedModel.unpackReportIfNecessary
    import Simulink.ModelReference.ProtectedModel.unpackHDL

    if slfeature('ProtectedModelValidateCertificatePreferences')>0


        protectedModelFile=Simulink.ModelReference.ProtectedModel.getProtectedModelFileName(model);
        [isProtected,fullName]=slInternal('getReferencedModelFileInformation',protectedModelFile);
        if isempty(fullName)||~isProtected
            error(message('Simulink:protectedModel:unableToFindProtectedModelFile',protectedModelFile));
        end
        Simulink.ProtectedModel.internal.checkCertificate(fullName);
    end

    switch mode
    case 'SIM'
        [varargout{1:nargout}]=unpackProtectedModelSimTargetArtifactsIfNecessary(model,varargin{:});
    case 'CODEGEN'
        [varargout{1:nargout}]=unpackProtectedModelCodeGenerationTargetIfNecessary(model,varargin{:});
    case 'SIM_FOR_CODEGEN'
        [varargout{1:nargout}]=unpackProtectedModelSimTargetArtifactsForCodegenIfNecessary(model,varargin{:});
    case 'VIEW'
        [varargout{1:nargout}]=unpackWebviewIfNecessary(model,varargin{:});
    case 'REPORT'
        [varargout{1:nargout}]=unpackReportIfNecessary(model,varargin{:});
    case 'HDL'
        [varargout{1:nargout}]=unpackHDL(model,varargin{:});
    otherwise
        assert(false);
    end


