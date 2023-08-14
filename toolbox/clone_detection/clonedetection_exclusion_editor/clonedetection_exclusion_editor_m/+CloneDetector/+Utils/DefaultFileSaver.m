classdef DefaultFileSaver<CloneDetector.Utils.FileChooser




    methods
        function[file,folder,status]=chooseFile(~,varargin)
            [file,folder,status]=uiputfile(varargin{:});
        end
    end
end



