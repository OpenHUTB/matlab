function varargout=mdnlsh(varargin)













    inputArguments=varargin;

    if nargin==1&&isstruct(varargin{1})
        error(message('optimlib:aconstrsh:ProbStructUnsupported'))
    end

    expNumInputs=3;





    inputArguments{expNumInputs}.Algorithm='quasi-newton';
    if~iscell(inputArguments{expNumInputs}.HessUpdate)
        inputArguments{expNumInputs}.HessUpdate='lbfgs';
    else
        inputArguments{expNumInputs}.HessUpdate{1}='lbfgs';
    end

    numberOfOutputArguments=max(nargout,1);

    varargout=cell(numberOfOutputArguments,1);
    [varargout{1:numberOfOutputArguments}]=fminunc(inputArguments{:});
