function varargout=alslnsh(varargin)













    minNumInputs=2;
    maxNumInputs=10;


    inputArguments=varargin;

    if nargin==1&&isa(varargin{1},'struct')
        error(message('optimlib:alslnsh:ProbStructUnsupported'))
    end
    if nargin>=minNumInputs
        if nargin<maxNumInputs


            inputArguments=[inputArguments,cell(1,maxNumInputs-nargin)];
        end

        inputArguments{maxNumInputs}.Algorithm='interior-point';
    end

    numberOfOutputArguments=max(nargout,1);

    varargout=cell(numberOfOutputArguments,1);
    [varargout{1:numberOfOutputArguments}]=lsqlin(inputArguments{:});