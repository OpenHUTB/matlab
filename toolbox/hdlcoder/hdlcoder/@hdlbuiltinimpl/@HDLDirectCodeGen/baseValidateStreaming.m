function v=baseValidateStreaming(this,hN)%#ok<*INUSL>



    v=hdlvalidatestruct;

    if hN.getStreamingFactor>0
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:illegalBlockSerialization'));
    end
