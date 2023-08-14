function varargout=dspblkanalog(action,varargin)




    blk=gcb;
    if nargin==0
        action='dynamic';
    end

    switch action
    case 'dynamic'




        mask_enables=get_param(blk,'maskenables');
        mask_prompts=get_param(blk,'maskprompts');
        mask_visibilities=get_param(blk,'maskvisibilities');

        filter_type=get_param(blk,'filttype');
        method=get_param(blk,'method');
        switch filter_type
        case{'Lowpass','Highpass'}
            if(strcmp(method,'Chebyshev II'))
                mask_prompts{4}='Stopband edge frequency (rad/s):';
            else
                mask_prompts{4}='Passband edge frequency (rad/s):';
            end
            mask_visibilities(5)={'off'};
            mask_prompts{5}='(unused)';


        case{'Bandpass','Bandstop'}
            mask_visibilities(5)={'on'};
            if(strcmp(method,'Chebyshev II'))
                mask_prompts{4}='Lower stopband edge frequency (rad/s):';
                mask_prompts{5}='Upper stopband edge frequency (rad/s):';
            else
                mask_prompts{4}='Lower passband edge frequency (rad/s):';
                mask_prompts{5}='Upper passband edge frequency (rad/s):';
            end

        otherwise
            error(message('dsp:dspblkanalog:unknownFilterType'));
        end


        switch method
        case{'Butterworth','Bessel'}
            mask_visibilities{6}='off';
            mask_visibilities{7}='off';
        case 'Chebyshev I'
            mask_visibilities{6}='on';
            mask_visibilities{7}='off';
        case 'Chebyshev II'
            mask_visibilities{6}='off';
            mask_visibilities{7}='on';
        case 'Elliptic'
            mask_visibilities{6}='on';
            mask_visibilities{7}='on';
        otherwise
            error(message('dsp:dspblkanalog:unknownFliterDesignType'));
        end

        set_param(blk,'maskenables',mask_enables,...
        'maskvisibilities',mask_visibilities,...
        'maskprompts',mask_prompts);

    case 'design'
        sys=bdroot(blk);
        status=get_param(sys,'SimulationStatus');
        if~strcmp(status,'stopped')&&~builtin('license','checkout','Signal_Blocks')
            error(message('dspshared:block:sigLicenseFailed','dspblkanalog'));
        end


        [varargout{1:nargout}]=dspanalogdes(varargin{:});
    otherwise
        error(message('dsp:dspblkanalog:unhandledCase'));
    end


    function[a,b,c,d,str]=dspanalogdes(method,type,N,Wlo,Whi,Rp,Rs)













        if isnan(N)||isinf(N)
            error(message('dsp:dspblkanalog:invalidFilterOrder1'));
        end


        if~isequal(floor(N),N)
            error(message('dsp:dspblkanalog:invalidFilterOrder2'));
        end


        if N<1
            error(message('dsp:dspblkanalog:invalidFilterOrder3'));
        end


        a=[];b=[];c=[];d=[];str='';

        switch type
        case 'Lowpass'
            fband=Wlo;ftype='low';
        case 'Highpass'
            fband=Wlo;ftype='high';
        case 'Bandpass'
            fband=[Wlo,Whi];ftype='bandpass';
        case 'Bandstop'
            fband=[Wlo,Whi];ftype='stop';
        end

        switch method
        case 'Butterworth'
            [a,b,c,d]=butter(N,fband,ftype,'s');
            str='butter';
        case 'Chebyshev I'
            str='cheby1';
            [a,b,c,d]=cheby1(N,Rp,fband,ftype,'s');
        case 'Chebyshev II'
            str='cheby2';
            [a,b,c,d]=cheby2(N,Rs,fband,ftype,'s');
        case 'Elliptic'
            str='ellip';
            [a,b,c,d]=ellip(N,Rp,Rs,fband,ftype,'s');
        case 'Bessel'
            str='besself';
            if strcmp(type,'Bandpass')||strcmp(type,'Lowpass')
                [a,b,c,d]=besself(N,fband);
            else
                [a,b,c,d]=besself(N,fband,ftype);
            end
        end


