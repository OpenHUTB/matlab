function openplckeywordsfile(taskobj) %#ok<INUSD>
%

%   Copyright 2020 The MathWorks, Inc.

    fullPath = fileparts( mfilename('fullpath') );
    open(fullfile(fullPath, 'plcopenkeywords.xml'))

    % LocalWords:  plcopenkeywords
