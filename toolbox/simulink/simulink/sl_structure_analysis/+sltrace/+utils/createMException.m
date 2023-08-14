
function[ME,varargout]=createMException(errID,varargin)
    for i=1:length(varargin)
        varargin{i}=num2str(varargin{i});
    end

    switch nargin
    case 1
        msg=message(errID);
    case 2
        msg=message(errID,varargin{1});
    case 3
        msg=message(errID,varargin{1},varargin{2});
    case 4
        msg=message(errID,varargin{1},varargin{2},varargin{3});
    case 5
        msg=message(errID,varargin{1},varargin{2},varargin{3},varargin{4});
    otherwise
        msg=message(errID);
    end

    ME=MException(errID,msg);
    varargout{1}=msg;
end