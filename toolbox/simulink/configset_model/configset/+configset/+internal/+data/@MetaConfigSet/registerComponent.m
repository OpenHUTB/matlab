function out=registerComponent(varargin)














    mlock;
    persistent m;

    narginchk(0,2);

    if isempty(m)
        m=containers.Map('KeyType','char','ValueType','char');
    end

    switch(nargin)
    case 2
        id=varargin{1};
        componentPath=varargin{2};
        m(id)=componentPath;
        out=true;

    case 1
        id=varargin{1};
        if m.isKey(id)
            out=m(id);
        else
            out='';
        end

    case 0
        out=m.keys;
    end

