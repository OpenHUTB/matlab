function err=midiCloseControl(cid)



    assert(isa(cid,'double')&&isreal(cid));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        err=midimexif('midiCloseControl',cid);
    else

        err=coder.nullcopy(0);
        for i=1:numel(cid)
            err=coder.ceval('closeControlCpp',cid(i));
            if err<0
                break;
            end
        end

        coder.ceval('mexUnlock');
    end
end
