function[bResultStatus,tableOfResults]=getTwoColumnReport(msgCatalogTagPrefix,conflictDetails,varargin)








    [~,cols]=size(conflictDetails);
    if nargin>2

        colTitles=varargin{1};

    else
        colTitles=cell(cols);
        for idx=1:cols
            colTitles{idx}=DAStudio.message([msgCatalogTagPrefix,'_colTitle',num2str(idx)]);
        end
    end

    bResultStatus=false;
    tableOfResults=ModelAdvisor.FormatTemplate('TableTemplate');
    tableOfResults.setInformation(DAStudio.message([msgCatalogTagPrefix,'_subtitle']))
    tableOfResults.setSubBar(false);
    tableOfResults.setColTitles(colTitles);

    if isempty(conflictDetails)
        tableOfResults.setSubResultStatus('Pass');
        tableOfResults.setSubResultStatusText(DAStudio.message([msgCatalogTagPrefix,'_pass']));
        bResultStatus=true;
    else
        tableOfResults.setSubResultStatus('Warn');
        tableOfResults.setSubResultStatusText(DAStudio.message([msgCatalogTagPrefix,'_fail']));
        tableOfResults.setTableInfo(conflictDetails);
        tableOfResults.setRecAction(DAStudio.message([msgCatalogTagPrefix,'_recAction']));
    end
end
