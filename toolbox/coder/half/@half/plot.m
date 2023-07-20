function hh=plot(varargin)







    c=todoublecell(varargin{:});
    h=plot(c{:});
    if nargout>0
        hh=h;
    end
end