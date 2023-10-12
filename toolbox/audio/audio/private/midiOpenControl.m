function[cid,err]=midiOpenControl(control,initval,channel,sync,device)

    assert(isa(control,'double')&&isscalar(control)&&isreal(control));
    assert(-1<=control&&control<=127);


    assert(isa(initval,'double')&&isscalar(initval)&&isreal(initval));

    assert(isa(channel,'double')&&isscalar(channel)&&isreal(channel));
    assert(0<=channel&&channel<=16);

    assert(isa(device,'double')&&isscalar(device)&&isreal(device));
    assert(isa(sync,'logical')&&isscalar(sync));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        [cid,err]=midimexif('midiOpenControl',control,initval,channel,sync,device);
    else
        coder.ceval('mexLock');
        cid=coder.nullcopy(0);
        err=coder.nullcopy(0);
        err=coder.ceval('openControlCpp',control,initval,channel,device,sync,coder.wref(cid));
    end
end
