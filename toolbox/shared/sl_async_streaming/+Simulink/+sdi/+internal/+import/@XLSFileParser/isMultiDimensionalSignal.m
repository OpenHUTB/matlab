function isMultiDimensional=isMultiDimensionalSignal(this,sigName)
    isMultiDimensional=~isempty(regexp(sigName,this.DimsRx,'once'));
end