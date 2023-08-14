%#codegen
function dout=hdleml_unbuffer(din,ic,ctrSize)









    coder.allowpcode('plain')
    eml_prefer_const(ic);


    inputLen=length(din);
    eml_assert(inputLen>=2,'No need to use serializer for scalar input.');

    persistent ctr
    if isempty(ctr)
        ctr=fi(ic,0,ctrSize,0,hdlfimath);
    end

    dout=din(ctr);
    ctr=fi(ctr+1,0,ctrSize,0,hdlfimath);
    if ctr>inputLen
        ctr=fi(1,0,ctrSize,0,hdlfimath);
    end
