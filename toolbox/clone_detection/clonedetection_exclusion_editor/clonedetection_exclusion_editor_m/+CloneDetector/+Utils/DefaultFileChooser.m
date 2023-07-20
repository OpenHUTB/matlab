classdef DefaultFileChooser<CloneDetector.Utils.FileChooser





    methods
        function[file,folder,status]=chooseFile(~,varargin)
            [file,folder,status]=uigetfile(varargin{:});
        end
    end
end

