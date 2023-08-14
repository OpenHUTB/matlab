function exc=exception(msgid,varargin)









    exc=MException(['ERRORHANDLER:',msgid],DAStudio.message(['ERRORHANDLER:',msgid],varargin{:}));