function out=getSignalInterpMethod(this,id)
    interpValue=this.sigRepository.getSignalInterpMethod(id);
    if this.sigRepository.getSignalIsEventBased(id)
        interpValue='none';
    end
    out=interpValue;
end