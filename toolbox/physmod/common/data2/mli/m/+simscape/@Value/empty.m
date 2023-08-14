function out=empty(varargin)




    try
        out=simscape.Value(double.empty(varargin{:}));
    catch e
        throwAsCaller(e);
    end
end
