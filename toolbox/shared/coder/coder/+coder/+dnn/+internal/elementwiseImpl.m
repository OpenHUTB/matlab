function elementwiseImpl(externalUse)
%#codegen


    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');
        coder.internal.prefer_const(externalUse);
        coder.inline('always');
        coder.ceval('-preservearraydims','__dnn_elementwise',externalUse);
    end

end
