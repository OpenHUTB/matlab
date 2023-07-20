function varargout=rationalfit(obj,varargin)


















    if nargin>=3&&isnumeric(varargin{1})&&isnumeric(varargin{2})
        i=varargin{1};
        j=varargin{2};

        validateattributes(i,{'numeric'},...
        {'integer','scalar','positive','<=',obj.NumPorts},'rationalfit','I',2)
        validateattributes(j,{'numeric'},...
        {'integer','scalar','positive','<=',obj.NumPorts},'rationalfit','J',3)

        [fit,errdb]=rationalfit(obj.Frequencies,rfparam(obj,i,j),varargin{3:end});
    else
        [fit,errdb]=rationalfit(obj.Frequencies,obj.Parameters,varargin{:});
    end

    varargout{1}=fit;
    if nargout>1
        varargout{2}=errdb;
    end
