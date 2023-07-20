function[sid,success]=showSourceBlockInModel(this,id)
    sid=this.getSignalSID(id);
    bpath=this.getSignalBlockSource(id,true);
    portIdx=this.getSignalPortIndex(id);

    metaData.ID=id;
    metaData.domain=this.sigRepository.getSignalDomainType(id);
    metaData.IsAssessment=this.getMetaDataV2(id,'IsAssessment');
    metaData.IsStateflow=this.getMetaDataV2(id,'IsStateflow');
    metaData.SSIDNumber=this.getMetaDataV2(id,'SSIDNumber');

    metaData.cb=this.getHighlightCallback(metaData.domain);

    success=Simulink.sdi.internal.Engine.highlightSignal(sid,bpath,portIdx,metaData);
end
