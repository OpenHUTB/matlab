function checkRegReadWriteParams(op,subfamily,mmr,represent,supportedRegs,statusRegs)

    DataTypes={'binary','2scomp','ieee'};

    if nargin>=5
        knownSupportedRegs=1;
    else
        knownSupportedRegs=0;
    end
    if nargin==6
        knownStatusRegs=1;
    else
        knownStatusRegs=0;
    end

    regPairSupported=0;
    subfamily_str=strrep(subfamily,'x','00');
    switch subfamily
    case 'C6x'
        subfamily_str=strrep(subfamily,'x','000');
        regPairSupported=1;
    case 'C55x'
    case 'C54x'
    case 'C28x'
    case 'C27x'
    case 'C24x'
    case{'Rxx','R1x','R2x'}
        subfamily_str=strrep(subfamily,'x','x');
    otherwise
    end

    switch op
    case 'regread'

        methodDesc='RegRead';

        if~ischar(mmr),
            error(message('TICCSEXT:autointerface:Register_InvalidSecondParam',methodDesc));
        end

        if~isempty(strfind(mmr,':'))
            error(message('TICCSEXT:autointerface:Register_RegPairNotSupportedInRead',methodDesc,subfamily_str));
        end

        if~ischar(represent),
            error(message('TICCSEXT:autointerface:Register_InvalidThirdParam',methodDesc));
        end

        if isempty(find(strcmpi(represent,DataTypes),1))
            error(message('TICCSEXT:autointerface:Register_InvalidRepresentation',methodDesc,represent));
        end

        if knownSupportedRegs&&isempty(find(strcmp(mmr,supportedRegs),1))
            error(message('TICCSEXT:autointerface:Register_RegNotSupported',methodDesc,mmr,subfamily_str));
        end

    case 'regwrite'

        methodDesc='RegWrite';

        if~ischar(mmr),
            DAStudio.error('TICCSEXT:autointerface:Register_InvalidSecondParam',methodDesc);
        end

        if~isempty(strfind(mmr,':'))
            error(message('TICCSEXT:autointerface:Register_RegPairNotSupportedInWrite',methodDesc,subfamily_str));
        end

        if~ischar(represent),
            error(message('TICCSEXT:autointerface:Register_InvalidFourthParam',methodDesc));
        end

        if isempty(find(strcmpi(represent,DataTypes),1))
            DAStudio.error('TICCSEXT:autointerface:Register_InvalidRepresentation',...
            methodDesc,represent);
        end

        if knownSupportedRegs&&isempty(find(strcmp(mmr,supportedRegs),1))
            DAStudio.error('TICCSEXT:autointerface:Register_RegNotSupported',...
            methodDesc,mmr,subfamily_str);
        end

        if knownStatusRegs&&~isempty(find(strcmp(mmr,statusRegs),1))
            error(message('TICCSEXT:autointerface:Register_StatusRegsNotSupported',mmr));
        end

    otherwise
    end


