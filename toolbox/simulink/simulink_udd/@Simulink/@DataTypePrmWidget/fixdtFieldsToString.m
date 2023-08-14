
function dataTypeString=fixdtFieldsToString(varargin)




























    assert(nargin<=4||nargin>=2,...
    'fixdt must have 2-4 arguments.');

    iArg=1;
    sign=varargin{iArg};

    iArg=iArg+1;
    wordLength=varargin{iArg};

    iArg=iArg+1;
    switch nargin
    case 2
        dataTypeString=['fixdt(',sign,',',wordLength,')'];
    case 3
        fractionLength=varargin{iArg};
        dataTypeString=['fixdt(',sign,',',wordLength,',',fractionLength,')'];
    case 4
        slope=varargin{iArg};
        bias=varargin{iArg+1};
        dataTypeString=['fixdt(',sign,',',wordLength,',',slope,',',bias,')'];
    end




