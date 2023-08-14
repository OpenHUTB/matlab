function c=todoublecell(varargin)






    c=varargin;
    for k=1:nargin
        if isa(varargin{k},'half')
            c{k}=double(varargin{k});
        end
    end
end