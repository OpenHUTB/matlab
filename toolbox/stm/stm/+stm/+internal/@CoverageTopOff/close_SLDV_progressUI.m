

function close_SLDV_progressUI(refMdl)
    try
        sldvData=get_param(refMdl,'AutoVerifyData');
    catch
        sldvData=[];
    end
    if isfield(sldvData,'ui')&&ishandle(sldvData.ui)
        delete(sldvData.ui);
    end
end
