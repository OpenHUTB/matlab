function viewObj=responseViewFactory(response,parentObj)




    switch response
    case 'lowpassfir'
        viewObj=signal.task.internal.designfilt.responseviews.LowpassFIRView(parentObj);
    case 'lowpassiir'
        viewObj=signal.task.internal.designfilt.responseviews.LowpassIIRView(parentObj);
    case 'highpassfir'
        viewObj=signal.task.internal.designfilt.responseviews.HighpassFIRView(parentObj);
    case 'highpassiir'
        viewObj=signal.task.internal.designfilt.responseviews.HighpassIIRView(parentObj);
    case 'bandpassfir'
        viewObj=signal.task.internal.designfilt.responseviews.BandpassFIRView(parentObj);
    case 'bandpassiir'
        viewObj=signal.task.internal.designfilt.responseviews.BandpassIIRView(parentObj);
    case 'bandstopfir'
        viewObj=signal.task.internal.designfilt.responseviews.BandstopFIRView(parentObj);
    case 'bandstopiir'
        viewObj=signal.task.internal.designfilt.responseviews.BandstopIIRView(parentObj);
    case 'differentiatorfir'
        viewObj=signal.task.internal.designfilt.responseviews.DifferentiatorFIRView(parentObj);
    case 'hilbertfir'
        viewObj=signal.task.internal.designfilt.responseviews.HilbertFIRView(parentObj);
    otherwise
        error(message('signal:task:designfiltTask:designfiltTask:ResponseViewNotAvailable'));
    end
