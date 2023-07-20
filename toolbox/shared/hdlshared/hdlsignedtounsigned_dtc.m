function[sig1,sig2,hdlsignals,hdlbody]=...
    hdlsignedtounsigned_dtc(in1,in2,out,rounding,saturation)











    sltype1=hdlsignalsltype(in1);
    [size1,bp1,signed1]=hdlwordsize(sltype1);

    sltype2=hdlsignalsltype(in2);
    [size2,bp2,signed2]=hdlwordsize(sltype2);

    outsltype=hdlsignalsltype(out);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);


    hdlsignals='';
    hdlbody='';




    if((signed1||signed2)&&~outsigned)&&(outsize~=1)&&(size1~=1)&&(size2~=1),


        name1=hdlsignalname(in1);
        outvtype=hdlsignalvtype(out);
        [temp1_name,temp1]=...
        hdlnewsignal([name1,'_unsigned_cast'],'block',-1,0,0,...
        outvtype,outsltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(temp1)];
        name2=hdlsignalname(in2);
        [temp2_name,temp2]=...
        hdlnewsignal([name2,'_unsigned_cast'],'block',-1,0,0,...
        outvtype,outsltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(temp2)];



        hdlbody1=hdldatatypeassignment(in1,temp1,rounding,saturation);
        hdlbody1=strrep(hdlbody1,'\n\n','\n');
        hdlbody2=hdldatatypeassignment(in2,temp2,rounding,saturation);
        hdlbody2=strrep(hdlbody2,'\n\n','\n');
        hdlbody=[hdlbody1,hdlbody2];


        sig1=temp1;
        sig2=temp2;
    else
        sig1=in1;
        sig2=in2;
    end

end
