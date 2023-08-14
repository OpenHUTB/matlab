function[hdlbody,hdlsignals]=hdladdsub(in1,in2,subtractin,out,rounding,saturation,mode)










    hdlbody='';
    hdlsignals='';

    if nargin<6
        mode='select';
    end

    outvtype=hdlsignalvtype(out);
    outsltype=hdlsignalsltype(out);

    [ignored,addtemp]=hdlnewsignal('addsub_add','block',-1,0,0,outvtype,outsltype);%#ok
    [ignored,subtemp]=hdlnewsignal('addsub_sub','block',-1,0,0,outvtype,outsltype);%#ok

    hdlsignals=[hdlsignals,makehdlsignaldecl(addtemp)];
    hdlsignals=[hdlsignals,makehdlsignaldecl(subtemp)];

    [tmpbody,tmpsignals]=hdladd(in1,in2,addtemp,rounding,saturation);
    hdlbody=[hdlbody,tmpbody];
    hdlsignals=[hdlsignals,tmpsignals];

    [tmpbody,tmpsignals]=hdlsub(in1,in2,subtemp,rounding,saturation);
    hdlbody=[hdlbody,tmpbody];
    hdlsignals=[hdlsignals,tmpsignals];

    tmpbody=hdlmux([subtemp,addtemp],out,subtractin,'=',[1,0],'when-else');
    hdlbody=[hdlbody,tmpbody];




