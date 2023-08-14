function modelObj=responseModelFactory(response)




    switch response
    case 'lowpassfir'
        modelObj=signal.task.internal.designfilt.responsemodels.LowpassFIRModel;
    case 'lowpassiir'
        modelObj=signal.task.internal.designfilt.responsemodels.LowpassIIRModel;
    case 'highpassfir'
        modelObj=signal.task.internal.designfilt.responsemodels.HighpassFIRModel;
    case 'highpassiir'
        modelObj=signal.task.internal.designfilt.responsemodels.HighpassIIRModel;
    case 'bandpassfir'
        modelObj=signal.task.internal.designfilt.responsemodels.BandpassFIRModel;
    case 'bandpassiir'
        modelObj=signal.task.internal.designfilt.responsemodels.BandpassIIRModel;
    case 'bandstopfir'
        modelObj=signal.task.internal.designfilt.responsemodels.BandstopFIRModel;
    case 'bandstopiir'
        modelObj=signal.task.internal.designfilt.responsemodels.BandstopIIRModel;
    case 'differentiatorfir'
        modelObj=signal.task.internal.designfilt.responsemodels.DifferentiatorFIRModel;
    case 'hilbertfir'
        modelObj=signal.task.internal.designfilt.responsemodels.HilbertFIRModel;
    otherwise
        error(message('signal:task:designfiltTask:designfiltTask:ResponseModelNotAvailable'));
    end