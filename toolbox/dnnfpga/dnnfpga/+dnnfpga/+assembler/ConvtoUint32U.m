



function uint32val=ConvtoUint32U(val)
%#codegen


    if isa(val,'uint32')
        uint32val=val;
    elseif isa(val,'logical')||isa(val,'uint8')||isa(val,'uint16')
        uint32val=uint32(val);
    elseif isa(val,'embedded.fi')
        assert((val.Signed+val.WordLength)<=32);
        if(val>=0)
            uint32val=uint32(val);
        else
            si=storedInteger(val);
            if isa(si,'int8')
                uint32val=int8([si,0,0,0]);
            elseif isa(si,'int16')
                uint32val=int16([si,0]);
            else
                assert(false);
                uint32val=int8([0,0,0,0]);
            end
        end
    elseif isa(val,'double')
        assert(false);
        uint32val=uint32(val);
    elseif isa(val,'single')
        uint32val=typecast(val,'uint32');
    elseif isa(val,'half')
        uint32val=typecast(val,'uint16');
    elseif isa(val,'int64')||isa(val,'uint64')
        uint32val=uint32(val);
    else
        assert(isnumeric(val));
        uint32val=uint32(val);
    end
end