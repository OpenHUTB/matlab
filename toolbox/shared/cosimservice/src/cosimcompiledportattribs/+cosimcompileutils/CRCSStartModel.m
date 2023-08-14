
function startModelStruct=CRCSStartModel(wrapperModelName)
    startModelStruct=struct('isError',false,'errorMsg','');



    listener.interceptor=Simulink.output.StorageInterceptorCb();


    listener.scope=Simulink.output.registerProcessor(listener.interceptor);


    Simulink.sdi.clear;

    set_param(wrapperModelName,'SimulationCommand','Start');


    msgs=listener.interceptor.getInterceptedMsg;
    errorsSeen=[];
    for i=1:length(msgs)
        m=msgs(i);
        if isequal(m.Severity,'ERROR')
            ME=MException(m.MessageId,m.Message);
            errorsSeen=[errorsSeen,ME];

        end
    end
    if~isempty(errorsSeen)
        startModelStruct.isError=true;
        startModelStruct.errorMsg=jsonencode(errorsSeen);
    end


    cleanup=onCleanup(@()clear('listener','errorsSeen'));
end
