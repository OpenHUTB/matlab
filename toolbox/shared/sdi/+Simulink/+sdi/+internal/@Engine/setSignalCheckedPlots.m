function setSignalCheckedPlots(this,id,val)
    if iscell(val)
        val=cell2mat(val);
    end
    val=shiftdim(val);
    this.sigRepository.setSignalChecked(id,uint8(val));
end