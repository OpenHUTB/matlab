function out=getSignalChecked(this,id)
    out=this.sigRepository.getSignalChecked(id);
    out=~isempty(out);
end