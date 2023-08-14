function obj=LibraryCategory(catName,varargin)









    if(nargin>0)
        obj=feval(mfilename('class'));
        obj.CategoryName=catName;
        if~isempty(varargin)
            set(obj,varargin{:});
        end

    else



        obj=feval(mfilename('class'));

    end

