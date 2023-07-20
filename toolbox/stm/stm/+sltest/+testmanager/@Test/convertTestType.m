% Change test from one type to another.

% Copyright 2016 MathWorks, Inc.
function convertTestType(obj, varargin)
try
    p = inputParser;
    addRequired(p,'obj',...
        @(x)validateattributes(x,{'sltest.testmanager.Test'},{'scalar','nonempty'}));
    p.parse(obj);
    sltest.internal.convertTestTypeHelper(p.Results.obj.id, isa(obj, 'sltest.testmanager.TestCase'), varargin{:});
catch ME
    throwAsCaller(ME);
end
