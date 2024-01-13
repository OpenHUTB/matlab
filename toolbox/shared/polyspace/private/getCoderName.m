function str=getCoderName(coderID)

    if strcmpi(coderID,pslink.verifier.codegen.Coder.CODER_ID)
        str=pslink.verifier.codegen.Coder.getCoderName();
    elseif strcmpi(coderID,pslink.verifier.ec.Coder.CODER_ID)
        str=pslink.verifier.ec.Coder.getCoderName();
    elseif strcmpi(coderID,pslink.verifier.tl.Coder.CODER_ID)
        str=pslink.verifier.tl.Coder.getCoderName();
    elseif strcmpi(coderID,pslink.verifier.sfcn.Coder.CODER_ID)
        str=pslink.verifier.sfcn.Coder.getCoderName();
    elseif strcmpi(coderID,pslink.verifier.slcc.Coder.CODER_ID)
        str=pslink.verifier.slcc.Coder.getCoderName();
    else
        str='';
    end
