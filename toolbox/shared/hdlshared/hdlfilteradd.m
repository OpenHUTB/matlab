function[hdlbody,hdlsignals]=hdlfilteradd(in1,in2,out,rounding,saturation)












    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    [hdlbody,hdlsignals]=hdladd(in1,in2,out,rounding,saturation);

    if emitMode

        if~hdlsignalcomplex(in1)&&~hdlsignalcomplex(in2)&&hdlsignalcomplex(out)

            outim_all=hdlgetallfromsltype(hdlsignalsltype(out));
            [ignored,const_zero]=hdlnewsignal('const_zero_im',...
            'filter',-1,0,0,outim_all.vtype,outim_all.sltype);
            constdecl=makehdlconstantdecl(const_zero,hdlconstantvalue(0,outim_all.size,outim_all.bp,1));
            hdlbody=[hdlbody,hdlsignalassignment(const_zero,hdlsignalimag(out))];
            hdlsignals=[hdlsignals,constdecl];

        end
    end



