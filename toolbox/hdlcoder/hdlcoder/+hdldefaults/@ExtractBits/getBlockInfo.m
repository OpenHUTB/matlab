function[ul,ll,mode]=getBlockInfo(this,slbh,hC)


    setting=get_param(slbh,'bitsToExtract');
    mode=strcmpi(get_param(slbh,'outScalingMode'),'Treat bit field as an integer');

    inSignal=hC.SLInputSignals(1);
    inType=inSignal.Type;
    hBT=inType.getLeafType;

    if hBT.isFloatType()
        wlen=0;
    else
        wlen=hBT.WordLength;
    end

    if(strcmpi(setting,'Lower half'))
        ul=ceil(wlen/2)-1;
        ll=0;
    elseif(strcmpi(setting,'Upper half'))
        ul=wlen-1;
        ll=floor(wlen/2);
    elseif(strcmpi(setting,'Range starting with most significant bit'))
        numBits=this.hdlslResolve('numBits',slbh);
        ul=wlen-1;
        ll=wlen-numBits;
    elseif(strcmpi(setting,'Range ending with least significant bit'))
        numBits=this.hdlslResolve('numBits',slbh);
        ul=numBits-1;
        ll=0;
    elseif(strcmpi(setting,'Range of bits'))
        range=this.hdlslResolve('bitIdxRange',slbh);
        if(length(range)==2)

            ll=range(1);
            ul=range(2);
        else

            ll=range(1);
            ul=wlen-1;
        end
    else
        error(message('hdlcoder:validate:invalidmasksetting'));
    end



end


