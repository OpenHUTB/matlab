function varargout=scdconstrsh(varargin)





    numberOfOutputArguments=max(nargout,1);

    varargout=cell(numberOfOutputArguments,1);
    [varargout{1:numberOfOutputArguments}]=aconstrsh(varargin{:});