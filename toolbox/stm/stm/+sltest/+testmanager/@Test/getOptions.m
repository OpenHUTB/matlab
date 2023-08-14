% Get options object associated with a test

% Copyright 2016 MathWorks, Inc.
function options = getOptions( obj )
    p = inputParser;
    addRequired(p,'obj',...
        @(x)validateattributes(x,{'sltest.testmanager.Test'},{'scalar','nonempty'}));
    p.parse(obj);

    isTestFile = isa(obj, 'sltest.testmanager.TestFile');
    options = sltest.internal.Helper.getOptions(obj.id, isTestFile);
end
