function v=validateBlock(this,hC)

    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;
    wordlen=hdlslResolve('CountWordLen',bfp);
    dirport=get_param(bfp,'CountDirPort');

    if(wordlen==1)&&strcmpi(dirport,'on')
        v=hdlvalidatestruct(2,...
        message('hdlcoder:validate:unuseddirport'));
    end


    CInfo=this.getBlockInfo(hC);

    if(~isempty(CInfo.CountToValue))&&isa(CInfo.CountToValue,'double')&&(abs(CInfo.CountToValue)>=2^53)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedlargecounter','Count to'));
    end

    if(~isempty(CInfo.CountFromValue))&&isa(CInfo.CountFromValue,'double')&&(abs(CInfo.CountFromValue)>=2^53)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedlargecounter','Count from'));
    end

    if(~isempty(CInfo.InitValues))&&isa(CInfo.InitValues,'double')&&(abs(CInfo.InitValues)>=2^53)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedlargecounter','Init'));
    end

    if(~isempty(CInfo.StepValue))&&isa(CInfo.StepValue,'double')&&(abs(CInfo.StepValue)>=2^53)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedlargecounter','Step'));
    end

end



