function newPath = incrementFilePath(inPath)
%
% Append number to a file path to make it unique

% Copyright 2014 The MathWorks, Inc.
%
    newPath = inPath;
    [outputPath,outputName,outputExt] = fileparts(inPath);
    if(exist(inPath,'file'))
        K = 1;
        while(1)
            tmpFileName = sprintf('%s_%d',outputName,K);
            tmpPath = fullfile(outputPath,[tmpFileName outputExt]);
            if(exist(tmpPath,'file') == 0)
                newPath = tmpPath;
                break;
            end
            K = K + 1;
        end
    end
end


