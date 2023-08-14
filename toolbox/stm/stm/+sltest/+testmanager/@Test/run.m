% Run all tests within obj

% Copyright 2018-2022 The MathWorks, Inc.

function resultObj = run(obj, type, varargin)
    arguments
        obj sltest.testmanager.Test {mustBeNonempty};
        type;
    end
    arguments (Repeating)
        varargin;
    end

    % create matrix [id1, type; id2, type; ...]
    idMap = [obj.id].';
    idMap(:, end+1) = type;

    parallelize = false;
    tagStr = '';
    cls = string(class(obj));
    nVar = length(varargin);
    if nVar == 1
        p = inputParser;
        p.addRequired('obj',@(x)validateattributes(x,cls,{'scalar','nonempty'}));
        p.parse(obj);
        validateattributes(varargin{1},"logical",{'scalar'});
        parallelize = varargin{1};
    elseif nVar > 1
        p = inputParser;
        p.addRequired('obj',@(x)validateattributes(x,cls,{'scalar','nonempty'}));
        p.addParameter('Parallel',false,@(x)validateattributes(x,"logical",{'scalar'}));
        p.addParameter('Tags',{},@(x)validateattributes(x,["cell","string"],{'vector'}));
        p.parse(obj, varargin{:});

        parallelize = p.Results.Parallel;
        tagList = string(p.Results.Tags);
        tagStr = tagList.join(',').char;
        verifyNoTestCaseTags(obj, tagStr);
    end
    resultObj = stm.internal.apiDetail.runWrapper('idMap',idMap, ...
        'parallel',parallelize,...
        'tag',tagStr, 'rootId', [obj.id]);
end

function verifyNoTestCaseTags(obj, tagStr)
    % directly running a test case while passing in tags is not supported
    if isa(obj, 'sltest.testmanager.TestCase')
        validateattributes(tagStr,"char",{'size', [0,0]},'','Tags');
    end
end
