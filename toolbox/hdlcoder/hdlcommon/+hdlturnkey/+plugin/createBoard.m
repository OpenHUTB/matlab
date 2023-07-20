function hBoard=createBoard(varargin)





    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    p=inputParser;
    p.addParameter('Workflow','IP Core Generation');
    p.addParameter('IsGenericIPPlatform',false);
    p.parse(varargin{:});
    inputArgs=p.Results;

    workflowName=inputArgs.Workflow;
    isGeneric=inputArgs.IsGenericIPPlatform;

    if strcmpi(workflowName,'IP Core Generation')
        hBoard=hdlturnkey.plugin.BoardIP(isGeneric);
    else
        error(message('hdlcommon:plugin:InvalidWorkflow',workflowName));
    end


end

