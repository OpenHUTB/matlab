function opts=getOptions(obj,varargin)





    opts=[];
    if any(obj.Type==["enum","enum_edit"])
        if nargin==1
            av=obj.AvailableValues();
        else
            av=obj.AvailableValues(varargin{1});
        end
        opts=configset.internal.util.convertToOptions(av);
    end
