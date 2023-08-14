function varargout=lscftsh(varargin)













    minNumInputs=4;
    maxNumInputs=7;


    inputArguments=varargin;

    if nargin==1&&isa(varargin{1},'struct')
        error(message('optimlib:lscftsh:ProbStructUnsupported'))
    end
    if nargin>=minNumInputs
        if nargin<maxNumInputs


            inputArguments=[inputArguments,cell(1,maxNumInputs-nargin)];
        end

    end

    numberOfOutputArguments=max(nargout,1);

    varargout=cell(numberOfOutputArguments,1);
    [varargout{1:numberOfOutputArguments}]=lsqcurvefit(inputArguments{:});
