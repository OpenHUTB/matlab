function[val,ctl,chn,err]=midiReadLastControl(cid)



    assert(isa(cid,'double')&&isscalar(cid)&&isreal(cid));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        [val,ctl,chn,err]=midimexif('midiReadLastControl',cid);
    else

        val=coder.nullcopy(0);
        ctl=coder.nullcopy(0);
        chn=coder.nullcopy(0);
        err=coder.nullcopy(0);
        err=coder.ceval('readLastControlCpp',cid,coder.wref(val),coder.wref(ctl),coder.wref(chn));
    end
end
