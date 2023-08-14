function setStylesheetID(this,ss,varargin)














    propName=this.getStylesheetProperty(varargin{:});
    if isempty(propName)
        return;
    else
        if isa(ss,'RptgenML.StylesheetEditor')
            ss=ss.ID;
        end


        set(this,propName,ss);
    end


