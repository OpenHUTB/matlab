classdef FileDialogServiceInterface
    methods(Abstract)
        [filename,pathname,filterindex]=getfile(varargin);
        [filename,pathname,filterindex]=putfile(varargin);
    end
end