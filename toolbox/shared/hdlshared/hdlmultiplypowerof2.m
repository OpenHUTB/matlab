function[hdlbody,hdlsignals]=hdlmultiplypowerof2(in1,powerof2,out,rounding,saturation,mode)








    gConnOld=hdlconnectivity.genConnectivity(0);

    hdlbody='';
    hdlsignals='';

    [assign_prefix,assign_op]=hdlassignforoutput(out);
    comment_char=hdlgetparameter('comment_char');

    name1=hdlsignalname(in1);
    handle1=hdlsignalhandle(in1);
    vector1=hdlsignalvector(in1);
    vtype1=hdlsignalvtype(in1);
    sltype1=hdlsignalsltype(in1);
    [size1,bp1,signed1]=hdlwordsize(sltype1);

    outname=hdlsignalname(out);
    outhandle=hdlsignalhandle(out);
    outvector=hdlsignalvector(out);
    outvtype=hdlsignalvtype(out);
    outsltype=hdlsignalsltype(out);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);

    if nargin<6
        if~hdl.ispowerof2(powerof2)
            error(message('HDLShared:directemit:nonpowerof2',num2str(powerof2)));
        elseif size1==0
            error(message('HDLShared:directemit:realinput','hdlmultiplypowerof2',name1));
        elseif size1==1
            error(message('HDLShared:directemit:booleaninputpow2',name1));
        end
        shift_amount=hdl.ceillog2(powerof2);
    else
        shift_amount=powerof2;
        powerof2=0;
    end

    [newname,newsize]=hdlsignaltypeconvert(name1,size1,signed1,vtype1,outsigned);
    newbp=bp1-shift_amount;
    [newvtype,newsltype]=hdlgettypesfromsizes(newsize,newbp,signed1);



























    if powerof2<0
        [minusvtype,minussltype]=hdlgettypesfromsizes(newsize+1,bp1,signed1);
        [tempminus,tempminus_ptr]=hdlnewsignal('mulpwr2_temp','block',-1,0,0,minusvtype,minussltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(tempminus_ptr)];
        [tempbody,tempsignals]=hdlunaryminus(in1,tempminus_ptr,rounding,saturation);
        hdlbody=[hdlbody,tempbody];
        hdlsignals=[hdlsignals,tempsignals];

        final_result=hdltypeconvert(tempminus,newsize+1,newbp,outsigned,minusvtype,...
        outsize,outbp,outsigned,outvtype,...
        rounding,saturation);
        hdlbody=[hdlbody,'  ',assign_prefix,outname,' ',assign_op,' ',final_result,';\n\n'];





        if gConnOld,
            hConnDir=hdlconnectivity.getConnectivityDirector;


            satin=regexptranslate('escape',tempminus);
            if~isempty(regexp(final_result,satin,'once')),
                hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
            end

        end


    else

        final_result=hdltypeconvert(newname,newsize,newbp,outsigned,newvtype,...
        outsize,outbp,outsigned,outvtype,...
        rounding,saturation);
        if~strcmpi(outname,final_result)
            hdlbody=[hdlbody,'  ',assign_prefix,outname,' ',assign_op,' ',final_result,';\n\n'];





            if gConnOld,
                hConnDir=hdlconnectivity.getConnectivityDirector;


                satin=regexptranslate('escape',newname);
                if~isempty(regexp(final_result,satin,'once')),
                    hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
                end

            end


        end
    end





    hdlconnectivity.genConnectivity(gConnOld);



