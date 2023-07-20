function metadata=getMetaData(this,id)
    metadata=this.sigRepository.getSignalMetaData(id,'__METADATA__');
end