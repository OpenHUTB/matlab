

function outputMessage(message,kind)
    switch kind
    case 'error'
        Simulink.output.error(message);
    case 'warning'
        MSLDiagnostic(message).reportAsWarning;
    case 'info'
        Simulink.output.info(message);
    otherwise
        assert(true,'slci.internal.outputMessage kind cannot be other than error, warning, info');
    end
end
