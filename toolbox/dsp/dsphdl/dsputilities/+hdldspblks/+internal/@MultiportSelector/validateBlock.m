function v=validateBlock(~,hC)


    v=hdlvalidatestruct;


    numoutputs=length(hC.SLOutputPorts);
    out_iscmplx=false(1,numoutputs);
    for ii=1:numoutputs
        out_iscmplx(ii)=hdlsignaliscomplex(hC.SLOutputSignals(ii));
    end


    in=hC.SLInputSignals(1);
    in_iscmplx=hdlsignaliscomplex(in);


    if~((in_iscmplx&&all(out_iscmplx))||...
        (~in_iscmplx&&all(~out_iscmplx)))
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:MultiportSelector:validateBlock:mixedrealcomplex'));
    end
