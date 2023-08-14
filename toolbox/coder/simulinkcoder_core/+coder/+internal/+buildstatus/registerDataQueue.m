function registerDataQueue(dq)




    receiver=coder.internal.buildstatus.BuildStatusReceiver.getInstance;
    receiver.registerCallback([],dq);
end

