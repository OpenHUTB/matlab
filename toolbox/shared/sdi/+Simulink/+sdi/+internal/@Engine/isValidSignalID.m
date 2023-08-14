function out=isValidSignalID(this,id)
    if isempty(id)
        out=false;
    else
        out=this.sigRepository.isValidSignal(id);
    end
end