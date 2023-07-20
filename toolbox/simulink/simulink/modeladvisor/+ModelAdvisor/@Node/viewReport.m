function viewReport(this,varargin)



    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    displayReport=1;
    if~isempty(this.MAObj)
        if nargin==1
            reportName=this.MAObj.generateReport(this);
        elseif strcmp(varargin{1},'lastReport')&&~isempty(this.MAObj.AtticData)&&~isempty(this.MAObj.AtticData.DiagnoseRightFrame)

            reportName=this.MAObj.AtticData.DiagnoseRightFrame;
        elseif strcmp(varargin{1},'saveas')
            displayReport=0;
            reportName=this.MAObj.generateReport(this);
        else


            reportName=this.MAObj.generateReport(this);
        end
        if(displayReport)
            this.MAObj.displayReport(reportName);
        end
    end




