function str=mulExpr(in1,in2,out,realonly,indent)






    if nargin<4
        realonly=false;
        indent=1;
    elseif nargin<5
        indent=1;
    end

    assignOp=' <= ';
    mulOp=' * ';
    addOp=' + ';
    subOp=' - ';
    termOp=';';


    in1C=hdlsignalcomplex(in1);
    in2C=hdlsignalcomplex(in2);
    outC=hdlsignalcomplex(out);

    if in1C&&in2C&&~realonly
        in1im=hdlsignalimag(in1);
        in2im=hdlsignalimag(in2);
        outim=hdlsignalimag(out);

        str=[hdl.indent(indent),hdlsignalname(out),assignOp,...
        mulSubExpr(in1,in2),subOp,mulSubExpr(in1im,in2im),...
        termOp,hdl.newline,...
        hdl.indent(indent),hdlsignalname(outim),assignOp,...
        mulSubExpr(in1im,in2),addOp,mulSubExpr(in1,in2im),...
        termOp,hdl.newline];

    elseif in1C&&~realonly
        in1im=hdlsignalimag(in1);
        outim=hdlsignalimag(out);

        str=[hdl.indent(indent),hdlsignalname(out),assignOp,...
        mulSubExpr(in1,in2),termOp,hdl.newline,...
        hdl.indent(indent),hdlsignalname(outim),assignOp,...
        mulSubExpr(in1im,in2),termOp,hdl.newline];

    elseif in2C&&~realonly
        in2im=hdlsignalimag(in2);
        outim=hdlsignalimag(out);

        str=[hdl.indent(indent),hdlsignalname(out),assignOp,...
        mulSubExpr(in2,in1),termOp,hdl.newline,...
        hdl.indent(indent),hdlsignalname(outim),assignOp,...
        mulSubExpr(in2im,in1),termOp,hdl.newline];

    else
        str=[hdl.indent(indent),hdlsignalname(out),assignOp,...
        mulSubExpr(in1,in2),...
        termOp,hdl.newline];
    end


    function str=mulSubExpr(in1,in2)
        sz1=hdlwordsize(hdlsignalsltype(in1));
        sz2=hdlwordsize(hdlsignalsltype(in2));

        name1=hdlsignalname(in1);
        name2=hdlsignalname(in2);
        mulOp=' * ';

        if sz1==1&&sz2==1
            if hdlgetparameter('isvhdl')
                mulOp=' AND ';
            else
                mulOp=' & ';
            end
        elseif sz1==1
            if hdlgetparameter('isvhdl')
                name1=['("0" & ',name1,')'];
            else
                name1=['{ 1''b0, ',name1,' }'];
            end
        elseif sz2==1
            if hdlgetparameter('isvhdl')
                name2=['("0" & ',name2,')'];
            else
                name2=['{ 1''b0, ',name2,' }'];
            end
        end
        str=[name1,mulOp,name2];
