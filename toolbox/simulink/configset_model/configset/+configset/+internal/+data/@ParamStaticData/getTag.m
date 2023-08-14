function out=getTag(obj,varargin)



    narginchk(1,2);

    out=obj.v_Tag;

    if nargin==2&&~isempty(obj.f_Tag)
        cs=varargin{1};
        fn=str2func(obj.f_Tag);
        out=fn(cs,obj.Name);
    end

