function[hdlbody,hdlsignals]=hdladd(in1,in2,out,rounding,saturation,realonly)






















    if nargin<6
        realonly=false;
    end

    hdlbody='';
    hdlsignals='';

    if length(in1)~=1||length(in2)~=1
        error(message('HDLShared:directemit:arrayinputs'));
    end


    addstyle.cast_before_sum=hdlgetparameter('cast_before_sum');

    if hdlgetparameter('isvhdl')
        addstyle.isvhdl=1;
    elseif hdlgetparameter('isverilog')
        addstyle.isvhdl=0;
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode




        [hdlbodytmp,hdlsignalstmp]=addreals(in1,in2,out,rounding,saturation,addstyle);
        hdlbody=[hdlbody,hdlbodytmp];
        hdlsignals=[hdlsignals,hdlsignalstmp];



        cplxout=hdlsignaliscomplex(out);
        cplxin1=hdlsignaliscomplex(in1);
        cplxin2=hdlsignaliscomplex(in2);

        if cplxout&&~(realonly)

            if cplxin1&&cplxin2

                [hdlbodytmp,hdlsignalstmp]=addreals(hdlsignalimag(in1),hdlsignalimag(in2),hdlsignalimag(out),...
                rounding,saturation,addstyle);
                hdlbody=[hdlbody,hdlbodytmp];
                hdlsignals=[hdlsignals,hdlsignalstmp];

            elseif cplxin1&&~cplxin2
                hdlbody=[hdlbody,hdldatatypeassignment(in1,out,rounding,saturation,[],'imag')];

            elseif~cplxin1&&cplxin2
                hdlbody=[hdlbody,hdldatatypeassignment(in2,out,rounding,saturation,[],'imag')];

            end

        end
    else
        if saturation==0
            satMode='Wrap';
        else
            satMode='Saturate';
        end
        rounding(1)=upper(rounding(1));

        pirelab.getAddComp(hN,[in1,in2],out,rounding,satMode);

    end







    function[hdlbody,hdlsignals]=addreals(in1,in2,out,rounding,saturation,addstyle)

        if addstyle.isvhdl==1
            if addstyle.cast_before_sum==1
                if isAdderFullPrecision(in1,in2,out)
                    [hdlbody,hdlsignals]=vhdladdrealreal(in1,in2,out,rounding,saturation);
                else
                    [hdlbody,hdlsignals]=vhdladdrealrealbittrue(in1,in2,out,rounding,saturation);
                end
            else
                [hdlbody,hdlsignals]=vhdladdrealreal(in1,in2,out,rounding,saturation);
            end

        else
            if addstyle.cast_before_sum==1
                if isAdderFullPrecision(in1,in2,out)
                    [hdlbody,hdlsignals]=verilogaddrealreal(in1,in2,out,rounding,saturation);
                else
                    [hdlbody,hdlsignals]=verilogaddrealrealbittrue(in1,in2,out,rounding,saturation);
                end
            else
                [hdlbody,hdlsignals]=verilogaddrealreal(in1,in2,out,rounding,saturation);
            end

        end


