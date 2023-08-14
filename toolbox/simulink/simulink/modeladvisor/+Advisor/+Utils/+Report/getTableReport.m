function report=getTableReport(arrayOfViolations,msgCatalogTag,varargin)






    assert(~isempty(arrayOfViolations),DAStudio.message('ModelAdvisor:engine:EmptyViolations'));

    if nargin>2

        colTitles=varargin{1};

    else
        [~,cols]=size(arrayOfViolations);
        colTitles=cell(cols,1);

        for idx=1:cols
            colTitles{idx}=DAStudio.message([msgCatalogTag,'_colTitle',num2str(idx)]);
        end
    end

    report=ModelAdvisor.FormatTemplate('TableTemplate');
    report.setSubTitle(DAStudio.message([msgCatalogTag,'_subtitle']))
    report.setSubBar(false);
    report.setColTitles(colTitles);
    report.setSubResultStatus('Warn');
    report.setSubResultStatusText(DAStudio.message([msgCatalogTag,'_warn']));
    report.setTableInfo(arrayOfViolations);
    report.setRecAction(DAStudio.message([msgCatalogTag,'_recAction']));
end
