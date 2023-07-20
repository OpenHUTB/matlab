% Get coverage settings object associated with a test

% Copyright 2015-2016 MathWorks, Inc.
function coverageSettings = getCoverageSettings( obj )
    p = inputParser;
    addRequired(p,'obj',...
        @(x)validateattributes(x,{'sltest.testmanager.Test'},{'scalar','nonempty'}));
    p.parse(obj);

    isTestFile = isa(obj, 'sltest.testmanager.TestFile');
    coverageSettings = sltest.internal.Helper.getCoverageSettings(obj.id, isTestFile);
end
