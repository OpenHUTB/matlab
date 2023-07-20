function h=ComponentMaker(varargin)




    h=feval(mfilename('class'));

    if length(varargin)==1
        if isa(varargin{1},'rptgen.rptcomponent')
            h.loadComponent(varargin{1});
        else
            h.v1convert(varargin{1});
        end
    else
        set(h,varargin{:});
    end