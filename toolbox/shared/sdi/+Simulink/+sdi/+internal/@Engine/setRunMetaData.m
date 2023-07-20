function setRunMetaData(this,runID,metadata)
    if this.isValidRunID(runID)
        if isfield(metadata,'dateCreated')
            this.setRunDateCreated(runID,metadata.dateCreated);
        end

        if isfield(metadata,'simMode')
            this.setRunSimMode(runID,metadata.simMode);
        end

        if isfield(metadata,'model')
            this.setRunModel(runID,metadata.model);
        end
    else
        error(message('SDI:sdi:InvalidRunID'));
    end
end