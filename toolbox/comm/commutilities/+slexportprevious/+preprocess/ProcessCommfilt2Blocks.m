function ProcessCommfilt2Blocks(obj)

    if isR2013aOrEarlier(obj.ver)
        Rctxblk=obj.findBlocksWithMaskType('Raised Cosine Transmit Filter');
        Rcrxblk=obj.findBlocksWithMaskType('Raised Cosine Receive Filter');
        Rcblk=[Rctxblk;Rcrxblk];

        for p=1:length(Rcblk)
            block=Rcblk{p};
            filtSpanStr=get_param(block,'filtSpan');
            try
                filtSpan=evalin('base',filtSpanStr);
            catch e
                if any(strcmp(e.identifier,{'MATLAB:undefinedVarOrClass',...
                    'MATLAB:UndefinedFunction'}))
                    error(message(...
                    'comm:saProcessCommfilt2Blocks:NotInBaseWorkspace',...
                    filtSpanStr));
                end
            end
            set_param(block,'D',sprintf('(%s)/2',filtSpanStr));

            if strcmp(get_param(block,'MaskType'),'Raised Cosine Receive Filter')

                set_param(block,'rateMode','Downsampling');
            end

            try
                Rstr=get_param(block,'R');
                R=evalin('base',Rstr);
            catch e
                if any(strcmp(e.identifier,{'MATLAB:undefinedVarOrClass',...
                    'MATLAB:UndefinedFunction'}))
                    error(message(...
                    'comm:saProcessCommfilt2Blocks:NotInBaseWorkspace',Rstr));
                end
            end
            try
                Nstr=get_param(block,'N');
                N=evalin('base',Nstr);
            catch e
                if any(strcmp(e.identifier,{'MATLAB:undefinedVarOrClass',...
                    'MATLAB:UndefinedFunction'}))
                    error(message(...
                    'comm:saProcessCommfilt2Blocks:NotInBaseWorkspace',Nstr));
                end
            end
            filterGain=get_param(block,'filterGain');
            if contains(filterGain,'rcfiltgaincompat')
                filterGain=strrep(filterGain,'gcbh','block');
                filterGain=sprintf('%1.25f',(eval(filterGain)));
            end
            filtType=get_param(block,'filtType');
            switch filtType
            case 'Normal'
                b=rcosdesign(R,filtSpan,N,'normal');
                g=max(b);
            case 'Square root'
                b=rcosdesign(R,filtSpan,N,'sqrt');
                g=max(b)/(((-1/(pi*N)*(pi*(R-1)-4*R)))*sqrt(N));
            end
            set_param(block,'filterGain',sprintf('%1.25f*(%s)',g,filterGain'));
            set_param(block,'checkGain','User-specified');
        end
    end

    if isR2015bOrEarlier(obj.ver)
        if isR2008aOrEarlier(obj.ver)
            Rctxblk=obj.findBlocksWithMaskType('Raised Cosine Transmit Filter');
            Rcrxblk=obj.findBlocksWithMaskType('Raised Cosine Receive Filter');
            Rcblk=[Rctxblk;Rcrxblk];
            n2bReplaced=length(Rcblk);
            if n2bReplaced>0
                for i=1:length(Rcblk)
                    rateOptions=get_param(Rcblk{i},'RateOptions');
                    if strcmp(rateOptions,'Enforce single-rate processing')
                        sampleMode='Frame-based';
                    elseif strcmp(rateOptions,'Allow multirate processing')
                        sampleMode='Sample-based';
                    end
                    set_param(Rcblk{i},'saveAsFlag','1');
                    set_param(Rcblk{i},'sampMode',sampleMode);
                end
            end
        else
            Rctxblk=obj.findBlocksWithMaskType('Raised Cosine Transmit Filter');
            Rcrxblk=obj.findBlocksWithMaskType('Raised Cosine Receive Filter');
            Rcblk=[Rctxblk;Rcrxblk];
            n2bReplaced=length(Rcblk);
            if n2bReplaced>0
                for i=1:length(Rcblk)
                    rateOptions=get_param(Rcblk{i},'RateOptions');
                    if strcmp(rateOptions,'Enforce single-rate processing')
                        framing='Enforce single-rate processing';
                    elseif strcmp(rateOptions,'Allow multirate processing')
                        framing='Allow multirate processing';
                    end
                    set_param(Rcblk{i},'saveAsFlag','1');
                    set_param(Rcblk{i},'framing',framing);
                end
            end
        end
    end

    if isR2015bOrEarlier(obj.ver)
        rectPulblk=obj.findBlocksWithMaskType('Ideal Rectangular Pulse Filter');
        n2bReplaced=length(rectPulblk);
        if n2bReplaced>0
            for i=1:length(rectPulblk)
                rateOptions=get_param(rectPulblk{i},'RateOptions');
                if strcmp(rateOptions,'Enforce single-rate processing')
                    sampleMode='Frame-based';
                elseif strcmp(rateOptions,'Allow multirate processing')
                    sampleMode='Sample-based';
                end
                set_param(rectPulblk{i},'saveAsFlag','1');
                set_param(rectPulblk{i},'sampMode',sampleMode);
            end
        end
    end

