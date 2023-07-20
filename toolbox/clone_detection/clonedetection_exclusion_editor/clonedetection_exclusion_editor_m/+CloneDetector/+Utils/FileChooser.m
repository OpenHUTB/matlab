classdef FileChooser




    methods(Abstract)
        [file,folder,status]=chooseFile(this,varargin)
    end
end
