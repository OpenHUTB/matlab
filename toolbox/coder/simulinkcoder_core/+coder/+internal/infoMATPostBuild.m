function varargout=infoMATPostBuild...
    (action,minfo_or_binfo,modelName,mdlRefTgtType,lSystemTargetFile,...
    varargin)









    cleanGenSettingsCache=coder.internal.infoMATInitializeFromSTF...
    (lSystemTargetFile,modelName,...
    'ModelReferenceTargetType',mdlRefTgtType);%#ok


    [varargout{1:nargout}]=coder.internal.infoMATFileMgr...
    (action,minfo_or_binfo,modelName,mdlRefTgtType,varargin{:});
