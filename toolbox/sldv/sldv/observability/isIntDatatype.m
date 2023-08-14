function out=isIntDatatype(datatype)


    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(datatype);
    coder.extrinsic('sldvprivate');
    out=coder.const(sldvprivate('isIntDatatype',datatype));
end

