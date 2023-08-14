function out=getSignalDataValues(this,id,createEnums,doFlush)
    try
        if nargin<4||doFlush
            Simulink.sdi.internal.flushStreamingBackend();
        end
        if nargin<3
            out=this.sigRepository.getSignalDataValues(id);
        else
            sigObj=Simulink.sdi.getSignal(id);
            isComplex=strcmpi(sigObj.Complexity,'complex');
            isCollapsedSig=this.sigRepository.isUnexpandedMatrix(id);
            if isComplex&&~isCollapsedSig
                out=sigObj.Children(1).Values;
            else
                out=this.sigRepository.getSignalDataValues(id,createEnums);
            end
        end
    catch
        out=timeseries;
    end
end