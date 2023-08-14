






function text=getText(this,id,varargin)
    try
        text=DAStudio.message([this.prefix,id],varargin{:});
    catch
        text=['[id::',id,']'];
    end
end


