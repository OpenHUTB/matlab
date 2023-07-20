function paneName=getParamDisplayPath(obj,name,varargin)






    if nargin>2&&~isempty(varargin{1})
        paneObject=getParamPane(obj,name,varargin{1});
    else
        paneObject=getParamPane(obj,name);
    end

    paneName=obj.getPaneDisplayPath(paneObject.Name,varargin{2:end});


