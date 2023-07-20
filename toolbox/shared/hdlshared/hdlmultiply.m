function[hdlbody,hdlsignals]=hdlmultiply(in1,in2,out,rounding,saturation,realonly)











    if length(in1)~=1||length(in2)~=1
        error(message('HDLShared:directemit:arraymultnotsupported'));
    end

    if nargin<6
        realonly=false;
    end


    if hdlsignaliscomplex(in1)==1&&hdlsignaliscomplex(in2)==1&&~realonly
        [hdlbody,hdlsignals]=hdlmultiplycomplexcomplex(in1,in2,out,rounding,saturation);
    elseif hdlsignaliscomplex(in1)==1&&~realonly
        [hdlbody,hdlsignals]=hdlmultiplycomplexreal(in1,in2,out,rounding,saturation);
    elseif hdlsignaliscomplex(in2)==1&&~realonly

        [hdlbody,hdlsignals]=hdlmultiplycomplexreal(in2,in1,out,rounding,saturation);
    else

        [hdlbody,hdlsignals]=hdlmultiplyrealreal(in1,in2,out,rounding,saturation);
    end

