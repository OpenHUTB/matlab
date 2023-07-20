function msg=getMessage(cbinfo,id,varargin)
    if SLStudio.Utils.showInToolStrip(cbinfo)
        if nargin>2
            msg=message(id,varargin{:}).getString();
        else
            msg=id;
        end
    else
        msg=DAStudio.message(id,varargin{:});
    end
end