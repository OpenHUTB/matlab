function varargout=hdlblkmask_fft(prop,varargin)










    switch lower(prop)
    case 'sine_mode'
        sine_mode_callback;
    case 'prod_mode'
        prod_mode_callback;
    case 'accum_mode'
        accum_mode_callback;
    case 'output_mode'
        output_mode_callback;
    case 'fft_length'
        varargout{1}=fft_length_callback;
    case 'initial_delay'
        varargout{1}=initial_delay_callback(varargin{:});
    case 'block_name'
        varargout{1}=block_name_callback;
    end
end


function sine_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    sinemode=get_param(gcb,'sinemode');
    if strcmp(sinemode,'Same word length as input')
        maskenb{5}='off';
    else
        maskenb{5}='on';
    end
    set_param(gcb,'MaskEnables',maskenb);

end



function prod_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    prodmode=get_param(gcb,'prodmode');
    if~strcmp(prodmode,'Binary point scaling')
        maskenb{7}='off';
        maskenb{8}='off';
    else
        maskenb{7}='on';
        maskenb{8}='on';

    end
    set_param(gcb,'MaskEnables',maskenb);

end



function accum_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    accumode=get_param(gcb,'accumode');
    if~strcmp(accumode,'Binary point scaling')
        maskenb{10}='off';
        maskenb{11}='off';
    else
        maskenb{10}='on';
        maskenb{11}='on';
    end
    set_param(gcb,'MaskEnables',maskenb);

end


function output_mode_callback


    maskenb=get_param(gcb,'MaskEnables');
    outputmode=get_param(gcb,'outputmode');
    if~strcmp(outputmode,'Binary point scaling')
        maskenb{13}='off';
        maskenb{14}='off';
    else
        maskenb{13}='on';
        maskenb{14}='on';

    end

    set_param(gcb,'MaskEnables',maskenb);

end

function N=fft_length_callback


    N=hdlslResolve('N',gcb);
    TotalStage=log2(N);


    if~isequal(TotalStage,floor(TotalStage))||TotalStage<3||TotalStage>16

        error(message('dsp:hdlshared:Powerof2'));
    end

end

function totaldelay=initial_delay_callback(varargin)


    if nargin<1

        error(message('dsp:hdlshared:needSpecifyBlk'));
    end
    blk=varargin{1};


    N=hdlslResolve('N',blk);
    TotalStage=log2(N);






    InitStage=N/2+6;


    PipeBF=5;
    PipeBFMin=2;

    PipeStage0=2;


    MidStage=((N/2-1)+...
    (TotalStage-3)*PipeBFMin+...
    (PipeBF-1)+...
    PipeBF+...
    PipeStage0)*2;


    addrWidth=TotalStage;
    numOne=floor(addrWidth/2);
    numZero=addrWidth-numOne;
    BitRevDelay=(2^addrWidth-2^numZero)-(2^numOne-1)+1;





    isBitReversed=get_param(blk,'isBitReversed');
    if strcmp(isBitReversed,'on')
        EndStage=3;
    else
        EndStage=BitRevDelay+4;
    end


    totaldelay=InitStage+MidStage+EndStage;

end

function blkname=block_name_callback


    dispDelay=get_param(gcb,'dispDelay');
    if strcmp(dispDelay,'on')
        initDelay=hdlblkmask_fft('initial_delay',gcb);
        blkname=['\nFFT\n\n',sprintf('   -%d\nZ     ',initDelay)];
    else
        blkname='';
    end

end
