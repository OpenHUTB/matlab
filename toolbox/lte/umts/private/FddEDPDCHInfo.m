





















function info=FddEDPDCHInfo(config)
    validateUMTSParameter('ULModulation',config.Modulation);
    is4pam=0;
    if strcmpi(config.Modulation,'4PAM');
        is4pam=1;
    end
    if(is4pam)
        if length(config.CodeCombination)~=4||~isequal(config.CodeCombination,[2,2,4,4])
            error('umts:error','For 4PAM Modulation the only valid code combination is [2 2 4 4] ')
        end
    end

    if~any(config.hsdschConfigured==[0,1])
        error('umts:error','The valid values for hsdschConfigured are 0(No), 1(Yes) ');
    end

    if(~isfield(config,'Nmaxdpdch'))
        config.Nmaxdpdch=0;
    elseif~any(config.Nmaxdpdch==[0,1])
        error('umts:error','The valid values for Nmaxdpdch are 0 and 1');
    end

    if~any(config.TTI==[2,10])
        error('umts:error',['Invalid E-DCH TTI (',num2str(config.TTI),') specified. Must be 2 or 10']);
    end

    valid=0;
    info.phyFrameCapacity=sum(3840./config.CodeCombination*config.TTI*(is4pam+1));
    if length(config.CodeCombination)==4
        if isequal(config.CodeCombination,[2,2,4,4])
            info.phyChCapacities=[3840,3840,1920,1920].*(config.TTI/2)*(is4pam+1);
            info.SpreadingCode=ones(1,4);
            info.iqMap=[1,1i,1,1i];
        else
            error('umts:error','Invalid CodeCombination');
        end
    elseif length(config.CodeCombination)==2
        info.SpreadingCode=[1,1];
        if isequal(config.CodeCombination,[4,4])
            info.phyChCapacities=[1920,1920].*(config.TTI/2);
            if(config.Nmaxdpdch)
                info.SpreadingCode=[2,2];
            end
        elseif isequal(config.CodeCombination,[2,2])
            info.phyChCapacities=[3840,3840].*(config.TTI/2);
        else
            error('umts:error','Invalid CodeCombination');
        end
        if config.hsdschConfigured==0
            info.iqMap=[1i,1];
        else
            info.iqMap=[1,1i];
        end
    elseif length(config.CodeCombination)==1
        for i=2:8
            if(config.CodeCombination==2^i)
                valid=1;
            end
        end
        if valid==0
            error('umts:error','Invalid CodeCombination');
        end
        info.phyChCapacities=7680/config.CodeCombination*(config.TTI/2);
        info.SpreadingCode=config.CodeCombination/4;
        info.iqMap=1;
        if config.Nmaxdpdch
            info.SpreadingCode=config.CodeCombination/2;
            if config.hsdschConfigured==0
                info.iqMap=1i;
            end
        end

    else
        error('umts:error','Invalid CodeCombination');
    end
