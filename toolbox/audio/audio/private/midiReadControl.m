function[val,err]=midiReadControl(cid)



    assert(isa(cid,'double')&&isscalar(cid)&&isreal(cid));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        [val,err]=midimexif('midiReadControl',cid);
    else

        val=coder.nullcopy(0);
        err=coder.nullcopy(0);
        err=coder.ceval('readControlCpp',cid,coder.wref(val));
    end
end
