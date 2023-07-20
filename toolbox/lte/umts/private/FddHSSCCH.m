




































































function out=FddHSSCCH(config,bits)

    if nargin==1
        if~isfield(config,'UEConfiguredForMIMO')
            config.UEConfiguredForMIMO=0;
        end
        if config.UEConfiguredForMIMO
            bits=FddHSSCCHCodingType3(config)';
        else
            bits=FddHSSCCHCoding(config)';
        end
    end
    symbols=FddDLModulation(bits,0)/sqrt(2);
    chips=FddSpreading(symbols,128,config.HSSCCHSpreadingCode,1);
    out=FddScrambling(chips,1,config.ScramblingCode,7680*mod(config.NSubframe,5))/sqrt(2);

end