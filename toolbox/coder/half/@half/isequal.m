


































function obj=isequal(varargin)
    s=todoublecell(varargin{1:nargin});
    obj=isequal(s{:});
end
