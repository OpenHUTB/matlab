function applyCB(this,dlg)



    if~isempty(this.SigInfo)
        this.applyVisualizationProperties(dlg);
        this.applyDataAccessProperties(dlg);
        this.applyTolerances(dlg);
    end

    dlg.enableApplyButton(false);
end
