



















function obj=nan(varargin)
    if(nargin==0)
        s=1;
    elseif(nargin==1)
        s=varargin{1};
    else
        s=coder.nullcopy(zeros([1,nargin-1]));
        for ii=1:nargin
            s(ii)=varargin{ii};
        end
    end

    obj=half.typecast(ones(s,'uint16').*32256);
end
