
function setBusElementPortAttributes(this,srcBepObj,dstBepH,setMqAttributes)





    set_param(dstBepH,'OutDataTypeStr',srcBepObj.OutDataTypeStr);

    set_param(dstBepH,'PortDimensions',srcBepObj.PortDimensions);
    set_param(dstBepH,'SampleTime',srcBepObj.SampleTime);

    set_param(dstBepH,'VarSizeSig',srcBepObj.VarSizeSig);
    set_param(dstBepH,'Unit',srcBepObj.Unit);
    set_param(dstBepH,'SignalType',srcBepObj.SignalType);
    set_param(dstBepH,'OutMin',srcBepObj.OutMin);
    set_param(dstBepH,'OutMax',srcBepObj.OutMax);
    set_param(dstBepH,'Description',srcBepObj.Description);
    if~strcmp(srcBepObj.BusVirtuality,'inherit')
        set_param(dstBepH,'BusVirtuality',srcBepObj.BusVirtuality);
    end


    if setMqAttributes
        set_param(dstBepH,'DataMode',srcBepObj.DataMode);
        if strcmp(srcBepObj.DataMode,'message')
            set_param(dstBepH,'MessageQueueUseDefaultAttributes',srcBepObj.MessageQueueUseDefaultAttributes);
        end
        set_param(dstBepH,'MessageQueueCapacity',srcBepObj.MessageQueueCapacity);
        set_param(dstBepH,'MessageQueueType',srcBepObj.MessageQueueType);
        set_param(dstBepH,'MessageQueueOverwriting',srcBepObj.MessageQueueOverwriting);
    end


end


