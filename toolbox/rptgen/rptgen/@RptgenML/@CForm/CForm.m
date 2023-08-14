function this=CForm(varargin)




    this=RptgenML.CForm;
    if length(varargin)==1
        this.copyReport(varargin{1});
    else
        this.init(varargin{:});
    end