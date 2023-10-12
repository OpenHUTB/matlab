function midiSyncControl(cid,val)
    assert(isa(cid,'double')&&isreal(cid));
    assert(isa(val,'double')&&isreal(val));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        midimexif('midiSyncControl',cid,val);
    else

        coder.ceval('syncControlCpp',cid,val);
    end
end
