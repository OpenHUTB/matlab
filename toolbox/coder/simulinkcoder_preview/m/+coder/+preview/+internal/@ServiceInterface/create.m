function out=create(sourceDD,entryType,entryName)




    out=[];
    if coder.preview.internal.ServiceInterface.slfeature
        switch entryType
        case 'DataReceiverService'
            out=coder.preview.internal.ReceiverService(sourceDD,entryType,entryName);
        case 'DataSenderService'
            out=coder.preview.internal.SenderService(sourceDD,entryType,entryName);
        case 'DataTransferService'
            out=coder.preview.internal.DataTransferService(sourceDD,entryType,entryName);
        case 'TimerService'
            out=coder.preview.internal.TimerService(sourceDD,entryType,entryName);
        case 'ParameterTuningInterface'
            out=coder.preview.internal.ParameterTuningService(sourceDD,entryType,entryName);
        case{'ParameterArgumentTuningInterface'
            'MeasurementInterface'}
            out=coder.preview.internal.StorageClass(sourceDD,entryType,entryName);
        end
    end
    if isempty(out)

        out=coder.preview.internal.ServiceInterface(sourceDD);
    end


