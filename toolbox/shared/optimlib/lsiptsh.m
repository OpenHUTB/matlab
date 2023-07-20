function varargout=lsiptsh(varargin)













    minNumInputs=2;
    maxNumInputs=5;


    inputArguments=varargin;

    if nargin==1&&isa(varargin{1},'struct')
        error('optimlib:lsiptsh:ProbStructUnsupported',...
        getString(message('optimlib:lscftsh:ProbStructUnsupported')));
    end
    if nargin>=minNumInputs
        if nargin<maxNumInputs


            inputArguments=[inputArguments,cell(1,maxNumInputs-nargin)];
        end

    end

    numberOfOutputArguments=max(nargout,1);

    varargout=cell(numberOfOutputArguments,1);
    [varargout{1:numberOfOutputArguments}]=lsqnonlin(inputArguments{:});
