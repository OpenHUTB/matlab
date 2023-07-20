function [filepath,ext] = splitFilePath(inpath)
%
% Use MATLAB to process file path under different OSs.

% Copyright 2014 The MathWorks, Inc.
%

    [pathstr,name,ext] = fileparts(inpath);
    filepath = fullfile(pathstr,name);
end
