function this=CReport(varargin)




    this=RptgenML.CReport;
    if length(varargin)==1
        this.copyReport(varargin{1});
    else
        this.init(varargin{:});
    end