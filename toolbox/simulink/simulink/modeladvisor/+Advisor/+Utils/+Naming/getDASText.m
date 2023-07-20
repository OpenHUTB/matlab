






function text=getDASText(prefix,id,varargin)
    try
        text=DAStudio.message([prefix,id],varargin{:});
    catch
        text=['[id::',id,']'];
    end
end


