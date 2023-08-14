function v=validateBlock(~,hC)


    v=hdlvalidatestruct(3,message('hdlcoder:validate:highztb'));

    out=hC.PIROutputPorts(1).Signal;
    if hdlsignalisdouble(out)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:outputdouble'));
    end
    if out.Type.isMatrix
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:matrix:LogicConstUnsupported'));
    end
end


