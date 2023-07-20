function changeExclusionFile(this)

    if Simulink.harness.internal.hasActiveHarness(this.getModelName())
        MSLDiagnostic('Simulink:Harness:CannotEditModelAsTestingHarnessIsActive',...
        this.getModelName()).reportAsWarning;
        return;
    end

    browseDlg=ModelAdvisor.BrowseExclusionFile(this);
    browseDlg.show;
    this.browseDlg=browseDlg;
