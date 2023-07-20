function[hdlbody,hdlsignals]=hdlfilterunaryminus(in,out,rounding,saturation,realonly)






    if nargin<5,
        realonly=false;
    end

    [hdlbody,hdlsignals]=hdlunaryminus(in,out,rounding,saturation,realonly);



