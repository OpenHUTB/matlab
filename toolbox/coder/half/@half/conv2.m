function obj=conv2(varargin)
















    narginchk(2,4)

    if nargin==2
        obj=half(conv2(single(varargin{1}),single(varargin{2})));
    elseif nargin==3
        if isa(varargin{3},'char')||isstring(varargin{3})
            obj=half(conv2(single(varargin{1}),single(varargin{2}),varargin{3}));
        else
            obj=half(conv2(single(varargin{1}),single(varargin{2}),single(varargin{3})));
        end
    else
        obj=half(conv2(single(varargin{1}),single(varargin{2}),single(varargin{3}),varargin{4}));
    end





