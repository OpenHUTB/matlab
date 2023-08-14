%#codegen
function y=hdleml_bitconcat_vec(outtpex,numIn,varargin)



    coder.allowpcode('plain')
    eml_prefer_const(outtpex,numIn);

    outLen=length(varargin)/numIn;
    eml_assert(mod(length(varargin),numIn)==0,'Input Length is not correctly formatted');
    y=hdleml_define_len(outtpex,outLen);



    for ii=1:outLen
        startIdx=((ii-1)*numIn)+1;
        endIdx=startIdx+numIn-1;
        y(ii)=bitconcat(varargin{eml_const(startIdx):eml_const(endIdx)});
    end

