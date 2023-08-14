function h=plotxy(this,varargin)














    try
        h=simscape.logging.plotxy(this,varargin{:});
    catch ME
        ME.throwAsCaller();
    end

end
