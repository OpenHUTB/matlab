






























function waveform=FddRRCFiltering(chipsin,nchips,osr,filterflag)

    if nargin<4
        filterflag='RRC';
    end
    if strcmpi(filterflag,'Off')

        waveform=filter(ones(osr,1),1,upsample(chipsin,osr));
        return;
    end


    nchips=validate(nchips,'number of chips that the RRC filter spans');


    alpha=0.22;
    rrc=rcosdesign(alpha,nchips,osr,'sqrt');


    rrc=rrc*sqrt(osr);


    waveform=FddLoopableFiltering(chipsin,rrc,nchips,osr,'tail');

end

function value=validate(value,name)

    original=value;
    value=fix(value);

    if(value<=0)
        error('umts:error','The %s (%s) must be positive (non-zero).',name,num2str(original));
    end

end

