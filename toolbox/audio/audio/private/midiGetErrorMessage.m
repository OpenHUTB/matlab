function msg=midiGetErrorMessage(err)

    assert(nargin==1);
    assert(isa(err,'double'));
    assert(isscalar(err));
    assert(isreal(err));

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        msg=midimexif('midiGetErrorMessage',err);
        msg=stripZeros(msg);
    else

        msg=char(zeros(1,256));
        coder.ceval('getErrorMessageCpp',int32(err),coder.wref(msg));
    end
end


function str=stripZeros(str)
    str=str(1:find([str,char(0)]==0,1)-1);
end

