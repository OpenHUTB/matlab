function varargout=aconstrsh(varargin)













    minNumInputs=4;
    maxNumInputs=10;


    inputArguments=varargin;

    if nargin==1&&isa(varargin{1},'struct')
        error(message('optimlib:aconstrsh:ProbStructUnsupported'))
    end
    if nargin>=minNumInputs
        if nargin<maxNumInputs


            inputArguments=[inputArguments,cell(1,maxNumInputs-nargin)];
        end

        inputArguments{maxNumInputs}.Algorithm='active-set';
    end

    numberOfOutputArguments=max(nargout,1);

    varargout=cell(numberOfOutputArguments,1);
    [varargout{1:numberOfOutputArguments}]=fmincon(inputArguments{:});
