function closeExplorer(this)




    if isa(this.MAExplorer,'DAStudio.Explorer')
        this.MAExplorer.hide;
    end
    if~isempty(this.AdvisorWindow)
        this.AdvisorWindow.close();
    end
