function[status,errorMsg,cc,messageId]=validateGpuDevice()




    status=true;
    cc='';
    errorMsg='';
    messageId='';

    numGpu=gpuDeviceCount;
    if numGpu>0
        try
            gDev=gpuDevice;
            cc=gDev.ComputeCapability;
            idx=gDev.Index;
        catch e
            messageId=e.message;
            msgString=string(messageId);
            status=false;
        end


        if(status)
            if(~gDev.DeviceSupported)
                messageId=message('gpucoder:system:unsupported_gpu_accel',idx);
                msgString=string(messageId);
                status=false;
            else

                ccMaj=str2double(cc(1));
                ccMin=str2double(cc(3));
                if((ccMaj<3)||((ccMaj==3)&&(ccMin<2)))
                    messageId=message('gpucoder:system:unsupported_cc_accel',idx,cc);
                    msgString=string(messageId);
                    status=false;
                end
            end
        end
    else
        messageId=message('gpucoder:system:no_gpus_dlaccel');
        msgString=string(messageId);
        status=false;
    end

    if(~status)
        errorMsg=msgString;
    end

end
