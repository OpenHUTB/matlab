function info=accessInternalInfo(action,data)





    persistent RTT_INTERNAL_RTT_INFO

    if isempty(RTT_INTERNAL_RTT_INFO)
        RTT_INTERNAL_RTT_INFO=0;
    end



    if isequal(get_param(bdroot,'SystemTargetFile'),'realtime.tlc')&&...
        isequal(get_param(bdroot,'SimulationMode'),'external')&&...
        isequal(get_param(bdroot,'SimulationStatus'),'initializing')
        if isequal(get_param(bdroot,'SystemTargetFile'),'realtime.tlc')||...
            isequal(get_param(bdroot,'SystemTargetFile'),'ert.tlc')&&...
            codertarget.target.isCoderTarget(bdroot);
            info=6119;
            return;
        end
    end

    info=0;

    if~isequal(nargin,0)
        switch action
        case 'isRTTselected'
            info=isequal(get_param(bdroot,'SystemTargetFile'),'realtime.tlc')||...
            isequal(get_param(bdroot,'SystemTargetFile'),'ert.tlc')&&...
            codertarget.target.isCoderTarget(bdroot);
        case 'isRTTinitialized'
            info=RTT_INTERNAL_RTT_INFO;
        case 'initializeRTT'
            if isequal(nargin,1)
                data=[];
            end
            if isequal(get_param(bdroot,'SystemTargetFile'),'ert.tlc')&&...
                codertarget.target.isCoderTarget(bdroot);
                data=6119;
            end
            RTT_INTERNAL_RTT_INFO=data;
        otherwise

        end
    end

end


