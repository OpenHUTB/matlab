
function init(hModel,type,varargin)

    o=get_param(hModel,'Object');

    if nargin==2
        o.init(type);
    else
        o.init(type,varargin{:});
    end
end