function closeDashboard()

    uiService=dashboard.UiService.get();
    if~isempty(uiService.Windows)
        for i=1:numel(uiService.Windows)


            uiService.Windows(1).close;
        end
    end

end

