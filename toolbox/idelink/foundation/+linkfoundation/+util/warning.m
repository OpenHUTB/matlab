function warning(msgid,varargin)









    MSLDiagnostic(['ERRORHANDLER:',msgid],varargin{:}).reportAsWarning;