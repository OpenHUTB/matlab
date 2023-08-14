
function addSymbol(testSequencePath,varargin)
    try
        p=inputParser;
        p.CaseSensitive=0;
        p.KeepUnmatched=0;
        p.PartialMatching=0;

        p.addRequired('name',@(x)validateattributes(x,{'char'},{'nonempty'}));
        p.addRequired('kind',@(x)ismember(x,{'Data','Message','Function Call','FunctionCall','Trigger'}));
        p.addRequired('scope',@(x)ismember(x,{'Input','Output','Local','Constant','Parameter','Data Store Memory','DataStoreMemory'}));
        p.parse(varargin{:});


        T=sltest.testsequence.internal.TestSequenceManager(testSequencePath);
        T.addSymbol(p.Results.kind,p.Results.scope,p.Results.name);
        clear T;
    catch ME
        throwAsCaller(ME);
    end
end