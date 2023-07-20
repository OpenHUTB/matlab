





















function obj=isequalwithequalnans(varargin)
    s=todoublecell(varargin{1:nargin});
    obj=isequalwithequalnans(s{:});%#ok<DISEQN>
end
