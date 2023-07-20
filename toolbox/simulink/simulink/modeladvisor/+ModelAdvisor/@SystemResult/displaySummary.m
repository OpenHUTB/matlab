function displaySummary(this,varargin)











    modeladvisorprivate('cacheHTMLdata','set',{this});
    if(isempty(this.report))
        disp(DAStudio.message('ModelAdvisor:engine:ReportNotExists'));
    else
        fprintf([this.report,'\n']);
        if nargin>1&&~strcmp(varargin{1},'NoSummaryLink')&&~isempty(dbstack(1))
            fprintf('<a href="matlab: modeladvisorprivate cacheHTMLdata summaryReport">Summary Report</a>\n')
        end
    end
end

