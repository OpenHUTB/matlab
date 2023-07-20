function str=sum_expr(in1,in2,sum_type)













    name1=hdlsignalname(in1);
    handle1=hdlsignalhandle(in1);
    vector1=hdlsignalvector(in1);
    vtype1=hdlsignalvtype(in1);
    sltype1=hdlsignalsltype(in1);
    [size1,bp1,signed1]=hdlwordsize(sltype1);

    name2=hdlsignalname(in2);
    handle2=hdlsignalhandle(in2);
    vector2=hdlsignalvector(in2);
    vtype2=hdlsignalvtype(in2);
    sltype2=hdlsignalsltype(in2);
    [size2,bp2,signed2]=hdlwordsize(sltype2);


    [outsize,outbp,outsigned]=deal(sum_type(1),sum_type(2),sum_type(3));
    [outvtype,outsltype]=hdlgettypesfromsizes(outsize,outbp,outsigned);










    resultsigned=outsigned;
    sumsize=outsize;
    sumbp=outbp;
    [sumvtype,sumsltype]=hdlgettypesfromsizes(sumsize,sumbp,resultsigned);



    addend1=hdltypeconvert(name1,size1,bp1,signed1,vtype1,...
    outsize,outbp,outsigned,outvtype,...
    'floor',false);

    addend2=hdltypeconvert(name2,size2,bp2,signed2,vtype2,...
    outsize,outbp,outsigned,outvtype,...
    'floor',false);



    str=[hdl.indent(0),addend1,' + ',addend2];




