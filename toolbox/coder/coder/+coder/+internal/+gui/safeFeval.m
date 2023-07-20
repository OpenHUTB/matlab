


function defaultValue=safeFeval(fname,defaultValue,varargin)



    if~isempty(which(fname))
        try
            defaultValue=feval(fname,varargin{:});
        catch
        end
    end
end
