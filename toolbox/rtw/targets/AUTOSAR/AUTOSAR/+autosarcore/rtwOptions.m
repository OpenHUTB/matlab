function varargout=rtwOptions(action)






    switch action
    case 'GetSupportedSchemaStrs'

        strs='4.0|4.1|4.2|4.3|4.4|R19-11';
        if slfeature('AutosarClassicR2011')
            strs=[strs,'|R20-11'];
        end

        varargout{1}=strs;
    case 'GetDefaultSchema'
        if slfeature('AutosarClassicR2011')
            defaultSchema='R20-11';
        else
            defaultSchema='4.3';
        end

        varargout{1}=defaultSchema;

    case 'GetRtwOptionsVersion'
        rtwOptionsVersion='2';

        varargout{1}=rtwOptionsVersion;

    otherwise

    end


