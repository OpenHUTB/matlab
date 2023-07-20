function dims=getSignalDimensions(this,sigName)
    dimsCell=regexp(sigName,this.DimsRx,'match');
    dimsStr=dimsCell{1};
    dimsStr=erase(dimsStr,'(');
    dimsStr=erase(dimsStr,')');
    dims=str2double(strsplit(dimsStr,','));
end