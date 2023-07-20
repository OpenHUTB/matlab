function createDetailedReport(this,covdata)





    SLStudio.internal.ScopedStudioBlocker(getString(message('Slvnv:simcoverage:cvmodelview:GenerateCoverageDetails')));
    this.reportManager.createReport(covdata);
end