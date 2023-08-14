function out=getRunMetaData(this,runID)
    if this.isValidRunID(runID)
        out.dateCreated=this.getRunDateCreated(runID);
        out.name=this.getRunNameTemplate(runID);
        out.tag=this.getRunTag(runID);
        out.description=this.getRunDescription(runID);
        out.version=this.sigRepository.getVersion(runID);
        out.simMode=this.getRunSimMode(runID);
        out.model=this.getRunModel(runID);
    else
        error(message('SDI:sdi:InvalidRunID'));
    end
end