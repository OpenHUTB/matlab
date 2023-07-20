function[hdlbody,hdlsignals]=hdlsubsub(in1,in2,out,rounding,saturation,realonly)




















    if nargin<6,
        realonly=false;
    end

    hdlbody='';
    hdlsignals='';

    if length(in1)~=1||length(in2)~=1
        error(message('HDLShared:directemit:arrayinputs'));
    end


    substyle.cast_before_sum=hdlgetparameter('cast_before_sum');

    if hdlgetparameter('isvhdl')
        substyle.isvhdl=1;
    elseif hdlgetparameter('isverilog'),
        substyle.isvhdl=0;
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end





    [hdlbodytmp,hdlsignalstmp]=subsubreals(in1,in2,out,rounding,saturation,...
    substyle);
    hdlbody=[hdlbody,hdlbodytmp];
    hdlsignals=[hdlsignals,hdlsignalstmp];



    cplxout=hdlsignaliscomplex(out);
    cplxin1=hdlsignaliscomplex(in1);
    cplxin2=hdlsignaliscomplex(in2);

    if cplxout&&~(realonly),

        if cplxin1&&cplxin2

            [hdlbodytmp,hdlsignalstmp]=subsubreals(hdlsignalimag(in1),hdlsignalimag(in2),hdlsignalimag(out),...
            rounding,saturation,substyle);
            hdlbody=[hdlbody,hdlbodytmp];
            hdlsignals=[hdlsignals,hdlsignalstmp];

        elseif cplxin1&&~cplxin2

            hdlbody=[hdlbody,hdlunaryminus(hdlsignalimag(in1),hdlsignalimag(out),rounding,saturation)];
        elseif~cplxin1&&cplxin2

            hdlbody=[hdlbody,hdlunaryminus(hdlsignalimag(in2),hdlsignalimag(out),rounding,saturation)];

        end

    end






    function[hdlbody,hdlsignals]=subsubreals(in1,in2,out,rounding,saturation,substyle)

        if substyle.isvhdl==1,
            if substyle.cast_before_sum==1,
                [hdlbody,hdlsignals]=vhdlsubsubrealrealbittrue(in1,in2,out,rounding,saturation);
            else
                [hdlbody,hdlsignals]=vhdlsubsubrealreal(in1,in2,out,rounding,saturation);
            end

        else
            if substyle.cast_before_sum==1,
                [hdlbody,hdlsignals]=verilogsubsubrealrealbittrue(in1,in2,out,rounding,saturation);
            else
                [hdlbody,hdlsignals]=verilogsubsubrealreal(in1,in2,out,rounding,saturation);
            end

        end



