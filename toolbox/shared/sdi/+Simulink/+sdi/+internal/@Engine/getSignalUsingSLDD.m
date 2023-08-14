
function out=getSignalUsingSLDD(this,sigID)
    out.DataID=sigID;
    out.RunID=this.sigRepository.getSignalRunID(sigID);
    out.SourceType=this.sigRepository.getSignalSourceType(sigID);
    out.RootSource=this.sigRepository.getSignalRootSource(sigID);
    out.TimeSource=this.sigRepository.getSignalTimeSource(sigID);
    out.DataSource=this.sigRepository.getSignalDataSource(sigID);
    out.BlockSource=this.sigRepository.getSignalBlockSource(sigID);
    out.ModelSource=this.sigRepository.getSignalModelSource(sigID);
    out.SignalLabel=this.sigRepository.getSignalLabel(sigID);
    out.TimeDim=this.sigRepository.getSignalTimeDim(sigID);
    out.SampleDims=this.sigRepository.getSignalSampleDims(sigID);
    out.PortIndex=this.sigRepository.getSignalPortIndex(sigID);
    out.Channel=this.sigRepository.getSignalChannel(sigID);
    out.Units=this.sigRepository.getUnit(sigID);
    out.SID=this.sigRepository.getSignalSID(sigID);
    out.HierarchyReference=this.sigRepository.getSignalHierarchyReference(sigID);
    out.LineColor=this.sigRepository.getSignalLineColor(sigID);
    out.LineDashed=this.sigRepository.getSignalLineDashed(sigID);
    out.LineWidth=this.sigRepository.getSignalLineWidth(sigID);
    out.MetaData=this.sigRepository.getSignalMetaData(sigID,'__METADATA__');
    out.ParentID=this.sigRepository.getSignalParent(sigID);
    out.rootDataSrc=this.sigRepository.getSignalRootSource(sigID);
    out.DataValues=this.sigRepository.getSignalDataValues(sigID);



    sig=Simulink.sdi.Signal(this,sigID);
    out.BlockSource=sig.blockSource;
end