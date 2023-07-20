function lCodeDescriptor = loadCodeDescriptor(lCodeFolder)
%LOADCODEDESCRIPTOR gets code descriptor for use with profiling

%   Copyright 2015 The MathWorks, Inc.
    
% Skip Embedded Coder license check for SLRT case
    licenceArgs = {};
    if strfind(lCodeFolder, 'slrt')
        licenceArgs = {247362};
    end 
    
    lCodeDescriptor = coder.getCodeDescriptor(lCodeFolder, licenceArgs{:});

