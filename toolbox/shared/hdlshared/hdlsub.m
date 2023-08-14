function[hdlbody,hdlsignals]=hdlsub(in1,in2,out,rounding,saturation,realonly)





















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





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode




        [hdlbodytmp,hdlsignalstmp]=subreals(in1,in2,out,rounding,saturation,...
        substyle);
        hdlbody=[hdlbody,hdlbodytmp];
        hdlsignals=[hdlsignals,hdlsignalstmp];



        cplxout=hdlsignaliscomplex(out);
        cplxin1=hdlsignaliscomplex(in1);
        cplxin2=hdlsignaliscomplex(in2);

        if cplxout&&~(realonly),

            if cplxin1&&cplxin2

                [hdlbodytmp,hdlsignalstmp]=subreals(hdlsignalimag(in1),hdlsignalimag(in2),hdlsignalimag(out),...
                rounding,saturation,substyle);
                hdlbody=[hdlbody,hdlbodytmp];
                hdlsignals=[hdlsignals,hdlsignalstmp];

            elseif cplxin1&&~cplxin2

                hdlbody=[hdlbody,hdldatatypeassignment(in1,out,rounding,saturation,[],'imag')];

            elseif~cplxin1&&cplxin2

                [hdlbodytmp,hdlsignalstmp]=hdlunaryminus(hdlsignalimag(in2),hdlsignalimag(out),rounding,saturation);
                hdlbody=[hdlbody,hdlbodytmp];
                hdlsignals=[hdlsignals,hdlsignalstmp];

            end

        end
    else
        if saturation==0
            satMode='Wrap';
        else
            satMode='Saturate';
        end
        rounding(1)=upper(rounding(1));

        if substyle.cast_before_sum==1
            if isAdderFullPrecision(in1,in2,out)
                pirelab.getAddComp(hN,[in1,in2],out,rounding,satMode,'Sub',[],'+-');
            else
                if hdlsignalisdouble(out)
                    hT=out.Type;
                else
                    sltypeout=hdlsignalsltype(out);
                    [outsize,outbp,out2sgn]=hdlgetsizesfromtype(sltypeout);
                    hT=pir_fixpt_t(out2sgn,outsize+1,-outbp);

                    if strcmp(out.Type.ClassName,'tp_complex')
                        hT=hN.getType('Complex','BaseType',hT);
                    elseif strcmp(out.Type.ClassName,'tp_array')
                        if strcmp(out.Type.BaseType.ClassName,'tp_complex')
                            hT=hN.getType('Complex','BaseType',hT);
                        end
                        hT=hN.getType('Array','BaseType',hT,'dimensions',out.Type.getDimensions);
                    end
                end



                tempSignalin1=hN.addSignal(out.Type,[out.Name,'_cast1']);
                tempSignalin1.SimulinkRate=in1.SimulinkRate;
                tempSignalin2=hN.addSignal(out.Type,[out.Name,'_cast2']);
                tempSignalin2.SimulinkRate=in2.SimulinkRate;
                tempSignalsum=hN.addSignal(hT,[out.Name,'_temp']);
                tempSignalsum.SimulinkRate=out.SimulinkRate;
                pirelab.getDTCComp(hN,in1,tempSignalin1,rounding,saturation);
                pirelab.getDTCComp(hN,in2,tempSignalin2,rounding,saturation);
                pirelab.getAddComp(hN,[tempSignalin1,tempSignalin2],tempSignalsum,rounding,satMode,'Sub',[],'+-');
                pirelab.getDTCComp(hN,tempSignalsum,out,rounding,saturation);
            end
        else
            pirelab.getAddComp(hN,[in1,in2],out,rounding,satMode,'Sub',[],'+-');
        end
    end




    function[hdlbody,hdlsignals]=subreals(in1,in2,out,rounding,saturation,substyle)





        hN=pirNetworkForFilterComp;
        emitMode=isempty(hN);

        hdlbody='';
        hdlsignals='';

        if emitMode
            if substyle.isvhdl==1,
                if substyle.cast_before_sum==1,
                    [hdlbody,hdlsignals]=vhdlsubrealrealbittrue(in1,in2,out,rounding,saturation);
                else
                    [hdlbody,hdlsignals]=vhdlsubrealreal(in1,in2,out,rounding,saturation);
                end

            else
                if substyle.cast_before_sum==1,
                    [hdlbody,hdlsignals]=verilogsubrealrealbittrue(in1,in2,out,rounding,saturation);
                else
                    [hdlbody,hdlsignals]=verilogsubrealreal(in1,in2,out,rounding,saturation);
                end

            end
        else

            pirelab.getSubComp(hN,[in1,in2],out,...
            rounding,saturation,'subtractor');
        end



