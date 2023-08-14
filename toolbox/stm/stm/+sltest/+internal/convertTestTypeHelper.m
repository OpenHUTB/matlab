


function convertTestTypeHelper(id,isTestCaseObject,varargin)
    try
        prevWarningState=warning('off','backtrace');
        oc=onCleanup(@()warning(prevWarningState));
        p=inputParser;


        if nargin==3
            addRequired(p,'Type',@validateTestCaseType);
        else
            addParameter(p,'Type','',@validateTestCaseType);
            addParameter(p,'RunOnTarget',{},@validateRunOnTarget);
        end
        p.parse(varargin{:});
        if(~ismember('Type',p.UsingDefaults))
            type=0;
            switch p.Results.Type
            case sltest.testmanager.TestCaseTypes.Equivalence
                type=1;
            case sltest.testmanager.TestCaseTypes.Baseline
                type=2;
            case sltest.testmanager.TestCaseTypes.Simulation
                type=0;
            case sltest.testmanager.TestCaseTypes.Scripted
                mustBeA(p.Results.Type,["sltest.testmanager.TestCaseTypes.Equivalence","sltest.testmanager.TestCaseTypes.Baseline","sltest.testmanager.TestCaseTypes.Simulation"]);
            end

            stm.internal.convertTestType(id,type);
        end
        if(nargin>3&&~ismember('RunOnTarget',p.UsingDefaults))
            runOnTarget=p.Results.RunOnTarget;
            if islogical(p.Results.RunOnTarget)
                runOnTarget={p.Results.RunOnTarget};
            end

            stm.internal.convertTestType(id,3,runOnTarget,isTestCaseObject);
        end
    catch ME
        throwAsCaller(ME);
    end
end

function validateRunOnTarget(x)
    validateattributes(x,{'logical','cell'},{});
    if~islogical(x)
        cellfun(@(a)isLogicalIfNotEmpty(a),x);
    end
end

function validateTestCaseType(x)
    validateattributes(x,...
    ["sltest.testmanager.TestCaseTypes","string"],{'scalar','nonempty'});
end

function isLogicalIfNotEmpty(a)
    if~isempty(a)
        validateattributes(a,{'logical'},{});
    end
end
